#!/bin/bash 

((!$#)) && echo No arguments supplied! && exit 1
set -e

wgsa_dir=$1

cd $wgsa_dir
cd .vep/Plugins
wget https://github.com/konradjk/loftee/archive/v0.1.1-beta.zip
unzip -j v0.1.1-beta.zip
rm v0.1.1-beta.zip

cd ../homo_sapiens/107_GRCh37
sudo gunzip Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz
sudo bgzip Homo_sapiens.GRCh37.75.dna.primary_assembly.fa

cd ../107_GRCh38
sudo gunzip Homo_sapiens.GRCh38.dna.toplevel.fa.gz
sudo bzip Homo_sapiens.GRCh38.dna.toplevel.fa

