
process GENERATE_MSCLUSTER {

    label 'light'
    container = '/hps/nobackup/rdf/metagenomics/service-team/singularity-cache/quay.io-biocontainers-mapseq-2.1.1--ha34dc8c_0.img'
    publishDir "${params.outdir}/${label}/${version}/", mode: 'copy'

    input:
    path dummy
    path fasta
    path tax
    val version
    val label

    output:
    path("*.mscluster"), emit: mscluster

    """
    mapseq -nthreads $task.cpus -tophits 80 -topotus 40 -outfmt simple $dummy $fasta $tax
    """

}