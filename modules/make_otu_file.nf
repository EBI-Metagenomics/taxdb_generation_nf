
process MAKE_OTU_FILE {

    label 'light'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path uplift
    path taxid
    val version
    val label

    output:
    path("*.otu"), emit: otu

    """
    python /hps/software/users/rdf/metagenomics/service-team/users/chrisata/scripts_taxdb_nf/bin/make_otu_file.py -u $uplift -t $taxid -l $label
    """

}