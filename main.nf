#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { TAXDB_GENERATION_PIPELINE_V6 } from './workflows/pipeline.nf'

workflow {
    TAXDB_GENERATION_PIPELINE_V6()
}