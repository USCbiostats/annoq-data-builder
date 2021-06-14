#!/bin/bash
input='input/hrc_sample'
output='input_unzipped/hrc_sample'

mkdir -p $output

for f in `ls $input|grep .gz$`; do
  fp=$input/$f
  STEM=$(basename "${fp}" .gz)
  echo unzipping ${fp} `date`
  gunzip -c "${fp}" > $output/"${STEM}"
done
