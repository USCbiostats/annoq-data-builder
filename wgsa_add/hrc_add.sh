#!/bin/bash 

input='./../../annoq-data/slim-hrc'
outdir='./../../annoq-data/slim-hrc-res'
#mkdir $outdir

for i in `ls $input`; do
    $input/$i|python3 add_panther_anno.py |bgzip > $outdir/$i
done
