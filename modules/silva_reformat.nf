
process SILVA_REFORMAT {

    label 'light'
    
    input:
    val version
    val subunit

    output:
    path ("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.uplift"), emit: uplift

    """
    perl /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/bin/silva-reformat.pl -v $version -s $subunit --out ./
    """

}