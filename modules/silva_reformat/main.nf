
process SILVA_REFORMAT {

    label 'heavy'

    input:
    path fasta
    path taxdump
    val subunit
    val version
    val label

    output:
    path("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.clean"), emit: fasta
    path("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.uplift"), emit: uplift
    path("SILVA_${version}_${subunit}Ref_tax_silva_trunc.fasta.taxid"), emit: taxid

    """
    silva-reformat.pl -f $fasta -t $taxdump -v $version -s $subunit --out ./
    """

}