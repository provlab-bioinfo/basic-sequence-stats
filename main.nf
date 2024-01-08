#!/usr/bin/env nextflow

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|   basic-sequence-stats                                               |
|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
|   Github : https://github.com/provlab-bioinfo/basic-sequence-stats   |
 \*-------------------------------------------------------------------*/

nextflow.enable.dsl = 2
WorkflowMain.initialise(workflow, params, log)

// if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
// if (params.platform != 'illumina' || params.platform == 'nanopore') {exit 1, "Platform must be either 'illumina' or 'nanopore'!" }
// if ((params.sheet == null && params.folder) == null || (params.sheet != null && params.folder != null)) {
//     exit 1, "Must specify one of '--folder' or '--sheet'!"}

include { LOAD_SHEET } from                  './subworkflows/local/load_sheet'
include { STATS } from                          './subworkflows/local/stats'
include { REPORT } from                      './subworkflows/local/report'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/custom/dumpsoftwareversions/main'

workflow {
    
    ch_versions = Channel.empty()

    // SUBWORKFLOW: Read in samplesheet
    LOAD_SHEET(file(params.sheet))

    // SUBWORKFLOW: Perform QC
    STATS(LOAD_SHEET.out.illumina, LOAD_SHEET.out.nanopore)
    ch_versions = ch_versions.mix(STATS.out.versions)

    // SUBWORKFLOW: Generate reports
    REPORT(STATS.out.readStats, STATS.out.illuminaQuality, STATS.out.nanoporeQuality)
    ch_versions = ch_versions.mix(REPORT.out.versions)

    // SUBWORKFLOW: Get versioning
    CUSTOM_DUMPSOFTWAREVERSIONS (ch_versions.unique().collectFile(name: 'collated_versions.yml'))    

    emit:
        reads = LOAD_SHEET.out.reads
        versions = ch_versions
}