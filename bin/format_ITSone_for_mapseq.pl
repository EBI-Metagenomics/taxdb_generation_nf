#!/usr/bin/env perl
# -*- coding: utf-8 -*-

# Copyright 2023 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This takes a derived file from the ITSone database ncbi taxids and lineages and tries
# to map this to the NCBI taxonomy tree. As mapseq needs uniform lineages, we need to 
# perform the standard tree walking and pruning of the NCBI tree.
#
use strict;
use warnings;
use File::Slurp;
use Getopt::Long;
use Digest::MD5 qw(md5_hex);
use JSON;
use LWP::Simple;
use Archive::Tar;
use DDP;

my ($outDir, $force, $input, $help);


GetOptions( "out=s"               => \$outDir,
            "force=i"             => \$force,
            "in=s"                => \$input,
            "h|help"              => \$help )  or die "Error with options, try $0 --help\n";

help() if($help);

$outDir = "." if(!$outDir);


my @taxmaps;

if(!defined($input)){
  help();
  die "No input file provided\n";
}else{
  @taxmaps = read_file($input);
}

my $treeData = fetchNCBI($outDir, $force);
process_taxmap(\@taxmaps, $treeData);

#cluster_files($taxmaps, $mapseqLoc);


#------------------------------------------------------------------------------
# subroutines ----------------------------------------------------------------- 
#------------------------------------------------------------------------------

# Get the taxonomy data from NCBI
sub fetchNCBI {
  my($outDir, $force) = @_;
  print STDERR "Getting ncbi data\n";

  my $outDirTax = $outDir.'/taxonomy';

  #Store the taxonomy file for future reference.
  unless ( -d $outDirTax ) {
    mkdir( $outDirTax )
        or die "Could not make the directory $outDirTax because: [$!]\n";
  }

  foreach my $f (qw(taxdump.tar.gz)){
    my $thisFile = $outDirTax."/".$f;
    if($force){
      if(-e $thisFile){
       unlink($thisFile) or die "Failed to remove $thisFile: [$!]\n";  
      }
    }


    if(!-e $thisFile){
      my $rc = getstore(
        'ftp://ftp.ncbi.nih.gov/pub/taxonomy/'.$f, $thisFile); 
      die 'Failed to get the file ncbi taxdump' unless ( is_success($rc) );
    }
  }

  print "Extracting ncbi data\n";
  my $tar = Archive::Tar->new;
  $tar->read( $outDirTax. '/taxdump.tar.gz' );
  if(!-e $outDirTax.'/nodes.dmp' or $force){
    $tar->extract_file( 'nodes.dmp', $outDirTax .'/nodes.dmp' );
  }
  if(!-e $outDirTax.'/names.dmp' or $force){
    $tar->extract_file( 'names.dmp', $outDirTax.'/names.dmp' );
  }
  my $treeData = startBuildTree($outDirTax);
}

sub startBuildTree {
  my ($outDirTax) = @_;
#-------------------------------------------------------------------------------
# Build up all the ncbi nodes. Read into a hash array
  print STDERR "Parsing ncbi data (names.dmp)\n";

#------------------------------------------------------------------------------
#This is a bit of a hack, but we want to keep these levels so we can hang
#all sequences off this

  #Move to config
  my %promote;
  foreach my $l ( "Viroids", "Viruses", "unclassified sequences", "other sequences" )
  {
    $promote{$l}++;
  }

  my %promoteTaxIds;

#------------------------------------------------------------------------------
# Extract just the scientific names (for the time being, it may be useful to
# have synonyms and lay terms ).
#
  my %names2taxid;
  my %taxid2names;
  my %minNames;
  open( _NAMES, $outDirTax. '/names.dmp' )
  or die "Could not open $outDirTax/names.dmp: [$!]\n";
  while (<_NAMES>) {
    next unless (/scientific name/);
    @_ = split( /\|/, $_ );
    my ($taxid) = $_[0] =~ /(\d+)/;
    my ($name)  = $_[1] =~ /\s+(.*)\s+/;
    $taxid2names{$taxid} = $name;
    push( @{$names2taxid{$name}}, $taxid );  
    $promoteTaxIds{$taxid}++ if ( $promote{$name} );
  }
  close(_NAMES);

#------------------------------------------------------------------------------
#Now parse the nodes file
#
  open( _NODES,  $outDirTax.'/nodes.dmp'  )
    or die "Could not open nodes.dmp: [$!]";

  my $nodes = [];    #This will be out store for all the nodes in the tree
  while (<_NODES>) {
    @_ = split( /\|/, $_ );
    my ($taxid)  = $_[0] =~ /(\d+)/;
    my ($parent) = $_[1] =~ /(\d+)/;
    my ($rank)   = $_[2] =~ /\s+(.*)\s+/;
    #Shunt those special ids to be superkingdoms.
    $rank = 'superkingdom' if ( $promoteTaxIds{$taxid} );
    
    unless(defined($taxid2names{$taxid})){
       #warn $taxid. " has no name\n"; 
      $taxid2names{$taxid} = '_unnamed';
      push( @{$names2taxid{'_unamed'}}, $taxid );  
    }
    $nodes->[$taxid] = {
                       taxid  => $taxid,
                       parent => $parent,
                       rank   => $rank,
                       name   => $taxid2names{$taxid} };
  
  }
  close(_NODES);

  my $data = { names2taxid => \%names2taxid,
               taxid2names => \%taxid2names,
               nodes       => $nodes };

  return( $data );
}



#------------------------------------------------------------------------------
# subroutines ----------------------------------------------------------------- 
#------------------------------------------------------------------------------

sub traverseTree {
  my ( $hash, $nodes, $count ) = @_;
  foreach my $k ( keys %{$hash} ) {
    $nodes->[$k]->{lft} = $count++;
    $count = traverseTree( $hash->{$k}, $nodes, $count );
    $nodes->[$k]->{rgt} = $count++;
  }
  return $count;
}

sub traverseTreeForPrint {
  my ( $hash, $nodes, $taxString, $taxJson ) = @_;
  foreach my $k ( keys %{$hash} ) {
    my $thisTaxString = $taxString;
    $thisTaxString .= $nodes->[$k]->{name} . ';';
    my $jNode = { parent => $nodes->[$k]->{parent},
                  taxid  => $nodes->[$k]->{taxid},
                  name   => $nodes->[$k]->{name},
                  lft    => $nodes->[$k]->{lft},
                  rgt    => $nodes->[$k]->{rgt},
                  rank   => $nodes->[$k]->{rank},
                  tax    => $thisTaxString,
                  children => []};

    push(@{$taxJson}, $jNode);
    traverseTreeForPrint( $hash->{$k}, $nodes, $thisTaxString, $jNode->{children} );
  }
}

sub traverseTreeAndPrint {
  my ( $hash, $nodes, $taxString ) = @_;
  foreach my $k ( keys %{$hash} ) {
    my $thisTaxString = $taxString;
    $thisTaxString .= $nodes->[$k]->{name} . ';';
    print $k. "\t"
      . $nodes->[$k]->{parent} . "\t"
      . $nodes->[$k]->{rank} . "\t"
      . $nodes->[$k]->{lft} . "\t"
      . $nodes->[$k]->{rgt} . "\t"
      . $nodes->[$k]->{name} . "\t"
      . $thisTaxString . "\n";
    traverseTreeAndPrint( $hash->{$k}, $nodes, $thisTaxString );
  }
}

sub buildTree {
  my ( $tree, $nodes, $ranksRef ) = @_;

  foreach my $node (@$nodes) {
    next unless ($node);
    next unless ( $node->{rank} eq 'species' or $node->{rank} eq 'no rank' or $node->{rank} eq 'subspecies');
    
    my @speciesNodes;
    push( @speciesNodes, $node );
    my $pnode = $node;
    until ( $pnode->{parent} == $pnode->{taxid} ) {
      if( $ranksRef->{ $nodes->[ $pnode->{parent} ]->{rank} } ){
        $speciesNodes[-1]->{parent} = $nodes->[ $pnode->{parent} ]->{taxid};
        push( @speciesNodes, $nodes->[ $pnode->{parent} ] );
      }
      $pnode = $nodes->[ $pnode->{parent} ];
    }

    my $parent = $tree;
    #Now walk down buiding up the tree.
    for ( my $i = $#speciesNodes ; $i >= 0 ; $i-- ) {
      $parent->{ $speciesNodes[$i]->{taxid} } = {}
        unless exists $parent->{ $speciesNodes[$i]->{taxid} };
      $parent = $parent->{ $speciesNodes[$i]->{taxid} };
    }
  }

}


#-------------------------------------------------------------------------------

sub usage {

  print <<'EOF_help';
Usage: $0 

Build a database table of the taxonomic tree using the ncbi taxonomy files names.dmp and nodes.dmp

EOF_help

}

#-------------------------------------------------------------------------------









sub help {
  die "Print some help\n";

}


sub process_taxmap {
  my($taxmap, $treeData) = @_;
  open(T, ">", "itsonedb.taxid") or die "Could not open itsonedb.taxid;\n";
  my $checksk;
  my @olines;
TAXID:
  foreach my $line (@$taxmap){
    chomp($line);
    my $taxid=0;
    my @taxNames;
    my $taxName;
    #Split to taxid and tax string.
    #100011	Eukaryota; Fungi; Dikarya; Ascomycota; Pezizomycotina; Dothideomycetes; Dothideomycetes incertae sedis; Leptospora;
		#100033	Eukaryota; Fungi; Dikarya; Ascomycota; Pezizomycotina; Dothideomycetes; Pleosporomycetidae; Pleosporales; Massarineae; Lentitheciaceae; Keissleriella;
		#100036	Eukaryota; Fungi; Dikarya; Ascomycota; Pezizomycotina; Dothideomycetes; Pleosporomycetidae; Pleosporales; Pleosporales incertae sedis; Splanchnonema;
 
    if($line =~ /^(\S+)\t(.*)/){
      my $its_taxid = $1;
      my $taxonomy = $2;
      my $t;    
			my $found = 0;
      my $firstTaxid;
      my $taxidList;
      #Build hash with our taxonomy prefixes
      foreach my $k (qw(sk k p c o f g s)){
         $t->{$k} = $k."__";
      }
    
      my %ranks = ( superkingdom => 1,
                   	kingdom      => 1,
                    phylum       => 1,
                    class        => 1,
                    order        => 1,
                    family       => 1,
                    genus        => 1,
                    species      => 1 );
      
		  my $node;
      #Can we find the taxid assigned by ITSoneDB?
			if($its_taxid and $treeData->{nodes}->[$its_taxid]){
	      $taxid = $its_taxid;
	      $taxidList = $taxid;
			}else{
				#We have not going to have to resort to the tax lineage.
				@taxNames= split(/\;\s{0,1}/, "$taxonomy");
      	$taxName = pop(@taxNames);
				$taxid = undef;
			}
			
			#We now either have a name or a node based on the taxid.
			my $building = 1;
NAME:
      while($building){
        #print STDERR "building 1\n"; 
       	# We may have a taxid, or still trying to get an anchor
       	# on to the database.
				
			  my $i= 0;		
				if(defined($taxid)){
					$found=1;
				}else{	
					if($treeData->{names2taxid}->{$taxName}){
          	$found=1;
						$checksk=1;
            $taxid = $treeData->{names2taxid}->{$taxName}->[$i];
            $taxidList = $taxid;
						$i++;
          }else{
						if(scalar(@taxNames)){
 							$taxName = pop(@taxNames);
						}else{
							$found = 0;
							$building = 0;
						}
            next NAME;
					}
				} 
				$firstTaxid = $taxid if(!defined($firstTaxid));	

				while($building){
           my $node = $treeData->{nodes}->[$taxid]; 
					 #Grab the taxid for next time.
					 $taxid = $treeData->{nodes}->[$taxid]->{parent};
           $building = 0 if($taxid ==1);
              
           if($ranks{$node->{rank}}){
             #now determine the prefix that we want to use.
             my $prefix = '';
             if($node->{rank} eq 'superkingdom'){
             	$prefix='sk';
             	$taxidList .=';'.$node->{taxid};
              
							if($checksk and scalar(@taxNames)){
              	if($node->{name} ne $taxNames[0]){
                	#The superkingdoms do not match, therefore reset.  
                 	foreach my $k (qw(sk k p c o f g s)){
                  	$t->{$k} = $k."__";
                  }
                  $building = 1;
                          
                  #Now make a choice what to do.  If there is only one name match
                  #we go up to the next step and then see if we can resolve.
                  
									#If there are alternatives, assume that one of them has to be
                  #correct
                  if(defined($treeData->{names2taxid}->{$taxName}->[$i])){
            				$taxid = $treeData->{names2taxid}->{$taxName}->[$i];
										$i++;
									}else{	
                  	if(scalar(@taxNames)){
                    	$taxName = pop(@taxNames);
                      next NAME;
                    }else{
                      $building=0; 
                  	}
                 	}
								}
         			}
            }else{
              $prefix = lc(substr($node->{rank},0,1));
              my $child = $node->{taxid};
              $taxidList .=';'.$child;
            }

            my $level = $node->{name};
            $level =~ s/\s/\_/g;
            $t->{$prefix} .= $level; 
          }
	        unless($found){
    		  if(scalar(@taxNames)){
      		  $taxName = pop(@taxNames);
        	  next NAME;
      	  }else{
        	  $building=0;
      	  }
			  }
      }
      print T "$its_taxid\t$taxidList\n";
		}	
  
    #Now construct the string of minimal lengths.
    my $string;
    foreach my $k (qw(sk k p c o f g s)){
      $string .= $t->{$k}.";";
    }
    $string =~ s/(\;)$//;
    push(@olines, "$its_taxid\t$string\n") if(defined($string));
    }  
  }
	close(T);
	write_file("uplift", @olines);
}

sub write_otu {
  my($olinesRef, $file) = @_;
  
  # read in file, add taxonomic string to hash (break to individual components)
  # dump hash and count to file

  my $tax_hash;
  foreach my $line (@$olinesRef){
    next if $line=~/^#/;
    chomp $line;
    my @fds=split (/\s+/, $line);
    my @sub_tax=split (/\;/, $fds[1]);
    my $taxString;
    while (scalar(@sub_tax)){
      $taxString .= ";" if($taxString);
	    $taxString .= shift(@sub_tax);
	    $tax_hash->{$taxString} = 1;
    }
  }

  
  my @otuFile;
  my $otu_count=0;
  foreach my $otu (keys %{$tax_hash}) {
    $otu_count++;
    push(@otuFile, "$otu_count\t$otu\n");
  }
  $otu_count++;
  push(@otuFile, "$otu_count\tUnclassified\n");
  
  write_file($file, @otuFile);
}
