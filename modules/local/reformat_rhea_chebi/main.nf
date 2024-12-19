process REFORMAT_RHEA_CHEBI {
    label 'process_single'
    container 'quay.io/biocontainers/python:3.10'

    input:
    path txt_rhea_chebi_mapping 

    output:
    path 'rhea_chebi_mapping_*.tsv', emit: tsv_rhea_chebi_mapping
    path "versions.yml"            , emit: versions

    script:
    
    """
    reformat_rhea_chebi_mapping.py ${txt_rhea_chebi_mapping} rhea_chebi_mapping_${params.rheadb_version}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version 2>&1 | sed 's/Python //g')
        rhea_db: ${params.rheadb_version}
    END_VERSIONS
    """
}