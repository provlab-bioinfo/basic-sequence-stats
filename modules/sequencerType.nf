#!/usr/bin/env nextflow
project_dir = projectDir

process sequencerType {
    input:
    val(dir)

    output:
    stdout emit: seqType
            
    script:
    """
    echo `sequencerType.py ${dir}`
    """
}