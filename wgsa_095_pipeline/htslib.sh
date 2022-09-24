#!/bin/bash 

set -e
((!$#)) && echo No arguments supplied! && exit 1

wgsa_dir=$1

cd $wgsa_dir
cd htslib

tar -vxjf ../../downloads/htslib-1.9.tar.bz2  --directory .
cd htslib-1.9
sudo make prefix=/usr/ install