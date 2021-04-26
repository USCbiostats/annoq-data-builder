#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=30G
#SBATCH --account=pdthomas_136
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=90G

input='input/hrc_sample'
outdir='output/hrc_sample'
module load python/3.9.2

python3 --version
source venv/bin/activate
mkdir $outdir
for i in `ls $input|grep gz$`; do
echo "zcat $input/$i |python3 add_panther_anno.py -p ./../annoq-data/wgsa_add  |gzip > $outdir/$i"
echo start at `date`
zcat $input/$i |python3 add_panther_anno.py -p ./../annoq-data/wgsa_add |gzip > $outdir/$i
echo end at `date`
done
#perl splitVCF_new.pl working_dir/All_20180418.vcf 16503655
