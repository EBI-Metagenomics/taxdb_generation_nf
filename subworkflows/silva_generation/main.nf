
include { SILVA_REFORMAT } from '../../modules/silva_reformat/main.nf'
include { REMOVE_EMPTY_PHYLA } from '../../modules/remove_empty_phyla/main.nf'
include { MAKE_OTU_FILE } from '../../modules/make_otu_file/main.nf'
include { CLEAN_FASTA } from '../../modules/clean_fasta/main.nf'
include { GENERATE_MSCLUSTER } from '../../modules/generate_mscluster/main.nf'

workflow SILVA_GENERATION {

    take:
        subunit
        silva_taxdump
        download_fasta
        label
    main:

        dummy_fasta = file(params.dummy_fasta, checkIfExists: true)
        silva_fasta = file(download_fasta, checkIfExists: true)

        SILVA_REFORMAT(
            silva_fasta,
            silva_taxdump,
            subunit,
            params.silva_version,
            label
        )

        REMOVE_EMPTY_PHYLA(
            SILVA_REFORMAT.out.uplift,
            params.silva_version,
            label
        )

        MAKE_OTU_FILE(
            REMOVE_EMPTY_PHYLA.out.tax,
            SILVA_REFORMAT.out.taxid,
            params.silva_version,
            label
        )

        CLEAN_FASTA(
            SILVA_REFORMAT.out.fasta,
            REMOVE_EMPTY_PHYLA.out.tax,
            params.silva_version,
            label
        )

        // GENERATE_MSCLUSTER(
        //     dummy_fasta,
        //     CLEAN_FASTA.out.cleaned_fasta,
        //     REMOVE_EMPTY_PHYLA.out.tax,
        //     params.silva_version,
        //     label
        // )

    emit:
        fasta = CLEAN_FASTA.out.cleaned_fasta
        tax = REMOVE_EMPTY_PHYLA.out.tax
        otu = MAKE_OTU_FILE.out.otu

}