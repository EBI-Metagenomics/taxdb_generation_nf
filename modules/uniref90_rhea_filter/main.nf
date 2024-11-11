process UNIREF90_RHEA_FILTER {
    label 'light'
    container 'quay.io/biocontainers/biopython:1.78'

    input:
    path uniref90_fasta
    path uniprot_rhea_mapping

    output:
    path 'uniref90_with_rhea.fasta', emit: filtered_fasta

    script:
    "uniref90_rhea_filter.py ${uniref90_fasta} ${uniprot_rhea_mapping} uniref90_with_rhea.fasta"
}