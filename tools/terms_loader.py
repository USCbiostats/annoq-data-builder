import csv
from os import path as ospath
import json
import argparse
from sys import path
from base import load_json
import pprint


def main():
    parser = parse_arguments()

    terms_file = parser.terms_filepath
    panther_file = parser.panther_file

    terms = load_terms(terms_file)
    panther_data = load_json(panther_file)

    #verify_terms_labels(terms, panther_data)
    #verify_terms_present(terms, panther_data)

    generate_terms_lookup(panther_data)


def generate_terms_lookup(panther_data):
    cols = panther_data['cols'][1:]
    data = panther_data['data']
    visited_terms = set()
    lookup = dict()

    for key, value in data.items():
        id_cols = value[1::2]
        label_cols = value[0::2]
        for i, id_col in enumerate(id_cols):
            labels = label_cols[i].split('|')
            for j, term_id in enumerate(id_col.split('|')):
                if term_id != "" and term_id not in visited_terms:
                    lookup[term_id] = {
                        'id': term_id,
                        'label': labels[j]
                    }
                    visited_terms.add(term_id)

    return lookup


def verify_terms_labels(terms, panther_data):
    cols = panther_data['cols'][1:]
    data = panther_data['data']
    visited_terms = set()

    print(f"ID \t Category Label \t  Genes Agg Labels")

    for key, value in data.items():
        id_cols = value[1::2]
        label_cols = value[0::2]
        for i, id_col in enumerate(id_cols):
            labels = label_cols[i].split('|')
            for j, term_id in enumerate(id_col.split('|')):
                # print(term)
                if term_id != "":
                    term = get_term(terms, term_id)
                    # print(term)
                    if term is not None and term['label'] != labels[j] and term_id not in visited_terms:
                        print(f"{term_id} \t {term['label']} \t  {labels[j]}")
                        visited_terms.add(term_id)
                        #raise ValueError(f"{term_id}not equal")

    print(f"Mismatch: {len(visited_terms)} terms")


def verify_terms_present(terms, panther_data):
    cols = panther_data['cols'][1:]
    data = panther_data['data']
    visited_terms = set()

    print(f"ID \t Label")

    for key, value in data.items():
        id_cols = value[1::2]
        label_cols = value[0::2]
        for i, id_col in enumerate(id_cols):
            labels = label_cols[i].split('|')
            for j, term_id in enumerate(id_col.split('|')):
                # print(term)
                if term_id != "":
                    term = get_term(terms, term_id)
                    # print(term)
                    if term_id not in visited_terms and term is None:
                        print(f"{term_id} \t {labels[j]}")
                        visited_terms.add(term_id)
                        #raise ValueError(f"{term_id}not equal")
    print(f"Not Found: {len(visited_terms)} terms")


def parse_arguments():
    """Parse the command line arguments

    Returns:
        [dict]: parsed arguments
    """
    parser = argparse.ArgumentParser(description='Loads genes, families aggs',
                                     epilog='It worked!')
    parser.add_argument('--terms', dest='terms_filepath',
                        required=True, help='Term Ids and labels file')
    parser.add_argument('--panther_file', dest='panther_file',
                        required=True, help='Panther File')

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
        #raise ValueError(f"{term_id} not found")
        # print(term_id)
        pass
    return term


def write_to_json(json_data, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        json.dump(json_data, outfile,  ensure_ascii=False, indent=4)


if __name__ == "__main__":
    main()
