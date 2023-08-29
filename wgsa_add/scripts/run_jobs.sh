#!/bin/bash 
#work pipeline
#1 create a directory under input, all files under that folder will be automaticly scanned and used as input
#2 change the name of work_name in script
#3 run
#detail WGSA configures can be found under ./scripts

if [ "$#" -ne 2 ]; then
  echo "Error: Exactly 2 arguments are required."
  echo "Usage: $0 <work_name> <wgsa_dir>"
  exit 1
fi

work_name=$1
base_dir=$2

echo "running work name: $work_name using base dir: $base_dir"

in_dir=$base_dir/wgsa_add/input_unzipped/$work_name
out_dir=$base_dir/wgsa_add/output/$work_name
slurm_dir=$base_dir/wgsa_add/slurm/$work_name
sbatch_template=$base_dir/wgsa_add/scripts/hrc_batch.template

mkdir -p $slurm_dir
mkdir -p $out_dir

for fp in `ls $in_dir|grep .vcf$` ; do
    echo $in_dir/$fp
    BASE_DIR=$base_dir IN_FILE=$in_dir/${fp} OUT_FILE=$out_dir/${fp} \
    envsubst '$BASE_DIR, $IN_FILE, $OUT_FILE' < $sbatch_template > $slurm_dir/slurm_${fp}.slurm
    sbatch $slurm_dir/slurm_${fp}.slurm
done

