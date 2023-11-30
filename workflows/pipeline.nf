
include { SILVA_GENERATION as SILVA_SSU_GENERATION } from '../subworkflows/silva_generation.nf'

workflow TAXDB_GENERATION_PIPELINE_V6 {

        SILVA_SSU_GENERATION(
            params.silva_version,
            "SSU"        )
    

}