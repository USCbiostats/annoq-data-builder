import argparse
import csv
import json
from coord_to_intervaltree import foo, parser
from decode_pickle import write_to_pickle, write_to_json
from typing import List
from intervaltree import IntervalTree, Interval
from collections import defaultdict


# python3 tools/coord_to_intervaltree.py -p Homo_sapiens.GRCh38.pep.all.fa -i UP000005640_9606.idmapping > parsed_coords.tsv

ensembl_to_uniprot = {}
uniprot_to_hgnc = {}

if __name__ == "__main__":
    args = parser.parse_args()

    itree = foo(args)
    count = 0
    skipped = 0
    for i in itree:
        count += 1
        if not i.hgnc_id:
            skipped += 1

    print(count)
    print('skipped', skipped)
