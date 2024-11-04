process REFORMAT_RHEA_CHEBI_FILE {
    label 'light'

    input:
    rhea_rheactions_gz

    output:
    rhea_chebi_mapping

    "python3 reformat_rhea_chebi_mapping.py $rhea_rheactions_gz"
}