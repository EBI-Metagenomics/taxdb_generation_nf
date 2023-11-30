
process SILVA_REFORMAT {

    label 'heavy'

    input:
    val subunit
    val version
    val label

    output:
    path("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.clean"), emit: fasta
    path("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.uplift"), emit: uplift
    path("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.taxid"), emit: taxid

    """
    perl /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/bin/silva-reformat.pl -v $version -s $subunit --out ./
    """

}