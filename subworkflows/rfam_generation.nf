
include { UNCOMPRESS_FILE } from '../modules/uncompress_file/main.nf'
include { EXTRACT_RFAM_SUBSET } from '../modules/extract_rfam_subset.nf'

workflow RFAM_GENERATION {

    main:

        rfam_cm = file(params.rfam_download_cm)
        rfam_claninfo = file(params.rfam_claninfo)

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

}