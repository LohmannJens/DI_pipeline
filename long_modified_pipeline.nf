#!/usr/bin/env nextflow
/*
* USAGE: nextflow run myscript.nf -qs 8
* Note that "-qs" is similar to "#SLURM --array=##%8" and will only run a specified # of jobs at a time.
* This script creates hard links to data that exists in nextflows work directory.
*/

/* Set parameter values. - STARTS HERE */
 // Note that any of the parameters can be set on the command line. For example, params.projectPath can be set on the command line by using "--projectPath". 
 // You can also use a configuration file to set parameters. Remember to use -c myParams.conf when running Nextflow.

// version
version = 0.3

// Path to project folder
params.projectPath = "/home/jens/Vir-AI-DIP/Influenza-virus-DI-identification-pipeline/"

// Paths to bowtie/2 indices
params.bowtie2_index = "${params.projectPath}data/genome/bowtie2-2.3.2-index/${params.strain}/${params.strain}"
params.virema_index = "${params.projectPath}data/genome/bowtie-1.2.0-index/${params.strain}/${params.strain}"

// Path to ViReMa folder
params.viremaApp = "${params.projectPath}/ViReMa_with_Fuzz"

// Path to raw fastq files
params.rawDataPath = "${params.projectPath}/data/raw_fastq/${params.experimentName}"

// Output path
params.outPath = "${params.projectPath}/results/${params.experimentName}"

Channel
    .fromFilePairs("${params.rawDataPath}/${params.accessionNumber}_{1,2}.fastq.gz", flat: true)
    .ifEmpty {error "Cannot find any reads matching: ${params.reads}"}
    .set {reads}

// Biocluster options. List memory in gigabytes.
params.myQueue = 'normal'
params.trimMemory = '15'
params.trimCPU = '6'
params.bowtie2Mem = '15'
params.bowtie2CPU = '6'
params.viremaMem = '15'
params.viremaCPU = '6'


// Trimming options
params.trimMinReadLen = 75
params.trimOptions = " ILLUMINACLIP:Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:15:10 SLIDINGWINDOW:3:20 LEADING:28 TRAILING:28 MINLEN:${params.trimMinReadLen} " 

// VireMa options
params.seed = 25
params.scoreMin = 'L,0,-0.3' /* This is the value for --score-min */
params.micro = '20'          /* The minimum length of microindels */
params.defuzz = '3'          /* If a start position is fuzzy, then its reported it at the 3' end (3), 5' end (5), or the center of fuzzy region (0). */
params.mismatch = '1'        /* This is the value of --N in ViReMa */
params.X  = 2                /*This is the value of --X in ViRema for setting number of nucleotides not allowed to mismatch on either end of read*/

// Output paths
//params.outPath = "results"

/* Set parameter values - ENDS HERE */


/* Code that should not change - STARTS HERE */

params.trimPath = "${params.outPath}/trimmomatic"
params.fastqcPath = "${params.outPath}/fastqc_trim"
params.alignPath = "${params.outPath}/bowtie2"
params.viremaPath = "${params.outPath}/virema"



/*
* Step 1. Trimming
* WARNING: considers '1' a valid exit status to get around wrapper error
*/

process trimmomatic {
    cpus params.trimCPU
    queue params.myQueue
    memory "$params.trimMemory GB"
    publishDir params.trimPath, mode: 'copy'
    //validExitStatus 0,1

    input:
    set val(id), file(read1), file(read2) from reads

    output:
    set val(id), "${read1.baseName}.qualtrim.paired.fastq", "${read2.baseName}.qualtrim.paired.fastq" into fastqChannel
    set val(id), "${read1.baseName}.qualtrim.paired.fastq", "${read2.baseName}.qualtrim.paired.fastq" into catChannel
    file "*.qualtrim.unpaired.fastq"
    stdout trim_out

    """
    java -jar ${params.projectPath}Trimmomatic-0.39/trimmomatic-0.39.jar PE \
    -threads $params.trimCPU -phred33 $read1 $read2 \
    ${read1.baseName}.qualtrim.paired.fastq ${read1.baseName}.qualtrim.unpaired.fastq \
    ${read2.baseName}.qualtrim.paired.fastq ${read2.baseName}.qualtrim.unpaired.fastq \
    $params.trimOptions
    """
}


/*
* Step 2. FASTQC of trimmed reads

process runFASTQC {
    cpus 4
    queue params.myQueue
    memory '15 GB'
    publishDir params.fastqcPath, mode: 'copy'

    input:
    set pair_id, file(read1), file(read2) from fastqChannel

    output:
    file "*.html"
    file "*.zip"

    """
    fastqc -t 2 -o ./ --noextract $read1 $read2
    """
}
*/

/*
* Step 3. Combine FASTQ pairs
*/
process combineFASTQ {
    queue params.myQueue
    publishDir params.trimPath, mode: 'copy'

    input:
    set pair_id, file(read1), file(read2) from catChannel

    output:
    file  "*both.fq" into bowtie2_channel

    """
    cat $read1 $read2 > ${pair_id}both.fq
    """
}


/*
* Step 4. Bowtie2 alignment
*/
process runbowtie2 {
    cpus params.bowtie2CPU
    queue params.myQueue
    memory "$params.bowtie2Mem GB"
    publishDir params.alignPath, mode: 'copy'

    input:
    file in_cat from bowtie2_channel

    output:
        file "*_unaligned.fq" into virema_channel
        file "*.sam"
        file "*_aligned.fq"

    """
    bowtie2 -p $params.bowtie2CPU -x $params.bowtie2_index -U $in_cat --score-min $params.scoreMin \
    --al ${in_cat.getBaseName(2)}_aligned.fq --un ${in_cat.getBaseName(2)}_unaligned.fq > ${in_cat.getBaseName(2)}.sam

    """
}

/*
* Step 5. ViReMa
*/
process runVirema {
    cpus params.viremaCPU
    queue params.myQueue
    memory "$params.viremaMem GB"
    publishDir params.viremaPath, mode: 'copy'

    input:
    file unalign from virema_channel

    output:
    file "*.results"
    file "*Virus_Recombination_Results.txt" into virema_sum
    file "*tions.txt"
    file "*UnMapped*.txt"
    file "*Single*.txt"
    file "*_rename.fq"

    """
    awk '{print (NR%4 == 1) ? "@1_" ++i : \$0}' $unalign > ${unalign.baseName}_rename.fq
    
    python ${params.viremaApp}/ViReMa.py --MicroInDel_Length $params.micro -DeDup --Defuzz 3 --Seed ${params.seed} \
    --N ${params.mismatch} --X ${params.X} --Output_Tag $unalign.baseName -ReadNamesEntry --p $params.viremaCPU \
    $params.virema_index ${unalign.baseName}_rename.fq ${unalign.baseName}.results

    """
}

/*
* Step 6. ViReMa Summary of results (w/ perl scripts)
*/
process runSummary {
    queue params.myQueue
    memory "$params.viremaMem GB"
    publishDir params.viremaPath, mode: 'copy'

    input:
    file in_file from virema_sum

    output:
    file "*.par*"

    """
    perl ${params.projectPath}parse-recomb-results-Fuzz.pl -i $in_file -o ${in_file.baseName}.par
    """
}
