
import argparse
from os import path as ospath

col_names = ["assay",
             "enhancer",
             "GO_molecular_function_complete_list_id",
             "GO_biological_process_complete_list_id",
             "GO_cellular_component_complete_list_id",
             "PANTHER_GO_SLIM_molecular_function_list_id",
             "PANTHER_GO_SLIM_biological_process_list_id",
             "PANTHER_GO_SLIM_cellular_component_list_id",
             "REACTOME_pathway_list_id",
             "PANTHER_pathway_list_id"]

counts = dict()


def main():
    parser = parse_arguments()
    vcf_path = parser.vcf_path

    annotation_file = ospath.splitext(ospath.basename(vcf_path))[0]

    counts['total'] = 0

    count_rows(vcf_path, col_names)

    print(counts)


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()


def is_annotated(annotation, k):
    print(annotation[k])
    if annotation[k] is not None or annotation[k] != "":
        counts[k] += 1


def count_rows(filepath, col_names):

    with open(filepath) as fp:
        row = fp.readline().rstrip()
        col_indices = get_column_indices(row, col_names)
        for col_index in col_indices:
            counts[col_index] = 0
        while row:
            row = fp.readline().rstrip()
            if row:
                count_row(row, col_indices)


def get_column_indices(row, col_names):
    line = row.rstrip().split("\t")
    col_indices = [line.index(f'enhancer_linked_{col_name}')
                   for col_name in col_names]

    return col_indices


def count_row(row, col_indices):
    line = row.rstrip().split("\t")

    for col_index in col_indices:
        is_annotated(line, col_index)


if __name__ == "__main__":
    main()
