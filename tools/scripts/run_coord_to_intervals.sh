#!/bin/bash 

python3 tools/coord_to_intervaltree.py \
-p ./../annoq_data/input/Homo_sapiens.GRCh38.pep.all.fa \
-i ./../annoq_data/input/UP000005640_9606.idmapping --json \
-o ./../annoq_data/output/annoq_tree.pkl