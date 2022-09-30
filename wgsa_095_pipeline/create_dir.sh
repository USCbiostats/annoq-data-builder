#!/bin/bash 

((!$#)) && echo No arguments supplied! && exit 1
wgsa_dir=$1

set -e

mkdir $wgsa_dir
cd $wgsa_dir

mkdir scripts
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
mkdir .vep
mkdir work

chmod 777 work
