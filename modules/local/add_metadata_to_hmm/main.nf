process ADD_METADATA_TO_HMM {
    input:
    path ko_hmm_dir
    val ko_list

    output:
    path "*.hmm", emit: modified_ko_hmm

    script:
    """
    add_metadata_to_hmm.py ${ko_list} ${ko_hmm_dir}
    """
}