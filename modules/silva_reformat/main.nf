
process SILVA_REFORMAT {

    label 'heavy'

    input:
    path fasta
    path taxdump
    val subunit
    val version
    val label

    output:
    path("*.fasta.clean"), emit: fasta
    path("*.fasta.uplift"), emit: uplift
    path("*.fasta.taxid"), emit: taxid

    """
    silva-reformat.pl -f $fasta -t $taxdump -v $version -s $subunit --out ./
    """

}