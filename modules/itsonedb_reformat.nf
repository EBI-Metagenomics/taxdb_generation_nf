
process ITSONEDB_REFORMAT {

    label 'heavy'

    input:
    path tax_lineage
    val version
    val label

    output:
    path("uplift"), emit: uplift
    path("itsonedb.taxid"), emit: taxid

    """
    perl /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/old_scripts_taxdb/format_ITSone_for_mapseq.pl -i $tax_lineage  --out ./
    """

}