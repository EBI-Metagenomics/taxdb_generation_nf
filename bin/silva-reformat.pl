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
use strict;
use warnings;
use DBI;
use File::Slurp;
use Getopt::Long;
use Digest::MD5 qw(md5_hex);
use JSON;
use LWP::Simple;
use Archive::Tar;
use Archive::Zip;
use DDP;

my ($outDir, $fasta, $taxdump, $force, $version, $help, $subunit, @files);


GetOptions( "out=s"               => \$outDir,
            "force=i"             => \$force,
			"s|subunit=s"         => \$subunit, #SSU or LSU
            "f=s"                => \$fasta,
            "t=s"                => \$taxdump,
            "h|help"              => \$help,
            "v|version=s"         => \$version  )  or die "Error with options, try $0 --help\n";

help() if($help);

$outDir = "." if(!$outDir);
@files = ($fasta);

my $taxmaps = fetchFiles($version, \@files); 
my $treeData = fetchNCBI($taxdump, $outDir, $force);
process_taxmap($taxmaps, $treeData);


#------------------------------------------------------------------------------
# subroutines ----------------------------------------------------------------- 
#------------------------------------------------------------------------------

# Get the taxonomy data from NCBI
sub fetchNCBI {
    my($taxdump, $outDir, $force) = @_;
    # print STDERR "Getting ncbi data\n";

    my $outDirTax = $outDir.'/taxonomy/';

  #Store the taxonomy file for future reference.
    unless ( -d $outDirTax ) {
    mkdir( $outDirTax )
        or die "Could not make the directory $outDirTax because: [$!]\n";
    }

    print "Extracting ncbi data\n";
    my $zip = Archive::Zip->new;
    $zip->read( $taxdump );
    if(!-e $outDirTax.'nodes.dmp' or $force){
	$zip->extractMember( 'nodes.dmp', $outDirTax .'nodes.dmp' );
    }
    if(!-e $outDirTax.'names.dmp' or $force){
	$zip->extractMember( 'names.dmp', $outDirTax.'names.dmp' );
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

sub help {

    print <<'EOF_help';
    Usage: $0 
Build a database table of the taxonomic tree using the ncbi taxonomy files names.dmp and nodes.dmp
EOF_help

}

#-------------------------------------------------------------------------------


sub fetchFiles {
    my ($version, $files) = @_;
    my @taxmap;
    foreach my $f (@$files){
	$f =~ s/VERSION/$version/;
    #Going to be lazy and gunzip via system call.
	my $unzip = $f;
    $unzip =~ s/(\.gz)$//;
	system("gunzip -c $f > $unzip") and die "Failed to unzip $f:$!\n";
	push(@taxmap, $unzip);

    }
    return(\@taxmap);
}

sub process_taxmap {
    my($taxmaps, $treeData) = @_;
    foreach my $file (@$taxmaps){
	print "$file\n";
	open(F, "<", $file) or die "Could not open $file:\n";
	open(FC, ">", "$file.clean") or die "Could not open $file.clean:\n";
	open(T, ">", "$file.taxid") or die "Could not open $file.taxid;\n";
	my @olines;


    #Add in the standard lines to uplift file
    my $header = "#cutoff: 0.00:0.08 0.00:0.08 0.70:0.35 0.70:0.35 0.70:0.35 0.80:0.25 0.92:0.08 0.95:0.05
#name: SILVA
#levels: Superkingdom Kingdom Phylum Class Order Family Genus Species\n";
	push(@olines, $header);


	TAXID:
	while(my $line = <F>){
	    my $taxid=0;
	    my @taxNames;
	    my $taxName;
	    my $taxidStore;
      #Split to sequence and tax string.
      #>JHRO01000071.19003.20524 Bacteria;Proteobacteria;Gammaproteobacteria;Enterobacteriales;Enterobacteriaceae;Escherichia-Shigella;Escherichia coli
	    if($line =~ /^\>(\S+)\s+(.*)/){
		my $nse = $1; 
		my $taxonomy = $2;
		print FC ">$nse\n";
		my $t;

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
        
		$taxidStore = '-';
        
        #Chlroplasts and Mitochondria need to be dealt with differently
		if($taxonomy =~ /;(Chloroplast|Mitochondria);/){
    my $organelle = $1;
    @taxNames= split(/\;/, "$taxonomy");
    $taxName = pop(@taxNames); 
    $t->{sk} = "sk__".$organelle;
    $taxName =~ s/\s/_/g;
    $t->{s}  = "s__".$taxName;
		}else{

          #Deal with two cases of SAR11 being missed.
		            $taxonomy =~ s/(SAR11 clade.*(unidentified|uncultured){1}.*)/Pelagibacterales/;
    $taxonomy =~ s/SAR11 clade/Pelagibacterales/;

          #Deal with things labelled at the terminal nodes as essentially unknown.
    $taxonomy =~ s/;(uncultured (\w\s)*|unidentified)$//i;

          #Now deal with anything labelled as a metagenome        
    $t =~ s/;(\w|\s)*metagenome$//i;

 
			    @taxNames= split(/\;/, "$taxonomy");
			    $taxName = pop(@taxNames);
          
			    my $building = 1;
			    NAME:
			    while($building){
            #print STDERR "building 1\n"; 
        # We may have a taxid, or still trying to get an anchor
        # on to the database.
				           
				my $skip = 0;
				my $found = 0;
				my $taxidList;

				$skip = 1 if($taxName =~ /uncultured|unidentified|metagenome|synthetic|phage|Incertae/i);
            #$taxName =~ s/\S+__//g;
    
				if($skip == 0){
              #print STDERR "Looking up $taxName\n";
				    if($treeData->{names2taxid}->{$taxName} and scalar(@{ $treeData->{names2taxid}->{$taxName} }) < 3){
					$found=1;

          
					my $checksk = 1;
              #need to handle multiple taxids with the same name.
              #if(scalar(@{ $treeData->{names2taxid}->{$taxName} }) == 2){
              #  $checksk = 1;
              #}
					NODE:        
					for (my $i = scalar( @{$treeData->{names2taxid}->{$taxName}}) - 1; $i >= 0; $i-- ){
					    $taxid = $treeData->{names2taxid}->{$taxName}->[$i];
					    $taxidStore= $taxid;
					    $taxidList = $taxid;
                #Okay, if we are here with a defined reference, check that
                #to see if the minimal field, second element in the array is set to true.
					    while($building){
                  #print STDERR "building 2\n"; 

						my $node = $treeData->{nodes}->[$taxid];
						$taxid = $treeData->{nodes}->[$taxid]->{parent};
						    #my $child = $node->{taxid};
						$building = 0 if($taxid ==1);
              
						if($ranks{$node->{rank}}){
                    #now determine the prefix that we want to use.
						    my $prefix = '';
						    if($node->{rank} eq 'superkingdom'){
							$prefix='sk';
							$taxidList .=';'.$node->{taxid};
							if($checksk and scalar(@taxNames)){
							    if($node->{name} ne $taxNames[0]){
                          #The superkingdoms do not match, therefore rest.  
								foreach my $k (qw(sk k p c o f g s)){
								    $t->{$k} = $k."__";
								}
								$taxidStore = '-';
								$building = 1;
                          #Now make a choice what to do.  If there is only one name match
                          #we go up to the next step and then see if we can resolve.
                          #If there are two alternatives, assume that one of them has to be
                          #correct and we will take that one instead.
								if(scalar(@{ $treeData->{names2taxid}->{$taxName} }) == 1){
								    if(scalar(@taxNames)){
									$taxName = pop(@taxNames);
									next NAME;
								    }else{
									$building=0; 
								    }
								}else{
                            #print "$i next node\n";
								    next NODE;
								}
							    }else{
								$i--;
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
					    }
					}
				    }
				    print T "$nse\t$taxidList\n";
				}
				unless($found){
            #warn "Error with $taxName, not found\n";
				    if(scalar(@taxNames)){
					$taxName = pop(@taxNames);
					next NAME;
				    }else{
					$building=0;
				    }
				}
			    }
		}

		my $string;
		foreach my $k (qw(sk k p c o f g s)){
		    $string .= $t->{$k}.";";
		}
		$string =~ s/(\;)$//;
		push(@olines, "$nse\t$string\n") if($string !~ /;p__;c__;o__;/);
	    }else{
		print FC $line;
	    }
	}
	close(F);
	close(FC);
	close(T);
	write_file($file.".uplift", @olines);
	write_otu(\@olines, $file.".uplift.otu");
    }
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