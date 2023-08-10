#!/bin/bash 
#work pipeline
#1 create a directory under input, all files under that folder will be automaticly scanned and used as input
#2 change the name of work_name in script
#3 run
#detail WGSA configures can be found under ./scripts
work_name='TOPMed'

base_dir='/scratch2/mushayah/WGSA_add'

in_dir='input_unzipped/HRC_03_07_19/'
out_dir='output/HRC_03_07_19/'
slurm_dir='slurm'

#local testing
in_dir='resources/test_wgsa_add/input'
out_dir='resources/test_wgsa_add/output'
slurm_dir='resources/test_wgsa_add/slurm'

mkdir -p $slurm_dir
mkdir -p $out_dir

for fp in `ls $in_dir|grep .vcf$` ; do
    echo $in_dir/$fp
    IN_FILE=$in_dir/${fp} OUT_FILE=$out_dir/${fp} \
    envsubst '$IN_FILE, $OUT_FILE' < hrc_batch.template > $slurm_dir/slurm_${fp}.slurm
    bash $slurm_dir/slurm_${fp}.slurm
done

