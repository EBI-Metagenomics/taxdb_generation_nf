
process EXTRACT_RFAM_SUBSET {

    label 'process_single'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path rfam_cm
    path rfam_claninfo
    val version
    val label

    output:
    path("ribo.cm"), emit: ribo_cm
    path("ribo.clan_info"), includeInputs: true, emit: ribo_claninfo

    script:
    """
    extract_rfam_subset.py -ci $rfam_claninfo -cm $rfam_cm -o ./ribo.cm
    cp $rfam_claninfo ribo.clan_info
    # last step needed because the 'includeInputs' argument doesn't work with Synlinks. see:
    # https://github.com/nextflow-io/nextflow/issues/1551
    """

}