
include { UNCOMPRESS_FILE } from '../../modules/local/uncompress_file/main.nf'
include { EXTRACT_RFAM_SUBSET } from '../../modules/local/extract_rfam_subset/main.nf'

workflow RFAM_GENERATION {

    main:

        rfam_claninfo = file(params.rfam_claninfo, checkIfExists: true)
        rfam_cm = file(params.rfam_download_cm, checkIfExists: true)

        UNCOMPRESS_FILE(
            rfam_cm,
            "full_ribo.cm"
        )

        EXTRACT_RFAM_SUBSET(
            UNCOMPRESS_FILE.out.uncmp_file,
            rfam_claninfo,
            params.rfam_version,
            params.rfam_label
        )

    emit:
        ribo_cm = EXTRACT_RFAM_SUBSET.out.ribo_cm
        ribo_claninfo = EXTRACT_RFAM_SUBSET.out.ribo_claninfo
}