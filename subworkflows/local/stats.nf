include { SEQKIT_STATS }               from '../../modules/nf-core/seqkit/stats/main'
include { FASTQC as FASTQC_STATS }     from '../../modules/nf-core/fastqc/main'
include { NANOPLOT as NANOPLOT_STATS } from '../../modules/nf-core/nanoplot/main'

workflow STATS {   
    take:
        illumina
        nanopore

    main:
        versions = Channel.empty()

        // SUBWORKFLOW: Do read statistics
        reads = illumina.join(nanopore, remainder: true).map{ meta, illumina, nanopore -> [ meta, illumina + [nanopore] ] }.map{ meta, reads -> [meta, reads - null]}
        log.debug("Reads:")
        reads.view()
        log.debug("End Reads")
        SEQKIT_STATS(reads).stats.set { readStats }  
        versions = versions.mix(SEQKIT_STATS.out.versions)      

        // SUBWORKFLOW: Do reads quality checks
        FASTQC_STATS(illumina).zip.set { illuminaQuality }
        versions = versions.mix(FASTQC_STATS.out.versions)

        NANOPLOT_STATS(nanopore).txt.set { nanoporeQuality }
        versions = versions.mix(NANOPLOT_STATS.out.versions)
        
    emit:
        readStats
        illuminaQuality
        nanoporeQuality
        versions
}

