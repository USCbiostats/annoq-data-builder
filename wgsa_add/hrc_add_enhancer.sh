#!/bin/bash 

input='./../../annoq-data/slim-hrc'
outdir='./../../annoq-data/slim-hrc-res'
#mkdir $outdir

for i in `ls $input |grep vcf`; do
  python3 add_enhancer_anno.py -f $input/$i -e ./../../annoq-data/enhancer/temp_out  > $outdir/$i
done
