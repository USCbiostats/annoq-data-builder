#!/bin/bash 

set -e

wgsa_dir=$1

cd $wgsa_dir
cd snpeff

unzip ../../downloads/snpEff_v4_3t_core.zip -d .

cd snpEff
java -jar snpEff.jar download -v hg19
java -jar snpEff.jar download -v GRCh37.75
java -jar snpEff.jar download -v hg38
java -jar snpEff.jar download -v GRCh38.86