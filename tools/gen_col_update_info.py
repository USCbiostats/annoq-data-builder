import argparse
import pandas as pd
import sys

COLS = ['id',
        'parent_id',
        'leaf',
        'name',
        'label',
        'detail',
        'link',
        'pmid',
        'sort',
        'root_url',
        'sample_url',
        'field_type',
        'keyword_searchable',
        'value_type',
        'version']

PARENT_ID_GNOM_AD = '330'

class ColDataProcessor:
    def __init__(self, input_csv, col_desc_file_path, output_csv, updated_unknown_csv, fixed_csv):
        self.table = pd.read_csv(input_csv, sep=',', header=0, usecols=COLS)
        self.table.reset_index()
        self.table_fixed = self.table.copy()               #Keep track of current values to output for updating purposes
        
        max_id = 0
        
        #Parse existing file and determine columns
        cur_name_to_detail = dict()
        name_to_row = dict()
             
        for row in range(len(self.table)):
            # Get maximumn id
            if pd.isnull(self.table.loc[row, 'id']) is False:
                id_str = str(self.table.loc[row, 'id'])
                if int(id_str) > max_id:
                    max_id = int(id_str)  
                    
            # Skip Top level hierarchy items
            if  pd.isnull(self.table.loc[row]['sort']) is False:
                continue
            
            # Skip if name or detail is not defined
            name = self.table.loc[row]['name']               
            if pd.isnull(name) or  pd.isnull(self.table.loc[row]['detail']):
                continue
            
            # Skip enhancer, go, panther and reactome fields 
            lower_name = name.lower()
            if lower_name.find('enhancer_linked') >= 0 or lower_name.find('_go_') >= 0 or lower_name.find('_panther_') >= 0 or lower_name.find('_reactome_') >= 0:
                continue 
            cur_name_to_detail[self.table.loc[row, 'name']] = self.table.loc[row, 'detail']
            name_to_row[str(self.table.loc[row, 'name'])] = row
        
        with open(col_desc_file_path) as file:
            desc_lines = [line.rstrip() for line in file]    
        
        # build lookup with new labels
        new_name_to_detail = dict()
        
        num_lines =len(desc_lines)
        previous_line = ''
        for i in range(0, num_lines):
            cur_line = desc_lines[i]
            cur_line.replace('"', '\"')
            cur_line_modified = (cur_line.strip())
            if cur_line.find('\t\t') == 0:
                previous_line = previous_line +  ' ' + cur_line_modified
                line = previous_line
            elif cur_line.find('\t') == 0:
                line = cur_line_modified
                previous_line = ''
            else:
                line = ''
                previous_line = ''

            if line == '':
                continue
            
            if i < num_lines and desc_lines[i + 1].find('\t\t') == 0:
                previous_line = line
                continue
            
            index = line.find(':')
            if index > 0:
                new_name_to_detail[(line[:index]).strip()] = '\"' + line[index+1:].strip() + '\"'  
               
              
        new_lines = []
        modified_lines = []
        start_id = max_id + 100
        for key, value in new_name_to_detail.items():
            prev_value = cur_name_to_detail.get(key)
            if  prev_value is None:
                str_id = str(start_id)
                if key.find('gnomAD') >=0 and value.find('allele frequency') >=0:
                    new_lines.append(str_id + ',' + PARENT_ID_GNOM_AD + ',TRUE,' + key + ',,' + value + ',,,,,,float,TRUE,,')
                    new_row = {'id':str_id, 'parent_id':PARENT_ID_GNOM_AD, 'leaf':'TRUE', 'name':key, 'detail': value, 'field_type':'float', 'keyword_searchable': 'TRUE'}
                    self.table_fixed.loc[len(self.table_fixed)] = new_row
                                                                    
                elif  key.find("gnomAD") >=0:
                    new_lines.append(str_id + ',' + PARENT_ID_GNOM_AD + ',TRUE,' + key + ',,' + value + ',,,,,,,,,')
                    new_row = {'id':str_id, 'parent_id':PARENT_ID_GNOM_AD, 'leaf': 'TRUE', 'name':key, 'detail': value}
                    self.table_fixed.loc[len(self.table_fixed)] = new_row                   
                                         
                elif  value.find("allele frequency") >=0:
                    new_lines.append(str_id + ',,TRUE,' + key + ',,' + value + ',,,,,,float,,,')
                    new_row = {'id':str_id, 'detail': value, 'leaf':'TRUE', 'name':key, 'field_type':'float'}
                    self.table_fixed.loc[len(self.table_fixed)] = new_row
                    
                else:
                    new_lines.append(str_id + ',,TRUE,' + key + ',,' + value + ',,,,,,,,,')
                    new_row = {'id':str_id, 'detail': value, 'leaf':'TRUE', 'name':key}
                    self.table_fixed.loc[len(self.table_fixed)] = new_row
                                        
                start_id = start_id + 1
            elif prev_value != value:

                '''
                sys.stdout.write("updating for id " + str(name_to_row.get(key)) + " from " + prev_value + " to new value " + value + "\n")
                sys.stdout.write("Size of table :" + str(len(self.table_fixed.index)))
                sys.stdout.write("Actual value being updated " + str(self.table_fixed.loc[name_to_row.get(key), 'detail']) + "\n")
                '''
                #sys.stdout.write("updating for " + str(name_to_row[key]) + " current value " +  self.table_fixed.at[str(name_to_row[key]), 'detail']  + " new value " + value + "\n")
                #Setting value at row, column
                self.table_fixed.at[name_to_row[key], 'detail'] = value
                
                mod_str = ''
                for col in COLS:
                    if mod_str != '':
                        mod_str = mod_str + ',' 
                    if pd.isnull(self.table_fixed.loc[name_to_row[key], col]) is False:
                        mod_str = mod_str + str(self.table_fixed.loc[name_to_row[key], col])
                    
                
                modified_lines.append(mod_str)
                #modified_lines.append(',,,,' + key + ',,' + value + ',,,,,,,,,')
                continue
            
        if len(modified_lines) > 0:
            modified_lines.insert(0, ",".join(COLS))
            modified_lines.insert(0, "Data with details that should be Modified as indicated")    
                
        with open(input_csv) as file:
            cur_lines = [line.rstrip() for line in file]
        cur_lines.extend(new_lines)
        
        
        with open(output_csv, 'w') as f:
            for line in cur_lines:
                f.write(f"{line}\n")
                
        unknown_lines = []                       
        for key, value in cur_name_to_detail.items():
            if  new_name_to_detail.get(key) is None:
                
                unknown_str = ''
                for col in COLS:
                    if unknown_str != '':
                        unknown_str = unknown_str + ',' 
                    if pd.isnull(self.table.loc[name_to_row[key], col]) is False:
                        unknown_str = unknown_str + str(self.table.loc[name_to_row[key], col])                
                
                unknown_lines.append(unknown_str)
            else:
                continue
            
        if len(unknown_lines) > 0:
            unknown_lines.insert(0, ",".join(COLS))            
            unknown_lines.insert(0, "Removed fields")
                 
        modified_lines.extend(unknown_lines)    
            
        with open(updated_unknown_csv, 'w') as f:
            for line in modified_lines:
                f.write(f"{line}\n")
                
        save_to_csv(self.table_fixed, fixed_csv)                                            


def save_to_csv(data, filename):
    data.to_csv(filename, index=False)  

def parse_arguments():
    parser = argparse.ArgumentParser(description='Compare column names from input file with description from chromosome output file from wgsa and output new file with newly added columns and output columns that harve been removed or ones where the label has been updated')
    parser.add_argument('--input_csv', type=str, help='Input CSV file path')
    parser.add_argument('--col_desc_file_path', type=str, help='Column description file path')
    parser.add_argument('--output_csv', type=str, help='Output CSV file path')
    parser.add_argument('--updated_unknown_csv', type=str, help='Updated and or Unknown CSV file path')
    parser.add_argument('--fixed_csv', type=str, help='Fixed CSV file path')    
    return parser.parse_args()

def main():
    args = parse_arguments()
    processor = ColDataProcessor(args.input_csv, args.col_desc_file_path, args.output_csv, args.updated_unknown_csv, args.fixed_csv)

#Different versions of annotation_tree.csv are generated.  Use the information in these files to manually update the version in https://github.com/USCbiostats/annoq-site/blob/master/metadata/annotation_tree.csv
# updated_annotation_tree.csv should be used to overwrite https://github.com/USCbiostats/annoq-site/blob/master/metadata/annotation_tree.csv and dependant files should be re-genrated
#python3 -m tools.gen_col_update_info --input_csv ../annoq_data/input/annotation_tree.csv --col_desc_file_path ../annoq_data/input/chr21.annotated.snp.description.txt --output_csv ../annoq_data/output/modified_updated_annotation_tree.csv --updated_unknown_ /home/muruganu/projects/temp/annoq-data-builder/annotation_tree_updated_unknown.csv       

if __name__ == "__main__":
    main()