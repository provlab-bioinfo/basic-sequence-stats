workflow STATS {
    take:
        sheet // file: /path/to/samplesheet.csv
        outdir
        label

    main:
        GET_STATS(sheet, outdir, label)

    emit:
        //samplesheet = GET_STATS.out.samplesheet
        versions = GET_STATS.out.versions

}

process GET_STATS {
    tag "$sheet"
    label 'process_medium'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'biocontainers/python:3.9--1' }"

    input:
        path(sheet)
        path(outdir)
        val(label)

    output:
       // path '*.csv'       , emit: samplesheet
        path "versions.yml", emit: versions

    when:
        task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/rnaseq/bin/
        """
        #nextflow run https://github.com/provlab-bioinfo/basic-sequence-stats \
        nextflow run /nfs/Genomics_DEV/projects/alindsay/Projects/basic-sequence-stats \
        --sheet ${sheet} \
        --outdir ${outdir} \
        --label ${label}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$(python --version | sed 's/Python //g')
        END_VERSIONS
        """
}
