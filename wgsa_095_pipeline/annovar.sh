#!/bin/bash 

set -e
((!$#)) && echo No arguments supplied! && exit 1

wgsa_dir=$1

cd $wgsa_dir

cd annovar20200608
tar -zxvf ../../downloads/annovar.latest.tar.gz --directory .
cd annovar

# perl annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/
# perl annotate_variation.pl -buildver hg19 -downdb -webfrom annovar ensGene humandb/
# perl annotate_variation.pl -buildver hg19 -downdb -webfrom annovar knownGene humandb/
# perl annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGene humandb/
# perl annotate_variation.pl -buildver hg38 -downdb -webfrom annovar ensGene humandb/     
# perl annotate_variation.pl -buildver hg38 -downdb -webfrom annovar knownGene humandb/    