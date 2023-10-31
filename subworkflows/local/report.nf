include { CSVTK_CONCAT as CSVTK_CONCAT_QC } from '../../modules/nf-core/csvtk/concat/main'
include { MULTIQC } from                         '../../modules/nf-core/multiqc/main'

ch_multiqc_config          = params.multiqc_config ?        Channel.fromPath(params.multiqc_config,        checkIfExists: true) : Channel.empty()
ch_multiqc_custom_config   = params.multiqc_custom_config ? Channel.fromPath(params.multiqc_custom_config, checkIfExists: true) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo ?          Channel.fromPath(params.multiqc_logo,          checkIfExists: true) : Channel.empty()

workflow REPORT {
    take:
        readStats
        illuminaQuality
        nanoporeQuality
    main:

        ch_versions = Channel.empty()

        // SUBWORKFLOW: Generate read stats report (seqkit)
        in_format = out_format = "tsv"  
        CSVTK_CONCAT_QC(readStats.map { cfg, stats -> stats }.collect().map { 
            file -> tuple([id: params.label+".seqkit"], file)
        }, in_format, out_format )
        ch_versions = ch_versions.mix(CSVTK_CONCAT_QC.out.versions)   

        // SUBWORKFLOW: Generate MultiQC report (Nanoplot and FastQC)
        ch_multiqc_illumina = illuminaQuality.map{ it.last() }.ifEmpty([]).flatten()
        ch_multiqc_nanopore = nanoporeQuality.map{ it.last() }.ifEmpty([]).flatten()
        ch_multiqc_files = ch_multiqc_illumina.mix(ch_multiqc_nanopore)

        MULTIQC(ch_multiqc_files.collect(), 
                ch_multiqc_config.toList(), 
                ch_multiqc_custom_config.toList(),
                ch_multiqc_logo.toList())

        ch_versions = ch_versions.mix(MULTIQC.out.versions)  

    emit:
        versions = ch_versions
}