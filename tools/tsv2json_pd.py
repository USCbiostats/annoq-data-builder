
import json
import csv
from os import path as ospath
from tsv2json import write_to_json
import pandas as pd
import argparse

DTYPES = {
    'id': 'object',
    'leaf': 'boolean',
    'parent_id': 'object',
    'pmid': 'object'

}


def main():
    parser = parse_arguments()
    input_csv = parser.input_csv
    delimiter = parser.delimiter if parser.delimiter else '\t'
    output_json = parser.output_json

    table = pd.read_csv(input_csv, dtype=DTYPES, sep=delimiter)
    table.set_index("id", inplace=True, drop=False)
    # table.to_json(orient="records", indent=2)

    table_json = [row.dropna().to_dict() for index, row in table.iterrows()]

    write_to_json(table_json, output_json)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', dest='input_csv', required=True)
    parser.add_argument('-o', '--output', dest='output_json', required=True)
    parser.add_argument('-d', '--delimiter', dest='delimiter')

    return parser.parse_args()


if __name__ == "__main__":
    main()


# python3 tools/tsv2json.py -i ./../annoq-data/slim-hrc-res/chr21.vcf -o ./../annoq-data/tmp5_
# python3 tools/tsv2json_pd.py -i ./../annoq-data/tree.csv -o ./../annoq-data/anno_tree.json -d ,
