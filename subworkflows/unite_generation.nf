
include { UNCOMPRESS_FILE } from '../modules/uncompress_file.nf'
include { GENERATE_UNITE_TAX } from '../modules/generate_unite_tax.nf'
include { CLEAN_FASTA_UNITE } from '../modules/clean_fasta_unite.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file/main.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster/main.nf'

workflow UNITE_GENERATION {

    main:

        dummy_fasta = file(params.dummy_fasta)
        unite_fasta = file(params.unite_download_fasta)

        UNCOMPRESS_FILE(
            unite_fasta,
            "unite.fasta"
        )

        GENERATE_UNITE_TAX(
            UNCOMPRESS_FILE.out.uncmp_file,
            params.unite_tax_header,
            params.unite_version,
            params.unite_label
        )

        CLEAN_FASTA_UNITE(
            UNCOMPRESS_FILE.out.uncmp_file,
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
        //     CLEAN_FASTA_UNITE.out.cleaned_fasta,
        //     GENERATE_UNITE_TAX.out.tax,
        //     params.unite_version,
        //     params.unite_label
        // )

}