import csv
import json
import argparse
import time
from os import path
from base import load_json
from terms_loader import generate_terms_lookup, get_term
from os import mkdir, path as ospath

parser = argparse.ArgumentParser()
parser.add_argument('-f', "--raw-file", type=str, required=False)
parser.add_argument('--panther_file', dest='panther_file',
                    required=True, help='Panther File')
parser.add_argument('-e', "--enhancer_file")
parser.add_argument('-o', "--out_json")
parser.add_argument("--parse-col", action="store_true")

output_columns = [
    "chrNum",
    "start",
    "end",
    "enhancer",
    "linkID",
    "gene",
]

TERMS_LOOKUP = None
COORDINATES_LOOKUP = None
PANTHER_LOOKUP = None
OUT_JSON = None


def create_working_dir(directory):
    try:
        mkdir(directory)
        print(directory + "(temp work output directory) created")
    except:
        print('json path exists')


def set_default(obj):
    if isinstance(obj, set):
        return list(obj)
    raise TypeError


def writeout(filepath, jsons):
    with open(filepath, "w") as j:
        json.dump(jsons, j, indent=4)


class EnahancerGene:
    global PANTHER_LOOKUP

    def __init__(self, records=[]) -> None:
        self.records = records
        self.record = dict()
        self.genes = set()

    def compare_enhancer(self, a, b):
        return a["chrNum"] == b["chrNum"] and \
            a["start"] == b["start"] and \
            a["end"] == b["end"]

    def add_record(self, record):
        if not self.record:
            self.record = record

        if self.compare_enhancer(self.record, record):
            self.genes.add(record['gene'])
        else:
            self.record['data'] = self.add_enhancer_genes(self.genes)
            self.records.append({**self.record, **{'genes': list(self.genes)}})
            self.reset_record()

    def get_hgnc_id(self, gene_id):
        if gene_id == None:
            return gene_id

        idx_parts = gene_id.split('|')
        if len(idx_parts) > 1:
            return idx_parts[1].replace('=', ':')

        return gene_id.strip()

    def add_enhancer_genes(self, genes):
        panther_lookup = PANTHER_LOOKUP

        cols = panther_lookup['cols'][1:]
        id_headers = cols[1::2]
        label_headers = cols[0::2]
        panther_data = panther_lookup['data']
        data = dict()

        hgnc_ids = [self.get_hgnc_id(gene) for gene in genes]

        for hgnc_id in hgnc_ids:
            annotations = panther_data.get(hgnc_id) or []
            #print(hgnc_id, self.get_hgnc_id(hgnc_id), annotations)

            id_cols = annotations[1::2]
            for i, id_col in enumerate(id_cols):
                data[id_headers[i]] = list()
                data[label_headers[i]] = list()
                for term_id in id_col.split('|'):
                    if term_id != "" and term_id not in data[id_headers[i]]:
                        term = TERMS_LOOKUP[term_id]
                        if term == None:
                            raise ValueError(f"{term_id}not equal")

                        data[label_headers[i]].append(term['label'])
                        data[id_headers[i]].append(term['id'])

        return data

    def reset_record(self):
        self.record.clear()
        self.genes.clear()

    def reset_records(self):
        self.records = []


def parse_enhancer_file(filepath):
    lookup = {}
    with open(filepath) as f:
        reader = csv.reader(f, delimiter="\t")
        for r in reader:
            # Ex: ['chr1', '99534632', '99534837', '1']
            lookup[r[3]] = {
                "chrNum": r[0],
                "start": r[1],
                "end": r[2],
            }
    return lookup


def parse_file(raw_file):
    # rows[0]
    # ['enhancer', 'gene', 'linkID', 'assay', 'tissue', 'p-value', 'eQTL_SNP_ID']
    # rows[3]
    # ['1', 'HUMAN|HGNC=15846|UniProtKB=Q9NP74', '1', '3', '66', '', '']
    # rows[20]
    # ['1', 'HUMAN|HGNC=15846|UniProtKB=Q9NP74', '1', '4', '53', '6e-08', '']
    start_time = time.time()

    bunchsize = 1000
    link_ids = set()
    enhancer_gene = EnahancerGene()

    with open(raw_file) as f:
        reader = csv.reader(f, delimiter="\t")
        col_map = next(reader)

        for r in reader:
            new_line = {}
            for idx, val in enumerate(r):
                if len(val) > 0:
                    if col_map[idx] == "linkID":
                        link_ids.add(val)
                    if col_map[idx] == "enhancer":
                        new_line = {**new_line, **COORDINATES_LOOKUP[val]}

                    new_line[col_map[idx]] = val

            json_line = {k: v for k, v in new_line.items()
                         if k in output_columns}

            enhancer_gene.add_record(json_line)

            if len(enhancer_gene.records) == bunchsize:
                print("writing files out")
                print("used time", time.time() - start_time, "s")
                writeout(ospath.join(OUT_JSON, '21.json'),
                         enhancer_gene.records)
                enhancer_gene.reset_records()
                # temp testing
                break


def check_file(file_path):
    if path.isfile(file_path):
        return True
    else:
        print("File path '" + file_path + "' does not exist.")
        return False


def main():
    args = parser.parse_args()
    panther_file = args.panther_file

    global COORDINATES_LOOKUP
    COORDINATES_LOOKUP = parse_enhancer_file(args.enhancer_file)

    global PANTHER_LOOKUP
    PANTHER_LOOKUP = load_json(panther_file)

    global TERMS_LOOKUP
    TERMS_LOOKUP = generate_terms_lookup(PANTHER_LOOKUP)

    global OUT_JSON
    OUT_JSON = args.out_json

    create_working_dir(OUT_JSON)

    parse_file(args.raw_file)


if __name__ == "__main__":
    main()
