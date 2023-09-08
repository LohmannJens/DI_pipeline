#!/bin/bash


experiment=Penn2022
accnums=("ERR10231076" "ERR10231077" "ERR10231079" "ERR10231080" "ERR10231081")


for accnum in "${accnums[@]}"; do
    configfile=configs/${experiment}/${accnum}.conf
    echo $accnum
    rm DIP-pipeline_trace.txt

    NXF_VER=22.10.1 NXF_CONDA_ENABLED=true nextflow -c $configfile run long_modified_pipeline.nf
    wait
    bash postprocessing.sh $experiment $accnum
done


#rm -r work/*
#rm -r results/${experiment}/bowtie2
#rm -r results/${experiment}/fastqc_trim
#rm -r results/${experiment}/trimmomatic
#rm -r results/${experiment}/virema
