#!/bin/bash 

input='./../../annoq-data/slim-hrc'
outdir='./../../annoq-data/slim-hrc-res'
#mkdir $outdir

for i in `ls $input |grep vcf`; do
  python3 add_panther_anno.py -f $input/$i -p ./../../annoq-data/wgsa_add > $outdir/$i
done
