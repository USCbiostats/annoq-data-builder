#!/bin/bash 

python3 tools/terms_loader.py \
--terms ../annoq-data/wgsa_add/terms.tsv \
--panther_file ../annoq-data/wgsa_add/panther_data.json \
--out_terms_file ../annoq-data/slim/terms.txt