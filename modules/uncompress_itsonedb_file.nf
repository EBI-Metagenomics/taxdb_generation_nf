
process UNCOMPRESS_ITSONEDB_FILE {

    label 'light'

    input:
    path itsonedb_fasta
    val version
    val label

    output:
    path("*.fasta"), emit: fasta

    """
    gunzip -c -f $itsonedb_fasta > itsonedb.fasta
    """
}