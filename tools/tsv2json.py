
import json
import csv
from os import path as ospath
import argparse


def main():
    parser = parse_arguments()
    input_csv = parser.input_csv
    output_json = ospath.join(parser.output_json, 'out21.json')

    data = load_csv_to_json(input_csv)
    write_to_json(data, output_json)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', dest='input_csv', required=True)
    parser.add_argument('-o', '--output', dest='output_json', required=True)

    return parser.parse_args()


def load_csv_to_json(csv_filepath):

    data = []

    with open(csv_filepath, encoding='utf-8') as csvf:
        csvReader = csv.DictReader(csvf, delimiter='\t')

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
