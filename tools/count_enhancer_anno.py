import argparse
from os import path as ospath

col_names = ["enhancer_linked_genes",
             "enhancer_linked_assay",
             "enhancer_linked_enhancer",
             "enhancer_linked_GO_molecular_function_complete_list_id",
             "enhancer_linked_GO_biological_process_complete_list_id",
             "enhancer_linked_GO_cellular_component_complete_list_id",
             "enhancer_linked_PANTHER_GO_SLIM_molecular_function_list_id",
             "enhancer_linked_PANTHER_GO_SLIM_biological_process_list_id",
             "enhancer_linked_PANTHER_GO_SLIM_cellular_component_list_id",
             "enhancer_linked_REACTOME_pathway_list_id",
             "enhancer_linked_PANTHER_pathway_list_id"]

counts = dict()


def main():
    parser = parse_arguments()
    vcf_path = parser.vcf_path

    annotation_file = ospath.splitext(ospath.basename(vcf_path))[0]

    counts['file'] = annotation_file
    counts['total'] = 0

    count_rows(vcf_path, col_names)

    print(counts)


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()


def is_annotated(annotation, d):
    if annotation[d[1]] is not None and annotation[d[1]] != "" and len(annotation[d[1]].strip()) > 2:
        counts[d[0]] += 1
        return True
    else:
        return False


def count_rows(filepath, col_names):

    with open(filepath) as fp:
        row = fp.readline().rstrip()
        col_indices = get_column_indices(row, col_names)

        for col_name in col_names:
            counts[col_name] = 0

        while row:
            row = fp.readline().rstrip()
            if row:
                count_row(row, col_indices)


def get_column_indices(row, col_names):
    line = row.rstrip().split("\t")
    col_indices = {col_name: line.index(col_name)
                   for col_name in col_names}

    return col_indices


def count_row(row, col_indices):
    line = row.rstrip().split("\t")
    annotated = False

    for col_index in col_indices.items():
        annotated |= is_annotated(line, col_index)

    if annotated:
        counts['total'] += 1


if __name__ == "__main__":
    main()
