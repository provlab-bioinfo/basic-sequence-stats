conda activate basic-sequence-stats

nextflow run . --label raw --sheet /nfs/Genomics_DEV/projects/alindsay/Projects/basic-sequence-collecter/testOutput/230503_N_I_047/pipeline_info/samplesheet.valid.csv --outdir ./testOutput/230503_N_I_047/

nextflow run . --label raw --sheet /nfs/Genomics_DEV/projects/alindsay/Projects/basic-sequence-collecter/testOutput/230503_N_N_046/pipeline_info/samplesheet.valid.csv --outdir ./testOutput/230503_N_N_046/