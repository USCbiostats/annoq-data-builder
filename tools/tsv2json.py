
import json
import csv
from os import path as ospath
import argparse


def main():
    parser = parse_arguments()
    input_csv = parser.input_csv
    delimiter = parser.delimiter if parser.delimiter else '\t'
    output_json = parser.output_json

    data = load_csv_to_json(input_csv, delimiter)
    write_to_json(data, output_json)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', dest='input_csv', required=True)
    parser.add_argument('-o', '--output', dest='output_json', required=True)
    parser.add_argument('-d', '--delimiter', dest='delimiter')

    return parser.parse_args()


def load_csv_to_json(csv_filepath, delimiter='\t'):

    data = []

    with open(csv_filepath, encoding='utf-8') as csvf:
        csvReader = csv.DictReader(csvf, delimiter=delimiter)

        for row in csvReader:
            data.append(row)
    return data


def write_to_json(data, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile,
                  ensure_ascii=False, indent=4)


if __name__ == "__main__":
    main()


# python3 tools/tsv2json.py -i ./../annoq-data/slim-hrc-res/chr21.vcf -o ./../annoq-data/tmp5_
# python3 tools/tsv2json.py -i ./../annoq-data/tree.csv -o ./../annoq-data/anno_tree.json -d ,


# python3 tools/tsv2json.py -i ./resources/test_wgsa_add//output/chr18.vcf -o ./resources/test_wgsa_add/output_json/chr18.json