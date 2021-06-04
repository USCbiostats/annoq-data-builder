import csv
import time
from os import mkdir, path as ospath
import json
import argparse
import shutil
import pandas as pd
from sys import path


def main():
    parser = parse_arguments()
    terms_file = parser.terms_filepath
    terms = load_terms(terms_file)


def parse_arguments():
    """Parse the command line arguments

    Returns:
        [dict]: parsed arguments
    """
    parser = argparse.ArgumentParser(description='Loads genes, families aggs',
                                     epilog='It worked!')
    parser.add_argument('--terms', dest='terms_filepath',
                        required=True, help='Term Ids and labels file')

    return parser.parse_args()


def load_terms(terms_file: path):
    """Loads the terms from a tsv file and makes a map with key of term id 

    Args:
        terms_file (path): file path to the tsv term file

    Returns:
        dict: the term map {id: {id, label}} dictionary
    """

    terms = {}

    with open(terms_file, encoding='utf-8') as tsvf:
        csvReader = csv.DictReader(tsvf, delimiter="\t")

        for rows in csvReader:
            term = rows.get('accession')
            label = rows.get('name')
            terms[term] = {
                'id': term,
                'label':  label
            }

    return terms


def get_term(terms, term_id):
    """Gets the term details from the terms map.

    If no match, the label will be the id 

    Args:
        terms (dict): the term map {id: {id, label}} dictionary
        term_id ([type]): term id to search with

    Returns:
        [type]: the term detail  {id, label} dictionary
    """
    term = terms.get(term_id)

    if term == None:
        raise ValueError(f"{term_id} not found")

    return term


def write_to_json(json_data, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        json.dump(json_data, outfile,  ensure_ascii=False, indent=4)


if __name__ == "__main__":
    main()
