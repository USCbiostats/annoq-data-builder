import argparse
import csv
import json
from decode_pickle import write_to_pickle, write_to_json
from typing import List
from intervaltree import IntervalTree, Interval
from collections import defaultdict

VALID_FORMATS = ['tree', 'coords']


parser = argparse.ArgumentParser()
parser.add_argument('-p', '--pep_fasta')
parser.add_argument('-i', '--idmapping')
parser.add_argument('-o', '--out_json')

parser.add_argument('-f', '--format', choices=VALID_FORMATS, default=VALID_FORMATS[0] )

# python3 tools/coord_to_intervaltree.py -p Homo_sapiens.GRCh38.pep.all.fa -i UP000005640_9606.idmapping > parsed_coords.tsv


class PantherInterval:
    def __init__(self, ensembl_id, chr_num, start, end, strand, hgnc_id=None):
        self.interval = Interval(begin=start, end=end)
        self.ensembl_id = ensembl_id
        self.chr_num = chr_num
        self.start = start
        self.end = end
        self.strand = strand
        self.hgnc_id = hgnc_id

    def as_json(self):
        cd = [
            self.ensembl_id,
            [
                self.chr_num,
                self.start,
                self.end,
                self.strand
            ]
        ]
        if self.hgnc_id:
            cd.append(self.hgnc_id)
        return cd

    @classmethod
    def parse_header(cls, header_str: str):
        header_bits = header_str.split()
        coordinates = header_bits[2]
        field_name, build_name, chr_num, start, end, strand = coordinates.split(
            ":", maxsplit=5)
        gene_id = header_bits[3]
        field_name, ensembl_id = gene_id.split(":", maxsplit=1)
        ensembl_id = ensembl_id.split(".", maxsplit=1)[0]
        # Get HGNC ID
        hgnc_id = None
        if ensembl_id in ensembl_to_uniprot and ensembl_to_uniprot[ensembl_id] in uniprot_to_hgnc:
            hgnc_id = uniprot_to_hgnc.get(ensembl_to_uniprot[ensembl_id])
        return cls(ensembl_id, chr_num, int(start), int(end), strand, hgnc_id)

    def __str__(self):
        hgnc_id = ""
        if self.hgnc_id:
            hgnc_id = self.hgnc_id
        return "\t".join([self.ensembl_id, self.chr_num, str(self.start), str(self.end), self.strand, hgnc_id])


class PantherIntervalTree:
    def __init__(self):
        self.interval_tree = IntervalTree()
        self.intervals: List[PantherInterval] = []

    def add_interval(self, interval: PantherInterval):
        self.interval_tree.add(interval.interval)
        self.intervals.append(interval)

    def __iter__(self):
        return iter(self.intervals)


def add_flanking_region(interval: PantherInterval, annoq_tree):
    flanking_regions = [0, 1e4, 2e4]
    if not interval.hgnc_id:
        return

    for flanking_region in flanking_regions:
        if not annoq_tree[flanking_region][interval.chr_num][interval.strand]:
            annoq_tree[flanking_region][interval.chr_num][interval.strand] = IntervalTree()

        annoq_interval = Interval(begin=interval.start - flanking_region,
                                  end=interval.end + flanking_region,
                                  data=interval.hgnc_id)
        annoq_tree[flanking_region][interval.chr_num][interval.strand].add(
            annoq_interval)


def foo(args):
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
                if pthr_interval.hgnc_id:
                    itree.add_interval(pthr_interval)

    return itree


ensembl_to_uniprot = {}
uniprot_to_hgnc = {}

if __name__ == "__main__":
    args = parser.parse_args()

    itree = foo(args)
      
    
    if args.format == 'coords':
        interval_jsons = [i.as_json() for i in itree]   
        write_to_json(interval_jsons, args.out_json, indent=2) 
    elif args.format == 'tree':
        print("Building annoq_tree...")
        def nested_dict(): return defaultdict(nested_dict)
        annoq_tree = nested_dict()
        
        for i in itree:
            add_flanking_region(i, annoq_tree)
   
        write_to_pickle(annoq_tree, args.out_json)      
        
        # For Display Purposes Only
        write_to_json(annoq_tree,  args.out_json.replace(".pkl", ".json"), indent=2)