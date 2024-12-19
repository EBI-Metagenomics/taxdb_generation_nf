process UNIREF90_NON_VIRAL_FILTER {
    label 'process_single'
    container 'community.wave.seqera.io/library/biopython_pip_taxoniq:61a7ad516ddf4b95'

    input:
    path uniref90_fasta

    output:
    path 'uniref90_non_viral.fasta', emit: filtered_fasta
    path "versions.yml"            , emit: versions

    script:
    """
    uniref90_non_viral_filter.py ${uniref90_fasta} uniref90_non_viral.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        biopython: \$(python -c "import importlib.metadata; print(importlib.metadata.version('biopython'))")
        taxoniq: \$(python -c "import importlib.metadata; print(importlib.metadata.version('taxoniq'))")
        uniref90_db: ${params.uniref90_version}
    END_VERSIONS
    """
}