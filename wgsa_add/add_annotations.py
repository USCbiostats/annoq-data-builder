import argparse
from os import path as ospath
from collections import defaultdict
from wgsa_add.clean_annotations import clean_line
from wgsa_add.utils import *
from wgsa_add.base import load_json, load_pickle
from wgsa_add.add_panther_anno import add_annotation_header as add_panther_annotation_header
from wgsa_add.add_panther_anno import add_annotation_row as add_panther_annotation_row
from wgsa_add.add_enhancer_anno import add_annotation_header as add_enhancer_annotation_header
from wgsa_add.add_enhancer_anno import add_annotation_row as add_enhancer_annotation_row


def nested_dict(): return defaultdict(nested_dict)


def main():
    parser = parse_arguments()
    enhancer_dir = parser.enhancer_dir
    panther_dir = parser.panther_dir
    vcf_path = parser.vcf_path

    annoq_tree = load_pickle(ospath.join(panther_dir, 'annoq_tree.pkl'))
    panther_data = load_json(ospath.join(panther_dir, 'panther_data.json'))
    coord_data = load_json(ospath.join(panther_dir, 'coords_data.json'))

    annotation_file = ospath.splitext(ospath.basename(vcf_path))[0]
    annotation = load_json(ospath.join(enhancer_dir, annotation_file+'.json'))

    gene_coords = {i[2]: (i[1][1], i[1][2]) for i in coord_data}
    # [ENSG_id, (contig, start, end), HGNC_id]

    add_annotations(vcf_path, annotation, annoq_tree, panther_data, gene_coords)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--enhancer_dir', dest='enhancer_dir', required=True,
                        help='Panther Dir (panther_data, cor_data and annoq_tree)')
    parser.add_argument('-p', '--panther_dir', dest='panther_dir', required=True,
                        help='Panther Dir (panther_data, cor_data and annoq_tree)')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()


def add_annotations(filepath, annotations, annoq_tree, panther_data, gene_coords):

    tool_idxs = {}
    with open(filepath) as fp:
        row = fp.readline().rstrip()

        cols = add_panther_annotation_header(row, 
                                             panther_data, 
                                             tool_idxs=tool_idxs)
        cols += add_enhancer_annotation_header()

        print_line(add_record(row, cols))
        # add info
        while row:
            row = fp.readline().rstrip()
            if row:
                cols = add_panther_annotation_row(row, annoq_tree, panther_data, gene_coords,
                                                  tool_idxs=tool_idxs)
                cols += add_enhancer_annotation_row( row, annotations)

                record = add_record(row, cols).strip()
                cleaned_record = clean_line(record)
                print(cleaned_record)


if __name__ == "__main__":
    main()


#python3 -m wgsa_add.add_annotations -f ./resources/test_wgsa_add/input/chr2.vcf -p resources/panther -e ./../annoq-data/enhancer/enhancer_map/ > resources/test_wgsa_add/output/chr2.vcf