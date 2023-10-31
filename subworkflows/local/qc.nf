include { SEQKIT_STATS as SEQKIT_STATS_QC } from '../../modules/nf-core/seqkit/stats/main'
include { FASTQC as FASTQC_QC } from             '../../modules/nf-core/fastqc/main'
include { NANOPLOT as NANOPLOT_QC } from         '../../modules/nf-core/nanoplot/main'

workflow QC {   
    take:
        illumina
        nanopore
    main:

        versions = Channel.empty()

        // SUBWORKFLOW: Do read statistics
        reads = illumina.join(nanopore).map{ meta, illumina, nanopore -> [ meta, illumina + [nanopore] ] }
        SEQKIT_STATS_QC(reads).stats.set { readStats }  
        versions = versions.mix(SEQKIT_STATS_QC.out.versions)      

        // SUBWORKFLOW: Do reads quality checks
        FASTQC_QC(illumina).zip.set { illuminaQuality }
        versions = versions.mix(FASTQC_QC.out.versions)

        NANOPLOT_QC(nanopore).txt.set { nanoporeQuality }
        versions = versions.mix(NANOPLOT_QC.out.versions)
        
    emit:
        readStats
        illuminaQuality
        nanoporeQuality
        versions
}

