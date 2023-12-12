
process UNCOMPRESS_FILE {

    label 'light'

    input:
    path cmp_file
    val uncmp_name

    output:
    path("${uncmp_name}"), emit: uncmp_file

    """
    gunzip -c -f $cmp_file > $uncmp_name
    """
}