#!/bin/bash -l
#SBATCH -p intel -N 1 -n 2 --mem 32gb --out logs/HiC_SALSA_nocorrect.%a.log

module load samtools
module load bedtools
module load SALSA
module load boost
module load workspace/scratch
# he restriction enzyme is Dpn2 (cuts at "GATC")
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=2
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
INPUT=hiC_QC
OUT=hiC_scaffold
BAM=$(ls $INPUT/*.HiC_aln.bam | sed -n ${N}p)
NAME=$(basename $BAM .HiC_aln.bam)
mkdir -p $OUT
BED=$NAME.bed
GENOME=genomes/$NAME.fasta

if [ ! -s $INPUT/$BED ]; then
	bamToBed -i $BAM > $SCRATCH/$BED
	sort -k 4,4 $SCRATCH/$BED > $INPUT/$BED
fi

if [ ! -s $GENOME.fai ]; then
	samtools faidx $GENOME
fi
#enzyme is Dpn2
pipeline=$(which run_pipeline.py)

$pipeline -a $GENOME -l $GENOME.fai -b $INPUT/$BED -e GATC -o $OUT/$NAME --exp 29000000
