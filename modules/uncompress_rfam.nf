
process UNCOMPRESS_RFAM {

    label 'light'

    input:
    path rfam_cm

    output:
    path("full_ribo.cm"), emit: full_ribo

    """
    gunzip -c -f $rfam_cm > full_ribo.cm
    """
}