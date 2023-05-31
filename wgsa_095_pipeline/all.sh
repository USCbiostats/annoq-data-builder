#!/bin/bash 

set -e

wgsa_dir='./../wgsa_095'

bash create_dir.sh $wgsa_dir
bash annovar.sh $wgsa_dir
bash snpeff.sh $wgsa_dir
bash vep.sh $wgsa_dir
bash htslib.sh $wgsa_dir
