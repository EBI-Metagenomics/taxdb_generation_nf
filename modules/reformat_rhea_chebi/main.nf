process REFORMAT_RHEA_CHEBI {
    label 'light'
    container 'quay.io/biocontainers/python:3.10'

    input:
    path rhea_rheactions_gz

    output:
    path 'rhea_chebi_mapping_*.tsv', emit: tsv_rhea_chebi_mapping

    script:
    "reformat_rhea_chebi_mapping.py ${rhea_rheactions_gz} rhea_chebi_mapping_${params.rheadb_version}.tsv"
}