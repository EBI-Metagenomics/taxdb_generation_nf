
process UNCOMPRESS_PR2_FILES {

    label 'light'
    publishDir "${params.outdir}/${label}/${version}/", pattern : "*.fasta", mode: 'copy'

    input:
    path pr2_fasta
    path pr2_tax
    val version
    val label

    output:
    path("*.fasta"), emit: fasta
    path("*.tax"), emit: tax

    """
    gunzip -c -f $pr2_fasta > PR2.fasta
    gunzip -f $pr2_tax
    """
}