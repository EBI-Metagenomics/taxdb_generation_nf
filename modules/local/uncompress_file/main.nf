
process UNCOMPRESS_FILE {

    label 'process_single'

    input:
    path cmp_file
    val uncmp_name

    output:
    path("${uncmp_name}"), emit: uncmp_file

    script:
    """
    gunzip -c -f $cmp_file > $uncmp_name
    """
}