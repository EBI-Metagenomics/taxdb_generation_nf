
include { SILVA_REFORMAT } from '../modules/silva_reformat.nf'
include { REMOVE_EMPTY_PHYLA } from '../modules/remove_empty_phyla.nf'
include { MAKE_OTU_FILE } from '../modules/make_otu_file.nf'
include { CLEAN_FASTA } from '../modules/clean_fasta.nf'
include { GENERATE_MSCLUSTER } from '../modules/generate_mscluster.nf'

workflow SILVA_GENERATION {

    take:
        subunit
        silva_version
        label
    main:

        dummy_fasta = file(params.dummy_fasta)

        SILVA_REFORMAT(
            subunit,
            silva_version,
            label
        )

        REMOVE_EMPTY_PHYLA(
            SILVA_REFORMAT.out.uplift,
            silva_version,
            label
        )

        MAKE_OTU_FILE(
            REMOVE_EMPTY_PHYLA.out.tax,
            SILVA_REFORMAT.out.taxid,
            silva_version,
            label
        )

        CLEAN_FASTA(
            SILVA_REFORMAT.out.fasta,
            REMOVE_EMPTY_PHYLA.out.tax,
            silva_version,
            label
        )

        // GENERATE_MSCLUSTER(
        //     dummy_fasta,
        //     CLEAN_FASTA.out.cleaned_fasta,
        //     REMOVE_EMPTY_PHYLA.out.tax,
        //     silva_version,
        //     label
        // )


}