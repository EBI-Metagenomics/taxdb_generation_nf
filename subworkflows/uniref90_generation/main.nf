include { UNIREF90_RHEA_FILTER                  } from '../../modules/uniref90_rhea_filter/main.nf'
include { UNIREF90_NON_VIRAL_FILTER             } from '../../modules/uniref90_non_viral_filter/main.nf'
include { REFORMAT_RHEA_CHEBI                   } from '../../modules/reformat_rhea_chebi/main.nf'
include { DIAMOND_MAKEDB as DIAMOND_MAKEDB_RHEA } from '../../modules/nf-core/diamond/makedb/main.nf'
include { DIAMOND_MAKEDB as DIAMOND_MAKEDB_TAXA } from '../../modules/nf-core/diamond/makedb/main.nf'

workflow UNIREF90_GENERATION {

    main:
        uniref90_fasta       = file(params.uniref90_download_fasta, checkIfExists: true)
        uniprot_rhea_mapping = file(params.uniprot_rhea_mapping, checkIfExists: true)
        rhea_chebi_mapping   = file(params.rhea_chebi_download_mapping, checkIfExists: true)

        UNIREF90_RHEA_FILTER(
            uniref90_fasta,
            uniprot_rhea_mapping
        )

        // UNIREF90_NON_VIRAL_FILTER(
        //     uniref90_fasta.splitFasta(by: 1000000, file: 'uniref90'),
        // )

        REFORMAT_RHEA_CHEBI(
            rhea_chebi_mapping
        )

        diamond_rhea_input = tuple(["id": params.uniref90_version], UNIREF90_RHEA_FILTER.out.filtered_fasta)
        DIAMOND_MAKEDB_RHEA(diamond_rhea_input, false, false, false)

        diamond_taxa_input = tuple(["id": params.uniref90_version], UNIREF90_NON_VIRAL_FILTER.out.filtered_fasta.collect())
        DIAMOND_MAKEDB_TAXA(diamond_taxa_input, false, false, false)

    emit:
        rhea_db            = DIAMOND_MAKEDB_RHEA.out.db
        taxonomy_db        = DIAMOND_MAKEDB_TAXA.out.db
        rhea_chebi_mapping = REFORMAT_RHEA_CHEBI.out.tsv_rhea_chebi_mapping
}
