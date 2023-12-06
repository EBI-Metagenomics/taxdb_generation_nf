
include { UNCOMPRESS_PR2_FILES } from '../modules/uncompress_pr2_files.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster.nf'
include { PR2_PROCESS_TAX } from '../modules/pr2_process_tax.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file.nf'

workflow PR2_GENERATION {

    main:

        dummy_fasta = file(params.dummy_fasta)
        pr2_fasta = file(params.pr2_download_fasta)
        pr2_tax = file(params.pr2_download_tax)

        UNCOMPRESS_PR2_FILES(
            pr2_fasta,
            pr2_tax,
            params.pr2_version,
            params.pr2_label
        )

        PR2_PROCESS_TAX(
            UNCOMPRESS_PR2_FILES.out.tax,
            params.pr2_tax_header,
            params.pr2_version,
            params.pr2_label
        )

        MAKE_OTU_FILE(
            PR2_PROCESS_TAX.out.tax,
            params.empty_file,
            params.pr2_version,
            params.pr2_label
        )

        // GENERATE_MSCLUSTER(
        //     dummy_fasta,
        //     UNCOMPRESS_PR2_FILES.out.fasta,
        //     PR2_PROCESS_TAX.out.tax,
        //     params.pr2_version,
        //     params.pr2_label
        // )

}