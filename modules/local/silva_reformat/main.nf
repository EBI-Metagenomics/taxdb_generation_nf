
process SILVA_REFORMAT {

    label 'process_low'

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

    script:
    """
    silva-reformat.pl -f $fasta -t $taxdump -v $version -s $subunit --out ./
    """

}