#!/bin/bash 

in_dir='input/HRC_03_07_19/'
out_dir='input_unzipped/HRC_03_07_19/'
slurm_dir='slurm_unzip'

#local testing
#in_dir='./../../annoq-data/hrc_sample'
#out_dir='./../../annoq-data/unzipped'
#slurm_dir='./../../annoq-data/slurm3'

mkdir -p $slurm_dir
mkdir -p $out_dir

for fp in `ls $in_dir|grep .snp.gz$` ; do
    echo $in_dir/$fp
    STEM=$(basename "${fp}" )
    out_file="chr"$(echo "$STEM" | grep -o -E '[XY0-9]+')".vcf"
    IN_FILE=$in_dir/${fp} OUT_FILE=$out_dir/${out_file} \
    envsubst '$IN_FILE, $OUT_FILE' < unzip.template.sbatch > $slurm_dir/slurm_${fp}.slurm
    sbatch $slurm_dir/slurm_${fp}.slurm
done

