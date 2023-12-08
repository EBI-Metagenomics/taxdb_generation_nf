
process GENERATE_ITSONEDB_TAX {

    label 'light'

    input:
    path fasta
    path uplift
    val version
    val label

    output:
    path("*uplift_final.txt"), emit: uplift_final

    """
    python /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/bin/generate_itsonedb_tax.py -f $fasta -u $uplift -o ./uplift.final.txt
    """

}