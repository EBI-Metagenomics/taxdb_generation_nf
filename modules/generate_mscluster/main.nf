
process GENERATE_MSCLUSTER {

    label 'mscluster'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mapseq:2.1.1a--h3ab3c3b_0':
        'biocontainers/mapseq:2.1.1a--h3ab3c3b_0' }"
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
    mapseq -nthreads $task.cpus -seed 12 -tophits 80 -topotus 40 -outfmt simple $dummy $fasta $tax
    """

}