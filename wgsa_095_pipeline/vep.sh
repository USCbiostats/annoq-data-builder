#!/bin/bash 

((!$#)) && echo No arguments supplied! && exit 1
set -e

wgsa_dir=$1


cd $wgsa_dir
cd vep

unzip ../../downloads/107.zip -d .

cd ensembl-vep-release-107/
cache_dir=./../../../wgsa_095/.vep

perl INSTALL.pl -c $cashe_dir --ASSEMBLY GRCh37