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

include { SHEET_CHECK } from                 './subworkflows/local/sheet_check'
include { FOLDER_CHECK } from                './subworkflows/local/folder_check'
include { QC } from                          './subworkflows/local/qc'
include { REPORT } from                      './subworkflows/local/report'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/custom/dumpsoftwareversions/main'

workflow {
    
    ch_versions = Channel.empty()

    // SUBWORKFLOW: Read in folder/samplesheet, validate, and stage input files
    if (params.sheet) {
        SHEET_CHECK(file(params.sheet))
        reads = SHEET_CHECK.out.reads
        ch_versions = ch_versions.mix(SHEET_CHECK.out.versions)
    } else if (params.folder) {
        FOLDER_CHECK(Channel.fromPath(params.folder))
        reads = FOLDER_CHECK.out.reads
        ch_versions = ch_versions.mix(FOLDER_CHECK.out.versions)
    }

    // SUBWORKFLOW: Perform QC
    QC(reads)
    ch_versions = ch_versions.mix(QC.out.versions)

    // SUBWORKFLOW: Generate reports
    REPORT(QC.out.readStats, QC.out.qualityStats)
    ch_versions = ch_versions.mix(REPORT.out.versions)

    // SUBWORKFLOW: Get versioning
    CUSTOM_DUMPSOFTWAREVERSIONS (ch_versions.unique().collectFile(name: 'collated_versions.yml'))    
}