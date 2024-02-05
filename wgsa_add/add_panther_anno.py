import argparse
from os import path as ospath
from collections import defaultdict
from wgsa_add.base import load_json, load_pickle
from wgsa_add.utils import add_record, convert_tools, print_line

def nested_dict(): return defaultdict(nested_dict)


EXTS = [0, 1E4, 2E4]
ANNO_TOOLS_COLS = [	'ANNOVAR_ensembl_Gene_ID',
                    'ANNOVAR_refseq_Transcript_ID',
                    'SnpEff_ensembl_Gene_ID',
                    'SnpEff_refseq_Transcript_ID',
                    'VEP_ensembl_Gene_ID',
                    'VEP_refseq_Transcript_ID']


def main():
    parser = parse_arguments()
    panther_dir = parser.panther_dir
    vcf_path = parser.vcf_path

    annoq_tree = load_pickle(ospath.join(panther_dir, 'annoq_tree.pkl'))
    panther_data = load_json(ospath.join(panther_dir, 'panther_data_no_labels.json'))
    coord_data = load_json(ospath.join(panther_dir, 'coords_data.json'))

    gene_coords = {i[2]: (i[1][1], i[1][2]) for i in coord_data}
    # [ENSG_id, (contig, start, end), HGNC_id]

    add_annotations(vcf_path, annoq_tree, panther_data, gene_coords)


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-p', '--panther_dir', dest='panther_dir', required=True,
                        help='Panther Dir (panther_data, cor_data and annoq_tree)')
    parser.add_argument('-f', '--vcf_path', dest='vcf_path', required=True,
                        help='VCF file')

    return parser.parse_args()



def get_dist(g_name, gene_cor_dict, pos):
    if not g_name in gene_cor_dict:
        return float('inf')
    start, end = gene_cor_dict[g_name]
    start, end = int(start), int(end)
    return min(abs(start - pos), abs(end - pos))


def get_nearest_gene(gene_cor_dict, pids, pos):
    dis_list = [(g, get_dist(g, gene_cor_dict, pos)) for g in pids]
    min_g, min_d = '', float('inf')
    for g, d in dis_list:
        if d < min_d:
            min_d = d
            min_g = g
    if min_d == float('inf'):
        raise ValueError('is not float ' + min_d)
    return min_g


def add_panther_anno_record(r, anno_tree, panther_data, gene_coords, ext=0, strand=['-1', '1']):
    (chrom, pos) = r.split("\t")[:2]
    pos = int(pos)
    pids = []
    for s in strand:
        pids += [i.data for i in anno_tree[ext][chrom][s][pos]]
    pids = list(set(pids))
    if len(pids) > 0:
        # return combine_panther_record([pids[0]], panther_data)
        return combine_panther_record([get_nearest_gene(gene_coords, pids, int(pos))], panther_data)
    else:
        return combine_panther_record([], panther_data)


def add_tool_based_anno_record(r, idx, tool_type, panther_data):
    if 'ensembl_Gene_ID' in tool_type:
        convert_tool = convert_tools['ensembl_Gene_ID']
    else:
        convert_tool = convert_tools['refseq_Transcript_ID']
    items = r.split("\t")
    pids = list(set([convert_tool(gene)
                     for gene in items[idx].split('|') if convert_tool(gene)]))
    return combine_panther_record(pids, panther_data)


def get_tools_prefix(tool_name):
    name = tool_name.split("_")
    return name[0] + "_" + name[1] + "_"


def add_annotation_header(row, panther_data, tool_idxs={}):

    col_names = row.split("\t")
    add_cols = []
    for ext in EXTS:
        add_cols += ['flanking_' + str(int(ext)) + '_' + i for i in panther_data['cols']]
    for tool_type in ANNO_TOOLS_COLS:
        add_cols += [get_tools_prefix(tool_type) +
                     i for i in panther_data['cols']]
        tool_idxs[tool_type] = col_names.index(tool_type)

    return add_cols


def add_annotation_row(row, annoq_tree, panther_data, gene_coords, tool_idxs={}):
    added_cols = []
    for ext in EXTS:
        added_cols += add_panther_anno_record(row, annoq_tree, panther_data, gene_coords, ext=ext)
    for tool_type in ANNO_TOOLS_COLS:
        added_cols += add_tool_based_anno_record(
            row, tool_idxs[tool_type], tool_type, panther_data)

    return added_cols


def add_annotations(filepath, annoq_tree, panther_data, gene_coords):

    tool_idxs = {}

    with open(filepath) as fp:
        # make column names
        row = fp.readline().rstrip()
        add_cols = add_annotation_header(row, panther_data, tool_idxs=tool_idxs)
        print_line(add_record(row, add_cols))
        # add info

        while row:
            row = fp.readline()
            if row:
                add_cols = add_annotation_row(row, annoq_tree, panther_data, gene_coords,  tool_idxs=tool_idxs)

                print_line(add_record(row, add_cols))
                
                
def combine_panther_record(ids, panther_data, sep='|'):
    panther_record_length = len(panther_data['cols']) 
    ids = [i for i in ids if i in panther_data['data']]
    if not ids:
        return ['.' for i in range(panther_record_length)]
    res = [[] for i in range(panther_record_length)]
    for pid in ids:
        anno = panther_data['data'][pid]
        for idx in range(0, panther_record_length):
            cur_data = anno[idx].split(sep)
            for i in range(len(cur_data)):
                if cur_data[i] == '.':
                    continue
                if not cur_data[i] in res[idx]:
                    res[idx].append(cur_data[i])
    for idx in range(len(res)):
        if not res[idx]:
            res[idx] = '.'
    return list(map(lambda x: sep.join(x), res))


if __name__ == "__main__":
    main()
