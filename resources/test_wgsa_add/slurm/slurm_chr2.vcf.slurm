#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=50:00:00
#SBATCH --account=pdthomas_136
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=50G
#SBATCH --mail-type=end, fail
#SBATCH --mail-user=mushayah@usc.edu


in_file='./../resources/test_wgsa_add/input/chr2.vcf'
out_file='./../resources/test_wgsa_add/output/chr2.vcf'
panther_dir='./../../annoq-data/wgsa_add'
enhancer_dir='./../../annoq-data/enhancer/enhancer_map'

#module load python/3.9.2
python3 --version
source ./../venv/bin/activate

echo "python3 add_annotations.py -f $in_file -p $panther_dir -e $enhancer_dir > $out_file"
echo start at `date`    
    python3 add_annotations.py -f $in_file -p  $panther_dir -e $enhancer_dir > $out_file
echo end at `date`

