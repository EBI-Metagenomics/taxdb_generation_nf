process FILTER_UNIREF90 {
    label ''

    input:
    uniref90_fasta

    output:
    uniref90_rhea_fasta

    "python3 filter_unifer90.py $uniref90_fasta"
}