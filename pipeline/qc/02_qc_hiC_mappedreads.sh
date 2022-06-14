#!/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 16gb --out logs/hic_qc.%a.log
module load phasegenomics
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=2
fi
INDIR=hiC_QC
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi

pushd $INDIR
BAM=$(ls *.bam | sed -n ${N}p)
NAME=$(basename $BAM .bam)
hic_qc.py -b $BAM -n 2000000 --lib_enzyme Dpn --outfile_prefix $NAME --sample_type genome
popd
