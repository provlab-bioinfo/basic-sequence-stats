# Basic Sequence Stats
 [![Lifecycle: WIP](https://img.shields.io/badge/lifecycle-WIP-yellow.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) [![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/CompEpigen/scMethrix/issues) [![License: MIT](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/license/mit/) [![minimal Python version: 3.0](https://img.shields.io/badge/Python-3.0-6666ff.svg)](https://www.python.org/) [![Package Version = 0.0.1](https://img.shields.io/badge/Package%20version-0.0.1-orange.svg?style=flat-square)](https://github.com/provlab-bioinfo/raw-read-qc/blob/main/NEWS) [![Last-changedate](https://img.shields.io/badge/last%20change-2023--10--12-yellowgreen.svg)](https://github.com/provlab-bioinfo/raw-read-qc/blob/main/NEWS)

A generic pipeline that can generate sequencing read statistics on an arbitrary set of FASTQ files from Illumina (single- and paired-end short reads) or Nanopore (long read) NGS, regardless of the project or organism of interest. Built upon previous work at [ProvLab](https://github.com/provlab-bioinfo/pathogenseq)<sup>[1](#references)</sup>.

## Table of Contents

- [Introduction](#introduction)
- [Quick-Start Guide](#quick-start%guide)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Input](#input)
- [Output](#output)
- [Workflow](#workflow)
- [References](#references)

## Quick code

```
conda activate basic-sequence-stats
nextflow run pipelines/basic-sequence-stats \
  [ --folder <input directory> | --sheet <sample sheet path> ]\
  --outdir <output directory> \
  --platform [ 'illumina' | 'nanopore' ] \
  [--label 'label']
  [--pairedEnd]
```

## Dependencies

[Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) is required to build the [basic-sequence-stats](/environments/environment.yml) environment with the necessary workflow dependencies. To create the environment:
```
conda env create -f ./environments/environment.yml
```

## Analyses:
* [`nanoplot`](https://github.com/wdecoster/NanoPlot): Reads quality check for Illumina experiments
* [`fastqc`](https://github.com/s-andrews/FastQC): Reads quality check for Nanopore experiments
* [`seqkit`](https://bioinf.shenwei.me/seqkit/): Read statistics toolkit

## Input

**`--outdir`**: The output directory. 
<br>
**`--label`**: A label for the analysis. See [Output](#output) fo details. 
<br>
**`--platform`**: Sequencing platform. Either `illumina` or `nanopore`. 
<br>
**`--pairedEnd`**: Either `true` or `false`. For `true`, `--platform` must be `illumina`.
<br>
**`--folder`**: For a typical sequencing run, only the run folder needs to be specified, as the FASTQ files will be searched for automatically. The file format must be as follows:

- Illumina: Paired reads are assumed and must use the default [Illumina nomenclature](https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm#) of `{SampleName}_S#_L001_R#_001.fastq.gz`. The script will search for `R1` and `R2`, and assign sample names as `SampleName_S1`.
- Nanopore: Accepts single or split FASTQ files, and must use the default Nanopore nomenclature of `{FlowCellID}_pass_barcode##_{random}[_#].fastq.gz`. Files containing the same barcode and terminated with `_#` will be automatically concatenated. Sample name will be assigned as `barcode##`.

**`--sheet`**: More complicated formats (e.g., samples spread across multiple Nanopore runs) can still be analyzed via sample sheet input. The CSV file must contain an `ID` and list of `Reads`, which can be either individual files or directories of files that will be concatenated together for analysis:

```
ID,         Reads
SAMPLE-01,  [/path/to/SAMPLE-01_R1_1.fq, /path/to/SAMPLE-01_R1_2.fq]
SAMPLE-02,  [/path/to/RUN1/SAMPLE-02/, /path/to/RUN2/SAMPLE-02/]
SAMPLE-03,  [/path/to/RUN1/SAMPLE-03.fastq.gz, /path/to/RUN2/SAMPLE-03/]
```

## Output
A single output file in .csv format will be created in the directory specified by `--outdir`. The filename will be `basic_qc_stats.csv`.
If a prefix is provided using the `--prefix` flag, it will be prepended to the output filename, for example: `prefix_basic_qc_stats.csv`.

**For both**: The output file headers from [`seqkit`](https://bioinf.shenwei.me/seqkit/) (see [example](/examples/illumina_basic_qc_stats.csv))

Summarized output will go to the folder `/reports/{label}_[nanoplot|fastqc|seqkit].tsv` and file outputs will go to `{label}/qc/[nanoplot|fastqc|seqkit]/{ID}.seqstats.tsv`

Output will have a folder called `{label}_seqstats` and filenames will have the format `{ID}.seqstats.tsv`.

<details>
  <summary>Click to open</summary>

```
ID
format
type
num_seqs
sum_len
min_len
avg_len
max_len
Q1
Q2
Q3
sum_gap
N50
Q20(%)
Q30(%)
```
</details>
<br>

**For Nanopore**: The output file headers from [`nanoq`](https://github.com/esteinig/nanoq) (see [example](/examples/nanopore_basic_qc_stats.csv)):

<details>
  <summary>Click to open</summary>

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
</details>

## References
1. Provlab-Bioinfo/pathogenseq: Pathogen whole genome sequence (WGS) data analysis pipeline. https://github.com/provlab-bioinfo/pathogenseq 



