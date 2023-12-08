
process CLEAN_FASTA_ITSONEDB {

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
    # Clean fasta headers
    sed "s/|ITS1 located by ENA annotation,.*//g" $fasta > ${fasta}.clean
    grep -v '^#' $tax | cut -f1 > ${label}.idlst
    seqtk subseq ${fasta}.clean ${label}.idlst > ${label}.fasta
    """

}