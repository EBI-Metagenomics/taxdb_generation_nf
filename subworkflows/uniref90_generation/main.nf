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

        UNIREF90_RHEA_FILTER.out.filtered_fasta
            .map { filepath -> 
                [[id: params.uniref90_version], filepath]
            }
            .set { diamond_makedb_rhea_ch }
        DIAMOND_MAKEDB_RHEA(diamond_makedb_rhea_ch, [], [], [])

        uniref90_batches_ch = Channel.fromPath(uniref90_fasta).splitFasta(by: 1000000, file: 'uniref90')
        UNIREF90_NON_VIRAL_FILTER(
            uniref90_batches_ch,
        )

        UNIREF90_NON_VIRAL_FILTER.out.filtered_fasta
            .collectFile(name: 'uniref90_non_viral.fasta')
            .map { filepath ->
                [[id: params.uniref90_version], filepath]
            }
            .set { diamond_makedb_taxa_ch }
        DIAMOND_MAKEDB_TAXA(diamond_makedb_taxa_ch, [], [], [])

        REFORMAT_RHEA_CHEBI(
            rhea_chebi_mapping
        )

    emit:
        rhea_db            = DIAMOND_MAKEDB_RHEA.out.db
        taxonomy_db        = DIAMOND_MAKEDB_TAXA.out.db
        rhea_chebi_mapping = REFORMAT_RHEA_CHEBI.out.tsv_rhea_chebi_mapping
}
