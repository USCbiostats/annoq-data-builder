import argparse
import csv
import json
from decode_pickle import write_to_pickle, write_to_json
from typing import List
from intervaltree import IntervalTree, Interval
from collections import defaultdict


def main():
    parser = parse_arguments()
    input_csv = parser.input_csv
    delimiter = parser.delimiter if parser.delimiter else '\t'
    output_pkl = parser.output_pkl

    table = pd.read_csv(input_csv, sep=delimiter)
    table.set_index("id", inplace=True, drop=False)

    # mappings = nested_dict()

    properties = dict()
    for index, row in table.iterrows():
        if row['field_type'] is not None and row['field_type'] is not np.nan:
            properties[row['name']] = row['field_type']
            if row['field_type'].strip() == 'long': 
                row['field_type'] = 'int'
            
            elif row['field_type'].strip() == 'text':
                row['field_type'] = 'str'
                
            elif row['id'].strip() ==  'chr' or row['id'].strip() ==  'GWAS_catalog_pubmedid' or row['id'].strip() ==  'GRASP_PMID':
              row['field_type'] = 'str'     


    # mappings["properties"] = properties
    write_to_pickle(properties, output_pkl)


def nested_dict(): return defaultdict(nested_dict)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', dest='input_csv', required=True)
    parser.add_argument('-o', '--output', dest='output_pkl', required=True)
    parser.add_argument('-d', '--delimiter', dest='delimiter')

    return parser.parse_args()


if __name__ == "__main__":
    main()


# python3 tools/mappings_data_type_gen.py -i ./../annoq-data/annotation_tree.csv -o ./../annoq-data/doc_type.pkl -d ,
