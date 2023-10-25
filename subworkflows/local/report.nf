include { CSVTK_CONCAT as CSVTK_CONCAT_QC } from '../../modules/nf-core/csvtk/concat/main'
include { MULTIQC } from                         '../../modules/nf-core/multiqc/main'

ch_multiqc_config = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()

workflow REPORT {
    take:
        readStats
        qualityStats
    main:

        ch_versions = Channel.empty()

        // SUBWORKFLOW: Generate read stats report (seqkit)
        in_format = out_format = "tsv"  
        CSVTK_CONCAT_QC(readStats.map { cfg, stats -> stats }.collect().map { 
            file -> tuple([id: params.label+".seqkit"], file)
        }, in_format, out_format )
        ch_versions = ch_versions.mix(CSVTK_CONCAT_QC.out.versions.first())   

        // SUBWORKFLOW: Generate MultiQC report (Nanoplot and FastQC)
        ch_multiqc_files = qualityStats.map{ it.last() }.ifEmpty([]).flatten()

        MULTIQC(ch_multiqc_files.collect(), 
                ch_multiqc_config.toList(), 
                ch_multiqc_custom_config.toList(),
                ch_multiqc_logo.toList())

        ch_versions = ch_versions.mix(MULTIQC.out.versions.first())  

    emit:
        versions = ch_versions
}
    
    // workflow_summary    = WorkflowHgtseq.paramsSummaryMultiqc(workflow, summary_params)
    // ch_workflow_summary = Channel.value(workflow_summary)

    // methods_description    = WorkflowHgtseq.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    // ch_methods_description = Channel.value(methods_description)

    // ch_multiqc_files = Channel.empty()
    // ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    // // adding reads QC for both trimmed and untrimmed
    // if (!params.isbam) {
    //     ch_multiqc_files = ch_multiqc_files.mix(READS_QC.out.fastqc_untrimmed.collect{it[1]}.ifEmpty([]))
    //     ch_multiqc_files = ch_multiqc_files.mix(READS_QC.out.fastqc_trimmed.collect{it[1]}.ifEmpty([]))
    // }
 

    // MULTIQC (
    //     ch_multiqc_files.collect(),
    //     ch_multiqc_config.toList(),
    //     ch_multiqc_custom_config.toList(),
    //     ch_multiqc_logo.toList()
    // )
    // multiqc_report = MULTIQC.out.report.toList()
                    
    // emit:
    //     qc_reads
    //     qc_stats = SEQKIT_STATS_QC.out.stats
    //     versions = ch_versions

