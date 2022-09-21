#!/bin/bash 

wgsa_dir='./../wgsa_095'

set -e

mkdir $wgsa_dir
cd $wgsa_dir

mkdir annovar20200608
mkdir configs
mkdir htslib
mkdir input
mkdir res
mkdir resources
mkdir slurm
mkdir snpeff
mkdir tmp
mkdir vep
mkdir work

chmod 777 work
