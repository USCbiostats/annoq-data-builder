#!/bin/bash 

wgsa_dir='./../wgsa_095'

set -e

cd $wgsa_dir

cd annovar20200608
tar -zxvf ../../downloads/annovar.latest.tar.gz --directory .
cd annovar

