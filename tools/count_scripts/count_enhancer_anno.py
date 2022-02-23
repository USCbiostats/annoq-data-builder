import argparse
import json
from os import path as ospath

""" The column names to include to be checked if there is any values """
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

occurrence_map = dict()


def main():
    parser = parse_arguments()
    vcf_path = parser.vcf_path

    fp = ospath.splitext(ospath.basename(vcf_path))[0]

    occurrence_map['file'] = fp
    occurrence_map['total'] = 0

    count_rows(vcf_path, col_names)

    print(json.dumps(occurrence_map, indent=2))


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()


def count_rows(filepath, col_names):
    """ First it makes the first row the header map for index search 
    later on. Streams each row and to count the occurrences

    Args:
        filepath (_type_): _description_
        col_names (_type_): _description_
    """
    with open(filepath) as fp:
        row = fp.readline().rstrip()
        col_map = map_col(row, col_names)

        # initialize the map with total of 0 for the each solumn name
        for col_name in col_names:
            occurrence_map[col_name] = 0

        while row:
            row = fp.readline().rstrip()
            if row:
                count_row(row, col_map)


def count_row(row, col_map):
    line = row.rstrip().split("\t")
    annotated = False

    # count if at least one is true
    for col in col_map.items():
        annotated |= is_annotated(line, col)

    if annotated:
        occurrence_map['total'] += 1


def map_col(row, col_names):
    line = row.rstrip().split("\t")
    col_map = {col_name: line.index(col_name)
               for col_name in col_names}

    return col_map


def is_annotated(annotation, d):
    """ Adds the occurrence if the the cell has a value

    Args:
        annotation (list<string>): line  of the annotation row as list
        d (tuple (key: value)): column map item with column name, column index)

    Returns:
        _type_: _description_
    """
    if annotation[d[1]] is not None and annotation[d[1]] != "" and len(annotation[d[1]].strip()) > 2:
        occurrence_map[d[0]] += 1
        return True
    else:
        return False


if __name__ == "__main__":
    main()
