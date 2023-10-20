
include {FASTQC as FASTQC_QC} from             '../../modules/nf-core/fastqc/main'
include {SEQKIT_STATS as SEQKIT_STATS_QC} from '../../modules/nf-core/seqkit/stats/main'
include {CSVTK_CONCAT as CSVTK_CONCAT_QC} from '../../modules/nf-core/csvtk/concat/main'

workflow QC {   
    take:
        reads
    main:
        ch_versions = Channel.empty()
        qc_reads = reads

        // SUBWORKFLOW: Do reads quality checks
        if (params.platform == 'nanopore') {
            NANOPLOT_QC(reads)        
            ch_versions = ch_versions.mix(NANOPLOT_QC.out.versions.first())
        } else if (params.platform == 'illumina') {
            FASTQC_QC(reads)
            ch_versions = ch_versions.mix(FASTQC_QC.out.versions.first())
        }

        // SUBWORKFLOW: Do read statistics
        SEQKIT_STATS_QC(reads)
        ch_versions = ch_versions.mix(SEQKIT_STATS_QC.out.versions.first())

        // SUBWORKFLOW: Concatenate statistics
        in_format = out_format = "tsv"
        label = params.label ? params.label + "_" : ""
        CSVTK_CONCAT_QC(SEQKIT_STATS_QC.out.stats.map { cfg, stats -> stats }.collect().map { 
            files -> tuple([id: params.platform +"_reads."+label+"_seqstats"], files)
        }, in_format, out_format )
        
    emit:
        qc_reads
        qc_stats = SEQKIT_STATS_QC.out.stats
        versions = ch_versions
}

