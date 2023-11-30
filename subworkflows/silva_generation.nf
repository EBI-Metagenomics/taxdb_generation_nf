
include { SILVA_REFORMAT } from '../modules/silva_reformat.nf'

workflow SILVA_GENERATION {

    take:
        silva_version
        subunit
    main:

        SILVA_REFORMAT(
            silva_version,
            subunit
        )

}