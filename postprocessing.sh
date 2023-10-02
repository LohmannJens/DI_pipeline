#!/bin/bash

### Usage of script ###
# bash postprocess.sh Alnaji2021 SRR14352105

experiment=$1
accnum=$2

infile=results/${experiment}/virema/${accnum}_unaligned_Virus_Recombination_Results.par
directory=results/${experiment}/final/
if [ ! -d $directory ]; then
    mkdir -p $directory
fi

outfile=$directory${experiment}_${accnum}.csv
echo Segment,Start,End,NGS_read_count > $outfile
awk 'NR > 1 {gsub(" ", ","); print $1","$2","$3","$6}' $infile >> $outfile

python analyze_aligned_reads.py -a $experiment -s $accnum
