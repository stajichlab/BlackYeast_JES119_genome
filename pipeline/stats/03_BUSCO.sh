#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 8 --mem 16G -p short --out logs/busco.%a.log -J busco -a 1-2

# for augustus training
# set to a local dir to avoid permission issues and pollution in global
module unload miniconda3
module load busco
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

module load workspace/scratch

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
GENOMEFOLDER=genomes
EXT=fasta
LINEAGE=ascomycota_odb10
OUTFOLDER=BUSCO
SEED_SPECIES=anidulans
mkdir -p $OUTFOLDER
for file in $(ls $GENOMEFOLDER/*.$EXT| sed -n ${N}p)
do
    ID=$(basename $file .$EXT)
    
    if [ -d "$OUTFOLDER/${ID}" ];  then
	echo "Already have run $ID in folder busco - do you need to delete it to rerun?"
	continue
    else
	busco -m genome -l $LINEAGE -c $CPU -o ${ID} --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	      --in $GENOMEFILE --download_path $BUSCO_LINEAGES
    fi
done
