# Basic Sequence Stats
 [![Lifecycle: WIP](https://img.shields.io/badge/lifecycle-WIP-yellow.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) [![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/provlab-bioinfo/basic-sequence-stats/issues) [![License: GPL3](https://img.shields.io/badge/license-GPL3-lightgrey.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html) [![minimal Python version: 3.0](https://img.shields.io/badge/Python-3.0-6666ff.svg)](https://www.python.org/) [![Package Version = 0.0.1](https://img.shields.io/badge/Package%20version-0.0.1-orange.svg?style=flat-square)](https://github.com/provlab-bioinfo/basic-sequence-stats/blob/main/NEWS) [![Last-changedate](https://img.shields.io/badge/last%20change-2023--10--25-yellowgreen.svg)](https://github.com/provlab-bioinfo/basic-sequence-stats/blob/main/NEWS)

A generic pipeline that can generate sequencing read statistics and quality metrics on an arbitrary set of FASTQ files from Illumina (single- and paired-end short reads) or Nanopore (long read) NGS, regardless of the project or organism of interest. Built upon previous work at [ProvLab](https://github.com/provlab-bioinfo/pathogenseq)<sup>[1](#references)</sup>.

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
```

## Dependencies

[Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) is required to build the [basic-sequence-stats](/environments/environment.yml) environment with the necessary workflow dependencies. To create the environment:
```
conda env create -f ./environments/environment.yml
```

## Analyses:
* [`nanoplot`](https://github.com/wdecoster/NanoPlot): Reads quality check for Nanopore reads
* [`fastqc`](https://github.com/s-andrews/FastQC): Reads quality check for Illumina reads
* [`seqkit`](https://bioinf.shenwei.me/seqkit/): Generates statistics for all reads

## Input

**`--outdir`**: The output directory. 
<br>
**`--label`**: A label for the analysis. See [Output](#output) for details. 
<br>
**`--platform`**: Sequencing platform. Either `illumina` or `nanopore`. 
<br>
**`--folder`**: For a typical sequencing run, only the run folder needs to be specified, as the FASTQ files will be searched for automatically. The file format must be as follows:

- Illumina: Paired reads are assumed and must use the default [Illumina nomenclature](https://support.illumina.com/help/BaseSpace_OLH_009008/Content/Source/Informatics/BS/NamingConvention_FASTQ-files-swBS.htm#) of `{SampleName}_S#_L001_R#_001.fastq.gz`. The script will search for `R1` and `R2`, and assign sample names as `SampleName_S1`.
- Nanopore: Accepts single or split FASTQ files, and must use the default Nanopore nomenclature of `{FlowCellID}_pass_barcode##_{random}[_#].fastq.gz`. Files containing the same barcode and terminated with `_#` will be automatically concatenated. Sample name will be assigned as `barcode##`.

**`--sheet`**: A CSV file specifying an `ID` and list of `Reads`. Each read must be a single file in `.fastq` or `.fastq.gz` format. For example:

```
ID,         illumina1,                  illumina2,                  nanopore
SAMPLE-01   ,/path/to/SAMPLE-01.fq      ,                           ,
SAMPLE-02   ,/path/to/SAMPLE-02_R1.fq   ,/path/to/SAMPLE-02_R2.fq   , 
SAMPLE-03   ,                           ,                           ,/path/to/SAMPLE-03.fq/
```

## Output

The output file structure is determined by the `outdir` and `label` parameters, and `ID` of the samples:

```bash
<outdir>
   ├── pipeline_info
   │          └── software_versions.yml
   ├── <label>
   │      └── stats
   │            ├── <ID>.nanoplot.html
   │            ├── <ID>.seqkit.tsv
   │            └── <ID>.fastqc.html
   └── report
          ├── <label>.multiqc.html
          └── <label>.seqkit.tsv
```

## References
1. Provlab-Bioinfo/pathogenseq: Pathogen whole genome sequence (WGS) data analysis pipeline. https://github.com/provlab-bioinfo/pathogenseq 



