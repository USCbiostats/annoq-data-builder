

from os import path as ospath
from tsv2json import write_to_json
import pandas as pd
import numpy as np
import argparse
from collections import defaultdict


def main():
    parser = parse_arguments()
    input_csv = parser.input_csv
    delimiter = parser.delimiter if parser.delimiter else '\t'
    output_json = parser.output_json

    table = pd.read_csv(input_csv, sep=delimiter)
    table.set_index("id", inplace=True, drop=False)

    mappings = nested_dict()

    properties = dict()
    for index, row in table.iterrows():
        if row['field_type'] is not None and row['field_type'] is not np.nan:
            properties[row['name']] = {'type': row['field_type']}

            if row['field_type'].strip() == 'text':
                properties[row['name']]["fields"] = {
                    "keyword": {
                        "type": "keyword",
                        "ignore_above": 10000
                    }
                }

    mappings["properties"] = properties
    write_to_json(mappings, output_json)


def nested_dict(): return defaultdict(nested_dict)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', dest='input_csv', required=True)
    parser.add_argument('-o', '--output', dest='output_json', required=True)
    parser.add_argument('-d', '--delimiter', dest='delimiter')

    return parser.parse_args()


if __name__ == "__main__":
    main()


# python3 tools/mappings_gen.py -i ./../annoq-data/tree-with-types.csv -o ./../annoq-data/mapping-v2.json -d ,
