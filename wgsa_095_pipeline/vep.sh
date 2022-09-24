#!/bin/bash 

((!$#)) && echo No arguments supplied! && exit 1
set -e

wgsa_dir=$1

cd $wgsa_dir
cd vep

unzip ../../downloads/100.zip -d .

cd ensembl-vep-release-100/

sudo perl INSTALL.pl -c /$wgsa_dir/.vep --ASSEMBLY GRCh37