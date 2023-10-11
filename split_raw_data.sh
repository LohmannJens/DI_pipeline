#!/bin/bash
experiment=test
accnum=SRR10489474

input_file=data/raw_fastq/${experiment}/${accnum}

outdir=data/raw_fastq/${experiment}/split

zcat ${input_file}.fastq.gz | split -l 5000000 - ${accnum}_part_

for file in ${accnum}_part_*; do mv $file "$file".fastq; done

for file in ${accnum}_part_*; do gzip "$file"; done

if [ ! -d ${outdir} ]; then
    mkdir -p ${outdir}
fi

mv ${accnum}_part_* ${outdir}

