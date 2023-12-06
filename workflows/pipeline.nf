
// nextflow run -resume main.nf 
// nextflow run -resume -profile lsf main.nf 

include { SILVA_GENERATION as SILVA_SSU_GENERATION } from '../subworkflows/silva_generation.nf'
include { SILVA_GENERATION as SILVA_LSU_GENERATION } from '../subworkflows/silva_generation.nf'
include { PR2_GENERATION } from "../subworkflows/pr2_generation.nf"
include { ITSONEBD_GENERATION } from "../subworkflows/itsonedb_generation.nf"
include { RFAM_GENERATION } from "../subworkflows/rfam_generation.nf"

workflow TAXDB_GENERATION_PIPELINE_V6 {

    SILVA_SSU_GENERATION(
        "SSU"
    )

    SILVA_LSU_GENERATION(
        "LSU"
    )
    
    PR2_GENERATION()

    RFAM_GENERATION()

}