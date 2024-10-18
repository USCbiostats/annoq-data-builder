from os import path as ospath
from tsv2json import write_to_json
import pandas as pd
import numpy as np
import argparse
from collections import defaultdict
from decode_pickle import write_to_pickle

def main():
    parser = parse_arguments()
    input_csv = parser.input_csv
    delimiter = parser.delimiter if parser.delimiter else '\t'
    output_pkl = parser.output_pkl
    output_annot_tree = parser.anno_tree_json

    table = pd.read_csv(input_csv, sep=delimiter)
    table.set_index("id", inplace=True, drop=False)



    properties = dict()
    column_values = []
    for index, row in table.iterrows():
        if row['field_type'] is not None and row['field_type'] is not np.nan:
            properties[row['name']] = row['field_type']
            if row['field_type'].strip() == 'long': 
                properties[row['name']]  = 'int'
            
            elif row['field_type'].strip() == 'text':
                properties[row['name']] = 'str'
                
            elif row['id'] ==  'chr' or row['id'] ==  'GWAS_catalog_pubmedid' or row['id'] ==  'GRASP_PMID':
                properties[row['name']] = 'str'
                
        annot_tree = {}
        annot_tree['id'] = str(row['id'])
        if row['parent_id'] is not None and False == np.isnan(row['parent_id']):
            annot_tree['parent_id'] = str(int(row['parent_id']))
        
        annot_tree['leaf'] = row['leaf']
        annot_tree['name'] = row['name']
        if row['label'] is not None and row['label'] is not np.nan:
            annot_tree['label'] = row['label']
        
        if row['detail'] is not None and row['detail'] is not np.nan:
            annot_tree['detail'] = row['detail']
        
        if row['link'] is not None and row['link'] is not np.nan:
            annot_tree['link'] = row['link']
        
        if row['pmid'] is not None and False == np.isnan(row['pmid']):
            annot_tree['pmid'] = str(int(row['pmid']))
        
        if row['sort'] is not None and False == np.isnan(row['sort']):    
            annot_tree['sort'] = row['sort']
        
        if row['sample_url'] is not None and row['sample_url'] is not np.nan:
            annot_tree['sample_url'] = row['sample_url']
            
        if row['root_url'] is not None and row['root_url'] is not np.nan:
            annot_tree['root_url'] = row['root_url']            
            
        if row['field_type'] is not None and row['field_type'] is not np.nan:
            annot_tree['field_type'] = row['field_type']                    
        
        if row['keyword_searchable'] is not None and row['keyword_searchable'] is not np.nan:
            annot_tree['keyword_searchable'] = row['keyword_searchable']
        column_values.append(annot_tree)


    write_to_pickle(properties, output_pkl)
    #write_to_json(properties, "pickle_in_json_format")
    write_to_json(column_values, output_annot_tree)

def nested_dict(): return defaultdict(nested_dict)


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', dest='input_csv', required=True)
    parser.add_argument('-o', '--output', dest='output_pkl', required=True)
    parser.add_argument('-a', '--anno_tree', dest='anno_tree_json', required=True)    
    parser.add_argument('-d', '--delimiter', dest='delimiter')

    return parser.parse_args()


if __name__ == "__main__":
    main()


# python3 tools/mappings_data_type_gen.py -i ./../annoq-data/annotation_tree.csv -a ./../annoq-data/anno_tree.json  -o ./../annoq-data/doc_type.pkl -d ,
