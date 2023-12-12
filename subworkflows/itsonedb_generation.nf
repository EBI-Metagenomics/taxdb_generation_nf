
include { UNCOMPRESS_FILE } from '../modules/uncompress_file.nf'
include { GET_TAX_LINEAGE } from '../modules/get_tax_lineage.nf'
include { ITSONEDB_REFORMAT } from '../modules/itsonedb_reformat.nf'
include { GENERATE_ITSONEDB_TAX } from '../modules/generate_itsonedb_tax.nf'
include { ITSONEDB_COLUMN_REPLACEMENT } from '../modules/itsonedb_column_replacement.nf'
include { CLEAN_FASTA_ITSONEDB } from '../modules/clean_fasta_itsonedb.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file/main.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster/main.nf'


workflow ITSONEBD_GENERATION {

    main:

        dummy_fasta = file(params.dummy_fasta)
        itsonedb_fasta = file(params.itsonedb_download_fasta)
        itsonedb_download_taxdump = file(params.itsonedb_download_taxdump)

        UNCOMPRESS_FILE(
            itsonedb_fasta,
            "itsonedb.fasta"
        )

        GET_TAX_LINEAGE(
            UNCOMPRESS_FILE.out.uncmp_file,
            itsonedb_download_taxdump,
            params.itsonedb_version,
            params.itsonedb_label
        )

        ITSONEDB_REFORMAT(
            GET_TAX_LINEAGE.out.tax_lineage,
            params.itsonedb_version,
            params.itsonedb_label
        )

        GENERATE_ITSONEDB_TAX(
            UNCOMPRESS_FILE.out.uncmp_file,
            ITSONEDB_REFORMAT.out.uplift,
            params.itsonedb_version,
            params.itsonedb_label
        )

        ITSONEDB_COLUMN_REPLACEMENT(
            GENERATE_ITSONEDB_TAX.out.uplift_final,
            ITSONEDB_REFORMAT.out.taxid,
            params.itsonedb_tax_header,
            params.itsonedb_version,
            params.itsonedb_label
        )

        CLEAN_FASTA_ITSONEDB(
            UNCOMPRESS_FILE.out.uncmp_file,
            ITSONEDB_COLUMN_REPLACEMENT.out.tax,
            params.itsonedb_version,
            params.itsonedb_label
        )

        MAKE_OTU_FILE(
            ITSONEDB_COLUMN_REPLACEMENT.out.tax,
            ITSONEDB_COLUMN_REPLACEMENT.out.taxid,
            params.itsonedb_version,
            params.itsonedb_label
        )

        // GENERATE_MSCLUSTER(
        //     dummy_fasta,
        //     CLEAN_FASTA_ITSONEDB.out.cleaned_fasta,
        //     ITSONEDB_COLUMN_REPLACEMENT.out.tax,
        //     params.itsonedb_version,
        //     params.itsonedb_label
        // )

}