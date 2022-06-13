#!/usr/bin/bash
#SBATCH -p short -N 1 -n 32 --mem 64gb --out logs/bwa_map.Illumina.log

module load miniconda3
module load samblaster
module load samtools
module load bwa

CPU=2
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
	CPU=$SLURM_CPUS_ON_NODE
fi

IN=input
PREFIX=Black_Yeast_S1
GENOME=genome/JES_119.Illumina_only.fasta
NAME=JES_119.Illumina_asm
OUTDIR=hiC_QC_Illumina
mkdir -p $OUTDIR

if [ ! -f $GENOME.sa ]; then
	bwa index $GENOME
fi

bwa mem -t $CPU -5SP $GENOME $IN/${PREFIX}_R[12]_001.fastq.gz | samblaster | samtools view -O bam --threads 2 -h -F 2316 -o $OUTDIR/$NAME.HiC_aln.bam
