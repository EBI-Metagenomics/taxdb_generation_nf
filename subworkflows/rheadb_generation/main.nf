include { FILTER_UNIREF90     } from '../../modules/filter_uniref90/main.nf'
include { REFORMAT_RHEA_CHEBI } from '../../modules/reformat_rhea_chebi/main.nf'
include { DIAMOND_MAKEDB      } from '../../modules/diamond_makedb/main.nf'

workflow RHEADB_GENERATION {

    main:
        uniref90_fasta       = file(params.uniref90_download_fasta, checkIfExists: true)
        uniprot_rhea_mapping = file(params.uniprot_rhea_mapping, checkIfExists: true)
        rhea_chebi_mapping   = file(params.rhea_chebi_download_mapping, checkIfExists: true)

        FILTER_UNIREF90(
            uniref90_fasta,
            uniprot_rhea_mapping
        )

        REFORMAT_RHEA_CHEBI(
            rhea_chebi_mapping
        )

        DIAMOND_MAKEDB(
            [ [id: 'uniref90_rhea'], [FILTER_UNIREF90.out.filtered_uniref90_fasta]],
            [],
            [],
            []
        )

    emit:
        rhea_db            = DIAMOND_MAKEDB.out.db
        rhea_chebi_mapping = REFORMAT_RHEA_CHEBI.out.tsv_rhea_chebi_mapping
}