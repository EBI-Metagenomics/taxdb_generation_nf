
process UNCOMPRESS_UNITE_FILE {

    label 'light'

    input:
    path unite_fasta
    val version
    val label

    output:
    path("*.fasta"), emit: fasta

    """
    gunzip -c -f $unite_fasta > unite.fasta
    """
}