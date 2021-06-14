#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=50:00:00
#SBATCH --account=pdthomas_136
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=30G

in_file='$IN_FILE'
out_file='$OUT_FILE'

echo unzipping $in_file `date`
gunzip -c $in_file > $out_file

