import argparse
from collections import defaultdict
from utils import *
from base import load_json, load_pickle
from os import mkdir, path as ospath
from add_panther_anno import exts, anno_tools_cols
from add_panther_anno import add_annotation_header as add_panther_annotation_header
from add_panther_anno import add_annotation_row as add_panther_annotation_row
from add_enhancer_anno import add_annotation_header as add_enhancer_annotation_header
from add_enhancer_anno import add_annotation_row as add_enhancer_annotation_row


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

    add_annotations(vcf_path, annotation, annoq_tree,
                    panther_data, gene_coords, lambda x: print(x.rstrip()))


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-e', '--enhancer_dir', dest='enhancer_dir', required=True,
                        help='Panther Dir (panther_data, cor_data and annoq_tree)')
    parser.add_argument('-p', '--panther_dir', dest='panther_dir', required=True,
                        help='Panther Dir (panther_data, cor_data and annoq_tree)')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()


def add_annotations(filepath, annotations, annoq_tree, panther_data, gene_coords, deal_res=print):

    tool_idxs = {}
    with open(filepath) as fp:
        row = fp.readline().rstrip()

        cols = add_panther_annotation_header(row, panther_data, deal_res=deal_res,
                                             tool_idxs=tool_idxs,
                                             exts=exts, anno_tools_cols=anno_tools_cols)
        cols += add_enhancer_annotation_header(row)

        deal_res(add_record(row, cols))
        # add info
        while row:
            row = fp.readline().rstrip()
            if row:
                cols = add_panther_annotation_row(row, annoq_tree, panther_data, gene_coords, deal_res=deal_res,
                                                  tool_idxs=tool_idxs, exts=exts, anno_tools_cols=anno_tools_cols)

                cols += add_enhancer_annotation_row(
                    row, annotations, deal_res=deal_res)

                deal_res(add_record(row, cols))


if __name__ == "__main__":
    main()
