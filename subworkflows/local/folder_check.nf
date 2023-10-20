//
// Check input samplesheet and get read channels
//

include { FOLDERCHECK } from '../../modules/local/foldercheck'

workflow FOLDER_CHECK {
    take:
        folder // folder: /path/to/folder

    main:
        if (params.platform = 'illumina') {
            def grouping = { file -> file.name.lastIndexOf('_L001').with {it != -1 ? file.name[0..<it] : file.name} }
            reads = Channel.fromFilePairs( params.illumina_search_path, flat: true, grouping).map{ it -> [it[0], it.tail()] }
        } else if (params.latform = 'nanopore') {
            def grouping = { file -> file.name.lastIndexOf('_').with {it != -1 ? file.name[0..<it] : file.name} }
            reads = Channel.fromFilePairs( params.nanopore_search_path, flat: true , size: -1, grouping).map{ it -> [(it[0] =~ /barcode\d{1,3}/)[0], it.tail()] }
        } else {
            exit 1, "Platform must be either 'illumina' or 'nanopore'!" 
        }

        FOLDERCHECK()

    emit:
        reads 
        versions = FOLDERCHECK.out.versions

}