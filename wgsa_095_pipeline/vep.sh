#!/bin/bash 

((!$#)) && echo No arguments supplied! && exit 1
set -e

wgsa_dir=$1


cd $wgsa_dir
cd vep

unzip ../../downloads/107.zip -d .

cd ensembl-vep-release-107/
cache_dir=./../../../wgsa_095/.vep

sudo perl INSTALL.pl -c $cache_dir -r $cache_dir --ASSEMBLY GRCh37 
sudo perl INSTALL.pl -c $cache_dir -r $cache_dir --ASSEMBLY GRCh38
