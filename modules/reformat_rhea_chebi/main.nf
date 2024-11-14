process REFORMAT_RHEA_CHEBI {
    label 'light'
    container 'quay.io/biocontainers/python:3.10'

    input:
    val rhea_rheactions_gz

    output:
    path 'rhea_chebi_mapping_*.tsv', emit: tsv_rhea_chebi_mapping

    script:
    
    """
    wget ${rhea_rheactions_gz}

    reformat_rhea_chebi_mapping.py rhea-reactions.txt.gz rhea_chebi_mapping_${params.rheadb_version}.tsv
    """
}