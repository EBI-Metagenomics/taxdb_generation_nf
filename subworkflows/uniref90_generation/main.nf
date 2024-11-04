include { FILTER_VIRUSES_UNIREF90 } from '../../modules/filter_viruses_uniref90/main.nf'
include { DIAMOND_MAKEDB          } from '../../modules/diamond_makedb/main.nf'

workflow UNIREF90_GENERATION {

    main:
        uniref90_fasta = file(params.uniref90_download_fasta, checkIfExists: true)

        FILTER_VIRUSES_UNIREF90(
            uniref90_fasta,
        )

        DIAMOND_MAKEDB(
            [ [id: 'uniref90_rhea'], [FILTER_VIRUSES_UNIREF90.out.filtered_uniref90_fasta]],
            [],
            [],
            []
        )
        
    emit:
        uniref90_db = DIAMOND_MAKEDB.out.db
}