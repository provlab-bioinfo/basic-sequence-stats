conda activate basic-sequence-stats
nextflow run . --label raw --folder ./testInput/230503_N_N_046/  --outdir ./testOutput/230503_N_N_046/ --platform nanopore
nextflow run . --label raw --folder ./testInput/230503_N_I_047/  --outdir ./testOutput/230503_N_I_047/ --platform illumina