import argparse
import csv
import json
from typing import List
from intervaltree import IntervalTree, Interval


ensembl_to_uniprot = {}
uniprot_to_hgnc = {}
if __name__ == "__main__":
    args = parser.parse_args()

    with open(args.idmapping) as idf:
        reader = csv.reader(idf, delimiter="\t")
        for r in reader:
            if r[1] == "Ensembl":
                ensemble_id = r[2]
                uniprot_id = r[0]
                ensembl_to_uniprot[ensemble_id] = uniprot_id
            elif r[1] == "HGNC":
                hgnc_id = r[2]
                uniprot_id = r[0]
                uniprot_to_hgnc[uniprot_id] = hgnc_id

    itree = PantherIntervalTree()
    with open(args.pep_fasta) as ff:
        # Get chr, start, end, Ensembl ID
        # >ENSP00000484065.1 pep:known chromosome:GRCh38:22:42140205:42144577:-1 gene:ENSG00000205702.10 transcript:ENST00000612115.1 gene_biotype:polymorphic_pseudogene transcript_biotype:protein_coding gene_symbol:CYP2D7 description:cytochrome P450 family 2 subfamily D member 7 (gene/pseudogene) [Source:HGNC Symbol;Acc:HGNC:2624]
        for l in ff.readlines():
            if l.startswith(">"):
                pthr_interval = PantherInterval.parse_header(l)
                itree.add_interval(pthr_interval)

    if args.json:
        interval_jsons = [i.as_json() for i in itree]
        print(json.dumps(interval_jsons))
    else:
        [print(i) for i in itree]
