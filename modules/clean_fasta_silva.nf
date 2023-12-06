
process CLEAN_FASTA_SILVA {

    label 'light'
    container = '/hps/nobackup/rdf/metagenomics/service-team/singularity-cache/quay.io_biocontainers_seqtk:1.3.sif'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path fasta
    path tax
    val version
    val label

    output:
    path("${label}.fasta"), emit: cleaned_fasta

    """
    grep -v '^#' $tax | cut -f1 > ${label}.idlst
    seqtk subseq $fasta ${label}.idlst > ${label}.fasta
    """

}