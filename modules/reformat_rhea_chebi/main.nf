process REFORMAT_RHEA_CHEBI {
    label 'light'
    container ''

    input:
    path rhea_rheactions_gz

    output:
    path 'rhea_chebi_mapping.tsv', emit: tsv_rhea_chebi_mapping

    "reformat_rhea_chebi_mapping.py ${rhea_rheactions_gz}"
}