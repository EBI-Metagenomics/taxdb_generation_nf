process HMMER_HMMPRESS {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/07/07c4cbd91c4459dc86b13b5cd799cacba96b27d66c276485550d299c7a4c6f8a/data' :
        'community.wave.seqera.io/library/hmmer:3.4--cb5d2dd2e85974ca' }"

    input:
    tuple val(meta), path(hmmfile)

    output:
    tuple val(meta), path("*.h3?"), emit: compressed_db
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ''

    """
    hmmpress \\
        $args \\
        ${hmmfile}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hmmer: \$(echo \$(hmmpress -h | grep HMMER | sed 's/# HMMER //' | sed 's/ .*//' 2>&1))
    END_VERSIONS
    """

    stub:
    def prefix    = task.ext.prefix ?: "stub"

    """
    touch ${prefix}.h3m
    touch ${prefix}.h3i
    touch ${prefix}.h3f
    touch ${prefix}.h3p

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hmmer: \$(echo \$(hmmbuild -h | grep HMMER | sed 's/# HMMER //' | sed 's/ .*//' 2>&1))
    END_VERSIONS
    """
}
