
include { UNCOMPRESS_UNITE_FILE } from '../modules/uncompress_unite_file.nf'
include { GENERATE_UNITE_TAX } from '../modules/generate_unite_tax.nf'
include { CLEAN_FASTA_UNITE } from '../modules/clean_fasta_unite.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file.nf'

workflow UNITE_GENERATION {

    main:

        dummy_fasta = file(params.dummy_fasta)
        unite_fasta = file(params.unite_download_fasta)

        UNCOMPRESS_UNITE_FILE(
            unite_fasta,
            params.unite_version,
            params.unite_label
        )

        GENERATE_UNITE_TAX(
            UNCOMPRESS_UNITE_FILE.out.fasta,
            params.unite_tax_header,
            params.unite_version,
            params.unite_label
        )

        CLEAN_FASTA_UNITE(
            UNCOMPRESS_UNITE_FILE.out.fasta,
            GENERATE_UNITE_TAX.out.tax,
            params.unite_version,
            params.unite_label
        )

        MAKE_OTU_FILE(
            GENERATE_UNITE_TAX.out.tax,
            params.empty_file,
            params.unite_version,
            params.unite_label
        )

        // GENERATE_MSCLUSTER(
        //     dummy_fasta,
        //     UNCOMPRESS_UNITE_FILE.out.fasta,
        //     GENERATE_UNITE_TAX.out.tax,
        //     params.unite_version,
        //     params.unite_label
        // )

}