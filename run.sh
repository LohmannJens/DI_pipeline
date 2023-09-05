#!/bin/bash


# TODO: repeat form "SRR8754513"
experiment=Alnaji2019
#accnums=("SRR8754522" "SRR8754523" \
#"SRR8754507" "SRR8754508" "SRR8754509" "SRR8754516" \
accnums=("SRR8754513" "SRR8754514" "SRR8754527" "SRR8754538" \
"SRR8754517" "SRR8754524" "SRR8754525" "SRR8754526" \
"SRR8754531" "SRR8754532" "SRR8754533")
### 22, 23 is Cal07 Fig 9
### 7, 8, 9, 16 is BLee
### 13, 14, 27, 38 is NC
### 17, 24, 25, 26 is Perth
### 31, 32, 33 is Cal Fig 6 (time series)


#experiment=Alnaji2021
#accnums=("SRR14352112" "SRR14352116" "SRR14352117" \
#"SRR14352109" "SRR14352110" "SRR14352111" \
#"SRR14352106" "SRR14352107" "SRR14352108" \
#"SRR14352113")
### 12, 16, 17 is 3hpi
### 9, 10, 11 is 6hpi
### 6, 7, 8 is 24hpi
### 13 is PR8 wildtype (seed virus?)


#experiment=Pelz2021
#accnums=("SRR15084902" "SRR15084903" "SRR15084904" "SRR15084905" "SRR15084906" "SRR15084907" "SRR15084908" "SRR15084909" "SRR15084910" "SRR15084911" "SRR15084912" "SRR15084913" "SRR15084914" "SRR15084915" "SRR15084916" "SRR15084917" "SRR15084918" "SRR15084919" "SRR15084921" "SRR15084922" "SRR15084923" "SRR15084924" "SRR15084925")
### unordered time series data


experiment=Mendes2021
accnums=("SRR15720520" "SRR15720521" "SRR15720522" "SRR15720523" \
"SRR15720524" "SRR15720525" "SRR15720526" "SRR15720527" \
"SRR15720528" "SRR15720529" "SRR15720530" "SRR15720531" \
"SRR15720532" "SRR15720533" "SRR15720534" "SRR15720535")
### 20, 21, 22, 23 is IFNB1 enriched
### 24, 25, 26, 27 is IFNB1 depleted
### 28, 29, 30, 31 is IFNB1 enriched
### 32, 33, 34, 35 is IFNB1 depleted


#experiment=Lui2019
#accnums=("SRR8949705")
### just one experiment


#experiment=Wang2018
#accnums=("SRR7722028" "SRR7722030" "SRR7722032" \
#"SRR7722029" "SRR7722031" "SRR7722033" \
#"SRR7722036" "SRR7722038" "SRR7722040" \
#"SRR7722037" "SRR7722039" "SRR7722041" \
#"SRR7722046")
### 28, 30, 32 is A549 rep1
### 29, 31, 33 is A549 rep2
### 36, 38, 40 is HBEpC rep1
### 37, 39, 41 is HBEpC rep2
### 46 is PR8 virus stock (seed virus)


for accnum in "${accnums[@]}"; do
    configfile=configs/${experiment}/${accnum}.conf
    echo $accnum
    rm DIP-pipeline_trace.txt

    NXF_VER=22.10.1 NXF_CONDA_ENABLED=true nextflow -c $configfile run modified_pipeline.nf
    wait
    bash postprocessing.sh $experiment $accnum
done


#rm -r work/*
#rm -r results/${experiment}/bowtie2
#rm -r results/${experiment}/fastqc_trim
#rm -r results/${experiment}/trimmomatic
#rm -r results/${experiment}/virema
