#!/bin/bash 
#SBATCH --ntasks=1 
#SBATCH --time=50:00:00
#SBATCH --account=pdthomas_136
#SBATCH --partition=thomas
#SBATCH --mem-per-cpu=90G

input='input/TOPMed_09_20'
output='input_unzipped/TOPMed_09_20'

mkdir -p $output

for f in `ls $input|grep .gz$`; do
  fp=$input/$f
  STEM=$(basename "${fp}" .gz)
  echo unzipping ${fp} `date`
  gunzip -c "${fp}" > $output/"${STEM}"
done
