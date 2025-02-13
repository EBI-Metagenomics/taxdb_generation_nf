
// nextflow run -resume -profile slurm main.nf

include { SILVA_GENERATION as SILVA_SSU_GENERATION } from '../subworkflows/silva_generation/main.nf'
include { SILVA_GENERATION as SILVA_LSU_GENERATION } from '../subworkflows/silva_generation/main.nf'
include { PR2_GENERATION                           } from "../subworkflows/pr2_generation/main.nf"
include { UNITE_GENERATION                         } from "../subworkflows/unite_generation/main.nf"
include { ITSONEBD_GENERATION                      } from "../subworkflows/itsonedb_generation/main.nf"
include { RFAM_GENERATION                          } from "../subworkflows/rfam_generation/main.nf"
include { RHEA_AND_TAXONOMY_GENERATION             } from "../subworkflows/rhea_and_taxonomy_generation/main.nf"

include { METADATA_LOG } from '../modules/local/metadata_log/main.nf'

workflow TAXDB_GENERATION_PIPELINE_V6 {
    if (params.generate_amplicon_db) {
        silva_taxdump = file(params.silva_download_taxdump, checkIfExists: true)

        SILVA_SSU_GENERATION(
            "SSU",
            silva_taxdump,
            params.silva_ssu_download_fasta,
            params.silva_ssu_label
        )

        SILVA_LSU_GENERATION(
            "LSU",
            silva_taxdump,
            params.silva_lsu_download_fasta,
            params.silva_lsu_label
        )
        
        PR2_GENERATION()

        UNITE_GENERATION()

        ITSONEBD_GENERATION()

        RFAM_GENERATION()

        METADATA_LOG()    
    }
    
    if (params.generate_uniref90_db) {
        RHEA_AND_TAXONOMY_GENERATION(      
            file(params.uniref90_fasta_link),
            file(params.uniprot_rhea_mapping),
            file(params.rhea_chebi_mapping_link),
            file(params.ncbi_taxdump_link)
        )
    }
}