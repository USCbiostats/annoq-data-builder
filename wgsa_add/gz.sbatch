#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=90:00:00
#SBATCH --account=lc_pdt
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=20G
cd /scratch2/mushayah/independent_anno
source env/bin/activate
for i in `ls samples`; do
python3 add_panther_anno.py samples/$i > res/$i.with_func_anno
done
#perl splitVCF_new.pl working_dir/All_20180418.vcf 16503655
