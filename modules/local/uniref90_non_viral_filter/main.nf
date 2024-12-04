process UNIREF90_NON_VIRAL_FILTER {
    label 'process_single'
    container 'community.wave.seqera.io/library/biopython_pip_taxoniq:61a7ad516ddf4b95'

    input:
    path uniref90_fasta

    output:
    path 'uniref90_non_viral.fasta', emit: filtered_fasta

    script:
    """
    uniref90_non_viral_filter.py ${uniref90_fasta} uniref90_non_viral.fasta
    """
}