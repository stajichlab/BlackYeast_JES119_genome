#!/bin/bash -l
#SBATCH -p intel -N 1 -n 8 --mem 64gb --out logs/AAFTF_polish_3FC.log

CPU=8
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
	CPU=$SLURM_CPUS_ON_NODE
fi

module load AAFTF
MEM=64
ASMFILE=JES119_fast_R10/JES119_202206.contigs.fasta
PREFIX=JES119_fast_R10
OUTDIR=asm/AAFTF
VECCLEAN=$OUTDIR/$PREFIX.vecclean.fasta
PURGE=$OUTDIR/$PREFIX.sourpurge.fasta
CLEANDUP=$OUTDIR/$PREFIX.rmdup.fasta
PILON=$OUTDIR/$PREFIX.pilon.fasta
SORTED=$OUTDIR/$PREFIX.sorted.fasta
PHYLUM=Ascomycota
LEFT=input/Illumina/JES_119_R1.fq.gz
RIGHT=input/Illumina/JES_119_R2.fq.gz
mkdir -p $OUTDIR

if [ ! -f $VECCLEAN ]; then
    AAFTF vecscreen -i $ASMFILE -c $CPU -o $VECCLEAN
fi
if [ ! -f $PURGE ]; then
    AAFTF sourpurge -i $VECCLEAN -o $PURGE -c $CPU --phylum $PHYLUM --left $LEFT --right $RIGHT
fi

if [ ! -f $CLEANDUP ]; then
    AAFTF rmdup -i $PURGE -o $CLEANDUP -c $CPU -m 500
fi

if [ ! -f $PILON ]; then
    AAFTF pilon -i $CLEANDUP -o $PILON -c $CPU --left $LEFT  --right $RIGHT --mem $MEM
fi

if [ ! -f $PILON ]; then
    echo "Error running Pilon, did not create file. Exiting"
    exit
fi

if [ ! -f $SORTED ]; then
    AAFTF sort -i $PILON -o $SORTED
    # AAFTF sort -i $CLEANDUP -o $SORTED
fi

if [ ! -f $STATS ]; then
    AAFTF assess -i $SORTED -r $STATS
fi
