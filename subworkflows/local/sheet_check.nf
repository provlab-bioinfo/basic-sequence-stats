//
// Check input samplesheet and get read channels
//

include { SAMPLESHEETCHECK } from '../../modules/local/samplesheetcheck'

workflow SHEET_CHECK {
    take:
        samplesheet // file: /path/to/samplesheet.csv

    main:
        SAMPLESHEETCHECK ( samplesheet ).csv.splitCsv ( header:true, sep:',' )        
            .map { create_read_channels(it) }
            .set { reads_channel }

        if (params.platform = "illumina") {
            reads_channel.map { meta, illuminaFQ, nanopore -> [ meta, illuminaFQ ] }
                .filter { meta, illuminaFQ -> illuminaFQ[0] != 'NA' && illuminaFQ[1] != 'NA' }
                .set { reads }
        }
        
        if (params.platform = "nanopore") {
            reads_channel.map {meta, illuminaFQ, nanopore -> [ meta, nanopore ] }
                .filter { meta, nanopore -> nanopore != 'NA' }
                .set { reads }
        }

        reads_channel.map { meta, illuminaFQ, nanopore -> meta.id }
            .set {ids}

    emit:
        reads      // channel: [ val(meta), ( [ illumina ] | nanopore ) ]
        ids
        versions = SAMPLESHEETCHECK.out.versions // channel: [ versions.yml ]
}
// Function to get list of [ meta, [ illumina1, illumina2 ], nanopore ]
def create_read_channels(LinkedHashMap row) {
    
    def meta = [:]
    meta.id           = row.sample
    meta.single_end   = !(row.illumina1 == 'NA') && !(row.illumina2 == 'NA') ? false : true

    illumina1 = checkRead(row.illumina1)
    illumina2 = checkRead(row.illumina2)
    nanopore  = checkRead(row.nanopore)
    
    def array = []
    if ( meta.single_end ) {
        illumina = row.illumina1 == 'NA' ? illumina2 : illumina1
        array = [ meta, [ illumina ], nanopore]
    } else {
        array = [ meta, [ illumina1, illumina2 ], nanopore ]
    } 
    return array 
}

def checkRead(String read) {
    if (read == 'NA') return 'NA'
    if (!file(read).exists())    exit 1, "ERROR: Please check input samplesheet -> FASTQ file does not exist!\n   ${read}"        
    if (file(read).size() == 0)  exit 1, "ERROR: Please check input samplesheet -> FASTQ file is empty!\n   ${read}"
    return file(read)
}