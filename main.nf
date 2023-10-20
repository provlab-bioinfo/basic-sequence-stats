#!/usr/bin/env nextflow

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*\
|   basic-sequence-stats                                               |
|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
|   Github : https://github.com/provlab-bioinfo/basic-sequence-stats   |
 \*-------------------------------------------------------------------*/

nextflow.enable.dsl = 2
WorkflowMain.initialise(workflow, params, log)

if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.platform != 'illumina' || params.platform == 'nanopore') {exit 1, "Platform must be either 'illumina' or 'nanopore'!" }
if ((params.sheet == null && params.folder) == null || (params.sheet != null && params.folder != null)) {
    exit 1, "Must specify one of '--folder' or '--sheet'!"}

include { SHEET_CHECK } from                 '../subworkflows/local/input_check'
include { QC } from                          '../subworkflows/local/qc'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

workflow {
    
    ch_software_versions = Channel.empty()

    // SUBWORKFLOW: Read in folder/samplesheet, validate, and stage input files
    if (param.sheet) {
        reads = SHEET_CHECK (ch_input).out.reads
        ch_software_versions = ch_software_versions.mix(SHEET_CHECK.out.versions)
    } else if (param.folder) {
        reads = FOLDER_CHECK(ch_input).out.reads
        ch_software_versions = ch_software_versions.mix(FOLDER_CHECK.out.versions)
    }

    // SUBWORKFLOW: Perform QC
    QC(reads)
    ch_software_versions = ch_software_versions.mix(QC.out.versions)

   // SUBWORKFLOW: Get versioning
    CUSTOM_DUMPSOFTWAREVERSIONS (ch_software_versions.unique().collectFile(name: 'collated_versions.yml'))
}