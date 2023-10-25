
include { FASTQC as FASTQC_QC } from             '../../modules/nf-core/fastqc/main'
include { SEQKIT_STATS as SEQKIT_STATS_QC } from '../../modules/nf-core/seqkit/stats/main'

workflow QC {   
    take:
        reads
    main:

        versions = Channel.empty()
 
        // SUBWORKFLOW: Do read statistics
        SEQKIT_STATS_QC(reads).stats.set { readStats }
        versions = versions.mix(SEQKIT_STATS_QC.out.versions.first())      

        // SUBWORKFLOW: Do reads quality checks
        if (params.platform == 'nanopore') {
            NANOPLOT_QC(reads).html.set { qualityStats }
            versions = versions.mix(NANOPLOT_QC.out.versions.first())
        } else if (params.platform == 'illumina') {
            FASTQC_QC(reads).zip.set { qualityStats }
            versions = versions.mix(FASTQC_QC.out.versions.first())
        }
                
    emit:
        readStats
        qualityStats
        versions
}

