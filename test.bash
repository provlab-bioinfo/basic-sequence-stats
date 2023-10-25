nextflow run . --label 231005_N_I_087 --folder /nfs/APL_Genomics/231005_N_I_087/231005_MN01658_0131_A000H5NFJH/ --outdir /nfs/Genomics_DEV/projects/alindsay/Projects/raw-read-qc/

nextflow run . --prefix 230503_N_N_046 --fastq_input /nfs/APL_Genomics/virus_covid19/routine_seq/2023_05_RUNS/230503_N_N_046/ARTIC03May2023_046/ --outdir /nfs/Genomics_DEV/projects/alindsay/Projects/raw-read-qc/ --nanopore

nextflow run . --label raw --folder /nfs/APL_Genomics/231005_N_I_087/231005_MN01658_0131_A000H5NFJH/ --outdir /nfs/Genomics_DEV/projects/alindsay/Projects/basic-sequence-stats/testOutput/ --platform illumina