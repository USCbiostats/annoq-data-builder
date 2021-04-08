#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=90:00:00
#SBATCH --account=lc_pdt
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=20G
input='res/HRC_03_07_19'
outdir='anno/hrc_12_2019'

source /scratch2/mushayah/set_up_env.sh
mkdir $outdir
cd /scratch2/mushayah/independent_anno
for i in `ls $input|grep gz$`; do
echo "zcat $input/$i |python3 add_panther_anno.py |python3 add_enhancer_anno.py|bgzip > $outdir/$i"
echo start at `date`
zcat $input/$i |python3 add_panther_anno.py |python3 add_enhancer_anno.py|bgzip > $outdir/$i
echo end at `date`
done
#perl splitVCF_new.pl working_dir/All_20180418.vcf 16503655
