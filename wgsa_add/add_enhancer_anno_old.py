from utils import *
import pickle
import sys

col_names = [ "genes",
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

def combine_interval_data_into_r(coor, ks):
    chrom, pos = coor[0], coor[1]
    if not chrom in trees:
        r = []
    else:
        r = trees[chrom][pos]
    res = {}
    for i in r:
        for k in i.data:
            res[k] = res.get(k, set()).union(i.data[k])
    for k in ks:
        #print(k)
        if not res.get(k):
            res[k] = '.'
            
    return [';'.join(res[k]) for k in ks]

pickle_data = pickle.load(open('data/enhancer/enhancer_anno_interval_tree', 'rb'))
trees = pickle_data

def add_anno(f ,deal_res=print):
    col_line = f.readline().rstrip()
    add_cols = ['enhancer_linked_' + i for i in col_names]
    deal_res(add_record(col_line, add_cols))

    #add info
    for r in f:
        line = r.rstrip().split("\t")
        chrom, pos = line[0], int(line[1])
        coor = [chrom, pos]
        add_cols = combine_interval_data_into_r(coor, col_names)
        deal_res(add_record(r, add_cols))

import fileinput

add_anno(fileinput.input(), lambda x: print(x.rstrip()))
