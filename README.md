# Raw Read QC

A generic pipeline that can be run on an arbitrary set of Illumina or Nanopore sequence files, regardless of the project or organism of interest. Based upon previous work at the BC-CDC<sup>[1](#references),[2](#references)</sup>.

## Table of Contents

- [Introduction](#introduction)
- [Quick-Start Guide](#quick-start%guide)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Input](#input)
- [Output](#output)
- [Workflow](#workflow)
- [References](#references)

## Quick-Start Guide

```
conda activate raw-read-qc
nextflow run pipelines/raw-read-qc \
  [--prefix 'prefix'] \
  --fastq_input <your fastq input directory> \
  --outdir <output directory> \
  [--nanopore | --illumina]
```

## Dependencies

[Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) is required to build an environment with required workflow dependencies. To create the environment
```
conda env create -f ./environments/environment.yml
```

## Analyses

* [`fastp`](https://github.com/OpenGene/fastp): QC stats for Illumina experiments
* [`nanoq`](https://github.com/esteinig/nanoq): QC stats for Nanopore experiments

## Input


## Output
A single output file in .csv format will be created in the directory specified by `--outdir`. The filename will be `basic_qc_stats.csv`.
If a prefix is provided using the `--prefix` flag, it will be prepended to the output filename, for example: `prefix_basic_qc_stats.csv`.

The output file headers for Illumina data:

```
sample_id
total_reads_before_filtering
total_reads_after_filtering
total_bases_before_filtering
total_bases_after_filtering
read1_mean_length_before_filtering
read1_mean_length_after_filtering
read2_mean_length_before_filtering
read2_mean_length_after_filtering
q20_bases_before_filtering
q20_bases_after_filtering
q20_rate_before_filtering
q20_rate_after_filtering
q30_bases_before_filtering
q30_bases_after_filtering
q30_rate_before_filtering
q30_rate_after_filtering
gc_content_before_filtering
gc_content_after_filtering
adapter_trimmed_reads
adapter_trimmed_bases
```

The output file headers for Nanopore data:

```
sample_id
reads
bases
n50
longest
shortest
mean_length
median_length
mean_quality
median_quality
```


## References
1. https://github.com/BCCDC-PHL/basic-nanopore-qc
2. https://github.com/BCCDC-PHL/basic-sequence-qc

