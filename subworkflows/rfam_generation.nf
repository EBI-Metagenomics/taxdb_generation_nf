
include { UNCOMPRESS_RFAM } from '../modules/uncompress_rfam.nf'
include { EXTRACT_RFAM_SUBSET } from '../modules/extract_rfam_subset.nf'

workflow RFAM_GENERATION {

    main:

        rfam_cm = file(params.rfam_download_cm)
        rfam_claninfo = file(params.rfam_claninfo)

        UNCOMPRESS_RFAM(
            rfam_cm
        )

        EXTRACT_RFAM_SUBSET(
            UNCOMPRESS_RFAM.out.full_ribo,
            rfam_claninfo,
            params.rfam_version,
            params.rfam_label
        )

}