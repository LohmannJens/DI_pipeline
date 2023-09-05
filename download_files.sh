#!/bin/bash
experiment=Wang2018

file=data/acclists/${experiment}.txt
prefetch --option-file $file
wait

outdir=data/raw_fastq/${experiment}
while read line; do
    echo ${line}
    fasterq-dump ${line}/${line}.sra --split-spot -O $outdir
done <$file

wait
gzip ${outdir}/*.fastq

while read line; do
    rm -r ${line}
done <$file