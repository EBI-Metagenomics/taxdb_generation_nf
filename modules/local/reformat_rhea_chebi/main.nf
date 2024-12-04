process REFORMAT_RHEA_CHEBI {
    label 'light'
    container 'quay.io/biocontainers/python:3.10'

    output:
    path 'rhea_chebi_mapping_*.tsv', emit: tsv_rhea_chebi_mapping

    script:
    
    """
        # Check if params.rhea_chebi_download_mapping is a URL or a file
    if [[ "${params.rhea_chebi_download_mapping}" =~ ^https?:// ]]; then
        # If it's a URL, download the file
        wget ${params.rhea_chebi_download_mapping} -O rhea-reactions.txt.gz
    else
        # Otherwise, create a symbolic link in the current directory
        ln -s ${params.rhea_chebi_download_mapping} rhea-reactions.txt.gz
    fi

    reformat_rhea_chebi_mapping.py rhea-reactions.txt.gz rhea_chebi_mapping_${params.rheadb_version}.tsv
    """
}