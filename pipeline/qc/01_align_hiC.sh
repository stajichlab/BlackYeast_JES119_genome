#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 32 --mem 64gb --out logs/bwa_map.Illumina.%a.log

module load miniconda3
module load samblaster
module load samtools
module load bwa

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

IN=input/HiC
PREFIX=Black_Yeast_S1
GENOME=$(ls genomes/*.fasta | sed -n ${N}p)
NAME=$(basename $GENOME .fasta)

echo "$GENOME $NAME"
OUTDIR=hiC_QC
mkdir -p $OUTDIR

if [[ ! -f $GENOME.sa ]]; then
    bwa index $GENOME
fi

bwa mem -t $CPU -5SP $GENOME $IN/${PREFIX}_R[12]_001.fastq.gz | samblaster | samtools view -O bam --threads 2 -h -F 2316 -o $OUTDIR/$NAME.HiC_aln.bam
