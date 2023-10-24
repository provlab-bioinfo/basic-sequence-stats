//
// Check input folder and find files in paths in params.illuminaSearchPath and params.nanoporeSearchPath
//

include { FOLDERCHECK } from '../../modules/local/foldercheck'

workflow FOLDER_CHECK {
    take:
        folder // file: /path/to/samplesheet.csv

    main:
        if (params.platform = 'illumina') {
            def grouping = { file -> file.name.lastIndexOf('_L001').with {it != -1 ? file.name[0..<it] : file.name} }
            Channel.fromFilePairs( params.illuminaSearchPath, flat: true, grouping)
                //    .toSortedList( { a, b ->
                //         def aparts = a[0].split("_S").collect { it as short }
                //         def bparts = b[0].split("_S").collect { it as short }
                //         (0).collect { aparts[it] <=> bparts[it] }.find() ?: 0
                //     } )
                //    .flatMap()
                   .map{ create_read_channels(it) } // it -> [it[0], it.tail()] }
                   .set{ reads }

        } else if (params.latform = 'nanopore') {
            def grouping = { file -> file.name.lastIndexOf('_').with {it != -1 ? file.name[0..<it] : file.name} }
            Channel.fromFilePairs( params.nanoporeSearchPath, flat: true , size: -1, grouping)
                  // .toSortedList( { a, b -> a[1] <=> b[1] } )
                   .map{ create_read_channels(it) } // it -> [(it[0] =~ /barcode\d{1,3}/)[0], it.tail()] }
                   .set{ reads }
        } else {
            exit 1, "Platform must be either 'illumina' or 'nanopore'!" 
        }

        log.debug "Got the reads"
        
        FOLDERCHECK(folder)

    emit:
        reads
        versions = FOLDERCHECK.out.versions

}

// Function to get list of [ meta, [ illumina1, illumina2 ], nanopore ]
def create_read_channels(List row) {
    
    def meta = [:]
    meta.id           = row[0]
    meta.single_end   = row.size() > 2 ? false : true

    if (params.platform == "illumina") {
        reads = meta.single_end ? [checkRead(row[1].toString())] : [checkRead(row[1].toString()),checkRead(row[2].toString())]
    } else (params.platform == "nanopore") {
        reads = checkRead(row[1].toString())
    }
    
    array = [ meta, reads ]
    return array
}

def checkRead(String read) {
    if (read == 'NA') return 'NA'
    if (!file(read).exists())    exit 1, "ERROR: Please check input samplesheet -> FASTQ file does not exist!\n   ${read}"        
    if (file(read).size() == 0)  exit 1, "ERROR: Please check input samplesheet -> FASTQ file is empty!\n   ${read}"
    return file(read)
}