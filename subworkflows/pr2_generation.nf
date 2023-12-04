
include { UNCOMPRESS_PR2_FILES } from '../modules/uncompress_pr2_files.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster.nf'
include { PR2_PROCESS_TAX } from '../modules/pr2_process_tax.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file.nf'

workflow PR2_GENERATION {

    take:
        pr2_version
        label
    main:

        dummy_fasta = file(params.dummy_fasta)
        pr2_fasta = file(params.pr2_download_fasta)
        pr2_tax = file(params.pr2_download_tax)

        UNCOMPRESS_PR2_FILES(
            pr2_fasta,
            pr2_tax,
            pr2_version,
            label
        )

        PR2_PROCESS_TAX(
            UNCOMPRESS_PR2_FILES.out.tax,
            params.pr2_tax_header,
            pr2_version,
            label
        )

        MAKE_OTU_FILE(
            PR2_PROCESS_TAX.out.tax,
            params.empty_file,
            pr2_version,
            label
        )

        // GENERATE_MSCLUSTER(
        //     dummy_fasta,
        //     UNCOMPRESS_PR2_FILES.out.fasta,
        //     PR2_PROCESS_TAX.out.tax,
        //     pr2_version,
        //     label
        // )

}