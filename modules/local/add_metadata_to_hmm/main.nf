process ADD_METADATA_TO_HMM {

    input:
    path ko_hmm_dir
    val ko_list

    output:
    path "kofam_modified.hmm", emit: kofam_modified

    script:
    def is_compressed = ko_hmm_dir.getExtension() == "gz" ? true : false
    def ko_hmm_input = is_compressed ? ko_hmm_dir.getName().replace(".tar.gz", "") : ko_hmm_dir

    """
    if [ "${is_compressed}" == "true" ]; then
        tar -xzf ${ko_hmm_dir}
    fi

    add_metadata_to_hmm.py ${ko_list} ${ko_hmm_input}

    cat *.modified.hmm > kofam_modified.hmm
    """
}