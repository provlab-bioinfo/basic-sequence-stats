# Raw Read QC

A generic pipeline that can be run on an arbitrary set of FASTQ files from Illumina or Nanopore NGS, regardless of the project or organism of interest. Built upon previous work at the [BCCDC-PHL](http://www.bccdc.ca/)<sup>[1](#references),[2](#references)</sup>.

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
  --fastq_input <input directory> \
  --outdir <output directory> \
  {--nanopore | --illumina} \
  [--prefix 'prefix']
```

## Dependencies

[Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) is required to build the [raw-read-qc](/environments/environment.yml) environment with the necessary workflow dependencies. To create the environment:
```
conda env create -f ./environments/environment.yml
```

## Analyses:
* [`fastp`](https://github.com/OpenGene/fastp): QC stats for Illumina experiments
* [`nanoq`](https://github.com/esteinig/nanoq): QC stats for Nanopore experiments

## Input
- Illumina: Paired reads are assumed and must use the default [Illumina nomenclature](https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm#) of `{SampleName}_S#_L001_R#_001.fastq.gz`. The script will search for `R1` and `R2`, and assign sample names as `SampleName_S1`.
- Nanopore: Accepts single or split FASTQ files, and must use the default Nanopore nomenclature of `{FlowCellID}_pass_barcode##_{random}[_#].fastq.gz`. Files containing the same barcode and terminated with `_#` will be automatically concatenated. Sample name will be assigned as `barcode##`.

## Output
A single output file in .csv format will be created in the directory specified by `--outdir`. The filename will be `basic_qc_stats.csv`.
If a prefix is provided using the `--prefix` flag, it will be prepended to the output filename, for example: `prefix_basic_qc_stats.csv`.

**For Illumina**: The output file headers from [`fastp`](https://github.com/OpenGene/fastp) (see [example](/examples/illumina_basic_qc_stats.csv)):

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

**For Nanopore**: The output file headers from [`nanoq`](https://github.com/esteinig/nanoq) (see [example](/examples/nanopore_basic_qc_stats.csv)):

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
1. BCCDC-PHL/basic-sequence-qc: Generate some basic quality control statistics on an arbitrary set of Illumina fastq sequence files. https://github.com/BCCDC-PHL/basic-sequence-qc 
2. BCCDC-PHL/basic-nanopore-qc: Collect basic sequence QC metrics from nanopore reads. https://github.com/BCCDC-PHL/basic-nanopore-qc



