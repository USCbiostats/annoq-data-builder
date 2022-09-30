#!/bin/bash 

((!$#)) && echo No arguments supplied! && exit 1
wgsa_dir=$1


set -e
mkdir -p $wgsa_dir/scripts

cp work_scripts/config.py $wgsa_dir/scripts/
cp work_scripts/config.temp $wgsa_dir/scripts/
cp work_scripts/sbatch.py $wgsa_dir/scripts/
cp work_scripts/sbatch.temp $wgsa_dir/scripts/
cp work_scripts/run_work.sh $wgsa_dir