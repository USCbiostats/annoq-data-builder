import pandas as pd
import numpy as np
import json
import networkx as nx
import argparse
from collections import defaultdict

from tools.base import write_to_json

DTYPES = {
    'id': 'object',
    'leaf': 'boolean',
    'parent_id': 'object',
    'pmid': 'object'
}

class AnnoqTreeProcessor:
    def __init__(self, input_csv):
        self.tree_df = pd.read_csv(input_csv, sep=',', dtype=DTYPES)
        self.tree_df.set_index("id", inplace=True, drop=False)
        self.tree_df = self.tree_df[~self.tree_df['name'].str.endswith('_list')]

    def add_value_type(self):
        self.tree_df['value_type'] = self.tree_df.apply(lambda row: self._value_type(row['name']), axis=1)

    def _value_type(self, name):
        if '_list_id' in name:
            return 'term_id'
        return None

    def generate_graph(self):
        return nx.from_pandas_edgelist(self.tree_df, 'parent_id', 'id', create_using=nx.DiGraph())

    def to_csv_data(self):
        return self.tree_df

    def to_json_data(self):
        return [row.dropna().to_dict() for index, row in self.tree_df.iterrows()]

    def generate_mappings(self):
        mappings = self._nested_dict()
        for index, row in self.tree_df.iterrows():
            if pd.notna(row['field_type']):
                properties = mappings.setdefault("properties", {})
                properties[row['name']] = {'type': row['field_type']}
                if row['field_type'].strip() == 'text':
                    properties[row['name']]["fields"] = {
                        "keyword": {
                            "type": "keyword",
                            "ignore_above": 10000
                        }
                    }
        return mappings

    @staticmethod
    def _nested_dict():
        return defaultdict(dict)


def save_to_csv(data, filename):
    data.to_csv(filename, index=False)

def parse_arguments():
    parser = argparse.ArgumentParser(description='Process and Export AnnoQ Annotation Tree Data.')
    parser.add_argument('--input_csv', type=str, help='Input CSV file path')
    parser.add_argument('--output_csv', type=str, help='Output CSV file path')
    parser.add_argument('--output_json', type=str, help='Output JSON file path for table')
    parser.add_argument('--mappings_json', type=str, help='Output JSON file path for mappings')
    return parser.parse_args()

def main():
    args = parse_arguments()

    processor = AnnoqTreeProcessor(args.input_csv)
    processor.add_value_type()

    # Writing DataFrame to CSV
    csv_data = processor.to_csv_data()
    save_to_csv(csv_data, args.output_csv)
    
    # Writing DataFrame to JSON
    json_data = processor.to_json_data()
    write_to_json(json_data, args.output_json, indent=2)

    # Writing Mappings to JSON
    mappings_data = processor.generate_mappings()
    write_to_json(mappings_data, args.mappings_json, indent=2)


if __name__ == "__main__":
    main()


#python3 -m tools.annotation_tree_gen --input_csv ../annoq_data/input/annotation_tree.csv --output_csv ../annoq_data/output/annotation_tree.csv --output_json ../annoq_data/output/annotation_tree.json --mappings_json ../annoq_data/output/annotation_mappings.json