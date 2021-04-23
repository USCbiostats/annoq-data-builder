#!/bin/bash 

python3 tools/coord_to_intervaltree.py \
-p ../annoq-data/Homo_sapiens.GRCh37.75.pep.all.fa \
-i ../annoq-data/UP000005640_9606.idmapping --json \
> ../annoq-data/coords_data.json