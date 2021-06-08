import fileinput
import argparse
from utils import *
import pickle
import sys
from base import ROOT_DIR, load_json, load_pickle
from os import mkdir, path as ospath

col_names = ["genes",
             "assay",
             "tissue",
             "GO_molecular_function_complete_list",
             "GO_molecular_function_complete_list_id",
             "GO_biological_process_complete_list",
             "GO_biological_process_complete_list_id",
             "GO_cellular_component_complete_list",
             "GO_cellular_component_complete_list_id",
             "PANTHER_GO_SLIM_molecular_function_list",
             "PANTHER_GO_SLIM_molecular_function_list_id",
             "PANTHER_GO_SLIM_biological_process_list",
             "PANTHER_GO_SLIM_biological_process_list_id",
             "PANTHER_GO_SLIM_cellular_component_list",
             "PANTHER_GO_SLIM_cellular_component_list_id",
             "REACTOME_pathway_list",
             "REACTOME_pathway_list_id",
             "PANTHER_pathway_list",
             "PANTHER_pathway_list_id"]


def main():
    parser = parse_arguments()
    global ENHANCER_DIR
    enhancer_dir = parser.enhancer_dir
    vcf_path = parser.vcf_path

    annotation_file = ospath.splitext(ospath.basename(vcf_path))[0]
    annotation = load_json(ospath.join(enhancer_dir, annotation_file+'.json'))

    add_annotation(vcf_path, annotation, lambda x: print(x.rstrip()))


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-e', '--enhancer_dir', dest='enhancer_dir', required=True,
                        help='Panther Dir (panther_data, cor_data and annoq_tree)')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()


def in_region(pos, start, end):
    return pos >= start and pos <= end


def combine_interval_data_into_r(annotations, coor, ks):
    chrom, pos = coor[0], coor[1]
    r = [annotation for annotation in annotations
         if in_region(pos, annotation['start'], annotation['end'])]
    res = {}
    for i in r:
        for k in i['data']:
            res[k] = res.get(k, set()).union(i['data'][k])
    for k in ks:
        if not res.get(k):
            res[k] = '.'

    return [';'.join(res[k]) for k in ks]


def add_annotation(filepath, annotations, deal_res=print):

    with open(filepath) as fp:
        row = fp.readline().rstrip()
        add_cols = ['enhancer_linked_' + i for i in col_names]
        deal_res(add_record(row, add_cols))

        # add info
        while row:
            row = fp.readline()
            if not row:
                continue
            line = row.rstrip().split("\t")
            chrom, pos = line[0], int(line[1])
            coor = [chrom, pos]
            add_cols = combine_interval_data_into_r(
                annotations, coor, col_names)
            deal_res(add_record(row, add_cols))


if __name__ == "__main__":
    main()
