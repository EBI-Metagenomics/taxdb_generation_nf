include { ADD_METADATA_TO_HMM } from '../../modules/local/add_metadata_to_hmm/main.nf'
include { CAT_CAT             } from '../../modules/nf-core/cat/cat/main.nf'
include { HMMER_HMMPRESS      } from '../../modules/local/hmmer/hmmpress/main.nf'

workflow KOFAM_GENERATION {
    take:
    ko_hmm_dir
    ko_list

    main:
    ADD_METADATA_TO_HMM(ko_hmm_dir, ko_list)
    CAT_CAT(ADD_METADATA_TO_HMM.out.modified_ko_hmm.flatten())
    HMMER_HMMPRESS(ADD_METADATA_TO_HMM.out.modified_ko_hmm)

    emit:
    kofam_db = HMMER_HMMPRESS.out.compressed_db
}