from utils import *
import pickle
import sys

pickle_data = pickle.load(open('panther_anno_tree_12_20.pkl', 'rb'))
panther_data = pickle_data['panther_data']
#need pickle data panther_anno_tree.pkl
#pickle data build by mk_panther_anno_tree.py
gene_cor_dict = {i[2]:(i[1][1] ,i[1][2]) for i in pickle_data['cor_data']}
#[ENSG_id, (contig, start, end), HGNC_id]

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
        raise   ``
    return min_g
    
def add_panther_anno_record(r, anno_tree, panther_data, ext=0, strand = ['-1', '1']):
    (chrom, pos) = parse_tab_anno_record(r)
    pids = []
    for s in strand:
        pids += [i.data for i in anno_tree[ext][chrom][s][pos]]
    pids = list(set(pids))
    if len(pids) > 0:
        #return combine_panther_record([pids[0]], panther_data)
        return combine_panther_record([get_nearest_gene(gene_cor_dict, pids, int(pos))], panther_data)
    else:
        return combine_panther_record([], panther_data)

def add_tool_based_anno_record(r, idx, tool_type, panther_data):
    if 'ensembl_Gene_ID' in tool_type:
        convert_tool = convert_tools['ensembl_Gene_ID']
    else:
        convert_tool = convert_tools['refseq_Transcript_ID']
    items = r.split("\t")
    pids = list(set([convert_tool(gene) for gene in items[idx].split('|') if convert_tool(gene)]))
    return combine_panther_record(pids, panther_data)

def get_tools_prefix(tool_name):
    name = tool_name.split("_")
    return name[0] + "_" + name[1] + "_"

def add_anno(f, pickle_data, panther_data, deal_res=print):
    exts = [0, 1e4, 2e4]
    anno_tools_cols = [	'ANNOVAR_ensembl_Gene_ID', 
 			'ANNOVAR_refseq_Transcript_ID', 
 			'SnpEff_ensembl_Gene_ID', 
 			'SnpEff_refseq_Transcript_ID', 
 			'VEP_ensembl_Gene_ID', 
 			'VEP_refseq_Transcript_ID']
    #make column names
    col_line = f.readline().rstrip()
    col_names = col_line.split("\t")
    add_cols = []
    tool_idxs = {}
    for ext in exts:
	    add_cols += ['flanking_' + str(int(ext)) + '_' + i for i in panther_data['cols'][1:]]
    for tool_type in anno_tools_cols:
            add_cols += [get_tools_prefix(tool_type) + i for i in panther_data['cols'][1:]]
            tool_idxs[tool_type] = col_names.index(tool_type)
    deal_res(add_record(col_line, add_cols))

    #add info
    for r in f:
        add_cols = []
        for ext in exts:
            add_cols += add_panther_anno_record(r, pickle_data['GRCh37_PANTHER_anno_tree'], panther_data, ext=ext)
        for tool_type in anno_tools_cols:
            add_cols += add_tool_based_anno_record(r, tool_idxs[tool_type], tool_type, panther_data)
        deal_res(add_record(r, add_cols))

import fileinput
add_anno(fileinput.input(), pickle_data, panther_data, lambda x: print(x.rstrip()))
