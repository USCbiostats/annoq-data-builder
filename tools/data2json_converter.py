import csv
import json
import argparse
from os import path

parser = argparse.ArgumentParser()
parser.add_argument('-f', "--raw-file", type=str, required=False)
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


class EnahancerGene:
    def __init__(self, records=[]) -> None:
        self.records = records
        self.record = dict()
        self.genes = set()

    def add_record(self, record):
        if not self.record:
            self.record = record

        if self.record['linkID'] == record['linkID']:
            self.genes.add(record['gene'])
        else:
            self.records.append({**self.record, **{'genes': list(self.genes)}})
            self.reset_record()

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


COORDINATES_LOOKUP = None
OUT_JSON = None


def writeout(jsons):
    with open(OUT_JSON, "w") as j:
        json.dump(jsons, j, indent=4)


def parse_file(raw_file):
    # rows[0]
    # ['enhancer', 'gene', 'linkID', 'assay', 'tissue', 'p-value', 'eQTL_SNP_ID']
    # rows[3]
    # ['1', 'HUMAN|HGNC=15846|UniProtKB=Q9NP74', '1', '3', '66', '', '']
    # rows[20]
    # ['1', 'HUMAN|HGNC=15846|UniProtKB=Q9NP74', '1', '4', '53', '6e-08', '']

    bunchsize = 1_00
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
                writeout(enhancer_gene.records)
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

    global COORDINATES_LOOKUP
    COORDINATES_LOOKUP = parse_enhancer_file(args.enhancer_file)
    global OUT_JSON
    OUT_JSON = args.out_json

    parse_file(args.raw_file)


if __name__ == "__main__":
    main()
