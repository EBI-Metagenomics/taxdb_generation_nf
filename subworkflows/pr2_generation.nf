
include { UNCOMPRESS_FILE as UNCOMPRESS_FASTA} from '../modules/uncompress_file.nf'
include { UNCOMPRESS_FILE as UNCOMPRESS_TAX} from '../modules/uncompress_file/main.nf'
include { PR2_PROCESS_TAX } from '../modules/pr2_process_tax.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file/main.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster/main.nf'

workflow PR2_GENERATION {

    main:

        dummy_fasta = file(params.dummy_fasta)
        pr2_fasta = file(params.pr2_download_fasta)
        pr2_tax = file(params.pr2_download_tax)

        UNCOMPRESS_FASTA(
            pr2_fasta,
            "PR2.fasta"
        )

        UNCOMPRESS_TAX(
            pr2_tax,
            "PR2.tax"
        )

        PR2_PROCESS_TAX(
            UNCOMPRESS_TAX.out.uncmp_file,
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
        //     UNCOMPRESS_FASTA.out.uncmp_file,
        //     PR2_PROCESS_TAX.out.tax,
        //     params.pr2_version,
        //     params.pr2_label
        // )

}