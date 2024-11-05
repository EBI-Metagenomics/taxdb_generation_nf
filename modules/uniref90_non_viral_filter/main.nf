process UNIREF90_NON_VIRAL_FILTER {
    label ''

    input:
    uniref90_fasta

    output:
    filtered_fasta

    "unifer90_non_viral_filter.py $uniref90_fasta"
}