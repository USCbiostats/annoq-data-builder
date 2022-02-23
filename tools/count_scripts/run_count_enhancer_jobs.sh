#!/bin/bash 


in_dir='./../../WGSA_add/output/HRC_03_07_19/'
out_dir='./../../annoq-data/counts/HRC_03_07_19/'
slurm_dir='./../../annoq-data/count_slurm'

#local testing
#in_dir='./../../../annoq-data/slim-hrc-res'
#out_dir='./../../../annoq-data/slim-hrc-res-count2'
#slurm_dir='./../../../annoq-data/slurm4'

mkdir -p $slurm_dir
mkdir -p $out_dir

for fp in `ls $in_dir|grep .vcf$` ; do
    echo $in_dir/$fp
    STEM=$(basename ${fp} ".vcf")
    IN_FILE=$in_dir/${fp} OUT_FILE=$out_dir/${STEM}".json" \
    envsubst '$IN_FILE, $OUT_FILE' < enhancer_count_sbatch.template > $slurm_dir/slurm_${fp}.slurm
    sbatch $slurm_dir/slurm_${fp}.slurm
done

