#!/bin/bash -l
#!/bin/bash
#OUTDIR=/group/jrigrp4/cn.mops/data/filtered_bams
#SBATCH -D /group/jrigrp4/custom_cnv/sfs
#SBATCH -o /group/jrigrp4/custom_cnv/logs/sfs_out_log-%j.txt
#SBATCH -e /group/jrigrp4/custom_cnv/logs/sfs_err_log-%j.txt
#SBATCH -J bSFS
#SBATCH --array=0-3
#SBATCH --mem-per-cpu=28000
#SBATCH --cpus-per-task=12

##Simon Renny-Byfield, UC Davis, March 2015

echo "Starting Job:"
date

cd ../data

files=(*.region)

cd ../sfs

#now sfs for each .region file

# calculate the .saf file
cmd="angsd -bam ../../teosinte_parents/file.list.txt -doSaf 2 -out $SLURM_ARRAY_TASK_ID.teoparents20 -anc ../../teosinte_parents/genomes/TRIP.fa -ref ../../teosinte_parents/genomes/Zea_mays.AGPv3.22.dna.genome.fa -GL 1 -P 12 -indF ../../teosinte_parents/angsd_output/teo_parents20e-6.indF -rf ../data/${files[$SLURM_ARRAY_TASK_ID]} -doMaf 1 -doMajorMinor 1 -minMapQ 30 -minQ 20"
echo $cmd
eval $cmd

# formally calculate the SFS
cmd="realSFS $SLURM_ARRAY_TASK_ID.teoparents20.saf 40 -maxIter 100 -P 12 > $SLURM_ARRAY_TASK_ID.teoparents20.sfs"
echo $cmd
eval $cmd

# no fiure out region wide thetas
cmd="angsd -bam ../../teosinte_parents/file.list.txt -out $SLURM_ARRAY_TASK_ID.teosinte20thetas.sfs -doThetas 1 -doSaf 2 -ref ../../teosinte_parents/genomes/Zea_mays.AGPv3.22.dna.genome.fa -indF ../../teosinte_parents/angsd_output/teo_parents20e-6.indF -pest $SLURM_ARRAY_TASK_ID.teoparents20.sfs -anc ../../teosinte_parents/genomes/TRIP.fa -rf ../data/${files[$SLURM_ARRAY_TASK_ID]} -doMaf 1 -doMajorMinor 1 -GL 1 -P 12 -minMapQ 30 -minQ 20"
echo $cmd
eval $cmd

# make the .bed file
cmd="thetaStat make_bed $SLURM_ARRAY_TASK_ID.teosinte20thetas.sfs.thetas.gz"
echo $cmd
eval $cmd

#calculate Tajimas D
cmd="thetaStat do_stat $SLURM_ARRAY_TASK_ID.teosinte20thetas.sfs.thetas.gz -nChr 20 -win 100 -step 50 -outnames $SLURM_ARRAY_TASK_ID.teothetasWindow.gz"
echo $cmd
eval $cmd

echo "End Job: "
date
