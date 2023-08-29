#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=90:00:00
#SBATCH --account=lc_pdt
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=20G
source /scratch2/mushayah/set_up_env.sh
input='res/dbSNP'
outdir='anno/dbSNP'
mkdir $outdir
cd /scratch2/mushayah/independent_anno
source env/bin/activate
for i in `ls $input|grep gz$`; do
zcat $input/$i |python3 add_panther_anno.py |bgzip > $outdir/$i
done
#perl splitVCF_new.pl working_dir/All_20180418.vcf 16503655
