
process ITSONEDB_REFORMAT {

    label 'process_low'

    input:
    path tax_lineage
    val version
    val label

    output:
    path("uplift"), emit: uplift
    path("itsonedb.taxid"), emit: taxid

    script:
    """
    format_ITSone_for_mapseq.pl -i $tax_lineage  --out ./
    """

}