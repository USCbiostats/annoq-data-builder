#!/bin/bash 

input='./../../../annoq-data/slim-hrc-res'
outdir='./../../../annoq-data/slim-hrc-res-count'
mkdir -p $outdir

for i in `ls $input |grep vcf`; do
  python3 count_enhancer_anno.py -f $input/$i
done
