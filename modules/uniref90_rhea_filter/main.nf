process UNIREF90_RHEA_FILTER {
    label 'light'

    input:
    uniref90_fasta
    uniprot_rhea_mapping

    output:
    filtered_fasta

    "unifer90_rhea_filter.py ${uniref90_fasta} ${uniprot_rhea_mapping}"
}