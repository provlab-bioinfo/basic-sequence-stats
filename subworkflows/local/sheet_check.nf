//
// Check input samplesheet and get read channels
//

include { SAMPLESHEETCHECK } from '../../modules/local/samplesheetcheck'

workflow SHEET_CHECK {
    take:
        samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEETCHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_read_channels(it) }
        .set { reads }

    reads.map { 
        meta, illuminaFQ, nanoporeFQ -> [ meta, illuminaFQ ] }
        .filter{ meta, illuminaFQ -> illuminaFQ[0] != 'NA' && illuminaFQ[1] != 'NA' }
        .set { illumina }
    
    reads.map {
        meta, reads, nanoporeFQ -> [ meta, nanoporeFQ ] }
        .filter{ meta, nanoporeFQ -> nanoporeFQ != 'NA' }
        .set { nanopore }

    reads
        .map { meta, illuminaFQ, nanoporeFQ -> meta.id }
        .set {ids}

    emit:
    reads      // channel: [ val(meta), [ illumina ], nanopore ]
    illumina   // channel: [ val(meta), [ illumina ] ]
    nanopore   // channel: [ val(meta), nanopore ]
    ids
    versions = SAMPLESHEETCHECK.out.versions // channel: [ versions.yml ]
}
// Function to get list of [ meta, [ illuminaFQ_1, illuminaFQ_2 ], nanoporeFQ ]
def create_read_channels(LinkedHashMap row) {
    
    def meta = [:]
    meta.id           = row.sample
    meta.single_end   = !(row.illuminaFQ_1 == 'NA') && !(row.illuminaFQ_2 == 'NA') ? false : true
    meta.basecaller_mode = row.basecaller_mode == null ? 'NA' : row.basecaller_mode
    meta.genome_size  = row.genomesize == null ? 'NA' : row.genomesize
    
    if( !(row.illuminaFQ_1 == 'NA') )
    def array = []
    // check short reads
    if ( !(row.illuminaFQ_1 == 'NA') ) {
        if ( !file(row.illuminaFQ_1).exists() ) {
            exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.illuminaFQ_1}"
        }
        
        if(file(row.illuminaFQ_1).size() == 0){
            exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file is empty!\n${row.illuminaFQ_1}" 
        }
        
        illuminaFQ_1 = file(row.illuminaFQ_1)
    } else { illuminaFQ_1 = 'NA' }
    if ( !(row.illuminaFQ_2 == 'NA') ) {
        if ( !file(row.illuminaFQ_2).exists() ) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.illuminaFQ_2}"
        }
        
        if(file(row.illuminaFQ_2).size() == 0){
            exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file is empty!\n${row.illuminaFQ_2}" 
        }
        illuminaFQ_2 = file(row.fasilluminaFQ_2tq_2)
    } else { illuminaFQ_2 = 'NA' }

    // check nanoporeFQ
    if ( !(row.nanoporeFQ == 'NA') ) {
        if ( !file(row.nanoporeFQ).exists() ) {
            exit 1, "ERROR: Please check input samplesheet -> Long FastQ file does not exist!\n${row.nanoporeFQ}"
        }
        
        if(file(row.nanoporeFQ).size() == 0){
            exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file is empty!\n${row.nanoporeFQ}" 
        }
        nanoporeFQ = file(row.nanoporeFQ)
    } else { nanoporeFQ = 'NA' }
    
    // prepare output 
    if ( meta.single_end ) {
        array = [ meta, illuminaFQ_1 , nanoporeFQ]
    } else {
        array = [ meta, [ illuminaFQ_1, illuminaFQ_2 ], nanoporeFQ ]
    } 
    return array 
}

// Function to get list of [ meta, [ illuminaFQ_1, illuminaFQ_2 ] ]
def create_fastq_channel_org(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample
    meta.single_end = row.single_end.toBoolean()

    // add path(s) of the fastq file(s) to the meta map
    def fastq_meta = []
    if (!file(row.illuminaFQ_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.illuminaFQ_1}"
    }
    if (meta.single_end) {
        fastq_meta = [ meta, [ file(row.illuminaFQ_1) ] ]
    } else {
        if (!file(row.illuminaFQ_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.illuminaFQ_2}"
        }
        fastq_meta = [ meta, [ file(row.illuminaFQ_1), file(row.illuminaFQ_2) ] ]
    }
    return fastq_meta
}
