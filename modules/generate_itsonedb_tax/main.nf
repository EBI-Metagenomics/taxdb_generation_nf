
process GENERATE_ITSONEDB_TAX {

    label 'light'

    input:
    path fasta
    path uplift
    val version
    val label

    output:
    path("*uplift.final.txt"), emit: uplift_final

    script:
    """
    generate_itsonedb_tax.py -f $fasta -u $uplift -o ./uplift.final.txt
    """

}