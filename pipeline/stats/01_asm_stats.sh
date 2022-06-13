#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 4gb --out logs/stats.log

module load AAFTF

INDIR=asm
OUTDIR=genomes
mkdir -p $OUTDIR
for type in AAFTF
do
	for file in $(ls $INDIR/$type/*.sorted.fasta)
	do
		ID=$(basename $file .sorted.fasta)
		rsync -a $file $OUTDIR/$ID.$type.fasta
		if [[ ! -f $OUTDIR/$ID.$type.stats.txt || $OUTDIR/$ID.$type.fasta -nt $OUTDIR/$ID.$type.stats.txt ]]; then
    	    		AAFTF assess -i $OUTDIR/$ID.$type.fasta -r $OUTDIR/$ID.$type.stats.txt
		fi
	done
done
