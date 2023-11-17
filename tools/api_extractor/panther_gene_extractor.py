import argparse
import json
import logging
import requests
import sys

## Logger basic setup.
logging.basicConfig(level=logging.INFO)
LOG = logging.getLogger('extractor')
LOG.setLevel(logging.WARNING)

PANTHER_API_DOWNLOAD_GENOME_URL = "https://pantherdb.org/services/oai/pantherdb/downloadgenome?organism=9606&startIndex="
PANTHER_API_DOWNLOAD_GENOME_DEFAULT_START_INDEX = 1
PANTHER_API_DOWNLOAD_GENOME_MAX_ENTRIES = 1000

PANTHER_LONG_GENE_ID_NUM_PARTS = 3
PANTHER_LONG_GENE_ID_DELIM = "|"
PANTHER_LONG_GENE_GENE_INDEX = 1
PANTHER_LONG_GENE_GENE_DELIM = "="
PANTHER_LONG_GENE_GENE_ID_NUM_PARTS = 2

PANTHER_ID_DELIM = ":"

def exit_with_msg(instr):
    LOG.error(instr)
    sys.exit(1)
               
    
def format_gene_id(long_gene_id):
    if long_gene_id is None:
        return None
    parts = long_gene_id.split(PANTHER_LONG_GENE_ID_DELIM)
    if len(parts) < (PANTHER_LONG_GENE_GENE_INDEX + 1):
        return None
    gene_part = parts[PANTHER_LONG_GENE_GENE_INDEX]
    gene_parts = gene_part.split(PANTHER_LONG_GENE_GENE_DELIM)
    if  len(gene_parts) < PANTHER_LONG_GENE_GENE_ID_NUM_PARTS:
        return None
    return gene_parts[0] + PANTHER_ID_DELIM + gene_parts[1]
    
     
    
def add_genes_to_lookup(gene_list_json, lookup):
    if gene_list_json is None:
        exit_with_msg('Unable to process information from ' + json.dumps(gene_list_json, sort_keys=False, indent=4))
    for gene in gene_list_json:
        panther_id = ""
        GO_molecular_function_complete_list = ""
        GO_molecular_function_complete_list_id = ""        
        GO_biological_process_complete_list = ""
        GO_biological_process_complete_list_id = ""
        GO_cellular_component_complete_list = ""
        GO_cellular_component_complete_list_id = ""
        PANTHER_GO_SLIM_molecular_function_list = ""
        PANTHER_GO_SLIM_molecular_function_list_id = ""
        PANTHER_GO_SLIM_biological_process_list = ""
        PANTHER_GO_SLIM_biological_process_list_id = ""
        PANTHER_GO_SLIM_cellular_component_list = ""
        PANTHER_GO_SLIM_cellular_component_list_id = ""
        PANTHER_protein_class_list = ""
        PANTHER_protein_class_list_id = ""
        REACTOME_pathway_list = ""
        REACTOME_pathway_list_id = ""
        PANTHER_pathway_list = ""
        PANTHER_pathway_list_id = ""
        panther_id = format_gene_id(gene["accession"])
        if panther_id is None:
            exit_with_msg('Unable to process null panther id information from ' + json.dumps(gene, sort_keys=False, indent=4))
 
        if gene.get("annotation_type_list", False) and gene["annotation_type_list"].get("annotation_data_type", False):
            data_types = gene["annotation_type_list"]["annotation_data_type"]
            if isinstance(data_types, dict):
                data_types = [data_types]
        
            for types in data_types:
                if types.get("content", False) and types.get("annotation_list", False):
                        type = types["content"]
                        annotation_list = types["annotation_list"]
                        
                        annotation_id_list = []
                        annotation_label_list = []
                        annotation = annotation_list["annotation"]
                        if isinstance(annotation, dict):
                            annotation = [annotation]
                        for a in annotation:
                            if a.get("id", False) and a.get("name", False):
                                annotation_id_list.append(a["id"])
                                annotation_label_list.append(a["name"])
                        id_list_str = '|'.join(annotation_id_list)
                        label_list_str = '|'.join(annotation_label_list)
                        
                        if type == "ANNOT_TYPE_ID_PANTHER_GO_SLIM_MF":
                            PANTHER_GO_SLIM_molecular_function_list_id = id_list_str
                            PANTHER_GO_SLIM_molecular_function_list = label_list_str         
                        elif type == "ANNOT_TYPE_ID_PANTHER_GO_SLIM_BP":
                            PANTHER_GO_SLIM_biological_process_list_id = id_list_str
                            PANTHER_GO_SLIM_biological_process_list = label_list_str
                        elif type == "ANNOT_TYPE_ID_PANTHER_GO_SLIM_CC":
                            PANTHER_GO_SLIM_cellular_component_list_id = id_list_str
                            PANTHER_GO_SLIM_cellular_component_list = label_list_str
                        elif type == "ANNOT_TYPE_ID_PANTHER_PC":
                            PANTHER_protein_class_list_id = id_list_str
                            PANTHER_protein_class_list = label_list_str
                        elif type == "ANNOT_TYPE_ID_PANTHER_PATHWAY":
                            PANTHER_pathway_list_id = id_list_str
                            PANTHER_pathway_list = label_list_str
                        elif type == "ANNOT_TYPE_ID_REACTOME_PATHWAY":
                            REACTOME_pathway_list_id = id_list_str
                            REACTOME_pathway_list = label_list_str
                        elif type == "GO:0003674": 
                            GO_molecular_function_complete_list_id = id_list_str
                            GO_molecular_function_complete_list = label_list_str         
                        elif type == "GO:0008150":
                            GO_biological_process_complete_list_id = id_list_str
                            GO_biological_process_complete_list = label_list_str
                        elif type == "GO:0005575":
                            GO_cellular_component_complete_list_id = id_list_str
                            GO_cellular_component_complete_list = label_list_str
                        else:
                           LOG.warning("Did not find annotation type for " + json.dumps(gene, sort_keys=False, indent=4))
                            
        lookup[panther_id] = [GO_molecular_function_complete_list,
                                GO_molecular_function_complete_list_id,
                                GO_biological_process_complete_list,
                                GO_biological_process_complete_list_id,
                                GO_cellular_component_complete_list,
                                GO_cellular_component_complete_list_id,
                                PANTHER_GO_SLIM_molecular_function_list,
                                PANTHER_GO_SLIM_molecular_function_list_id,
                                PANTHER_GO_SLIM_biological_process_list,
                                PANTHER_GO_SLIM_biological_process_list_id,
                                PANTHER_GO_SLIM_cellular_component_list,
                                PANTHER_GO_SLIM_cellular_component_list_id,
                                PANTHER_protein_class_list,
                                PANTHER_protein_class_list_id,
                                REACTOME_pathway_list,
                                REACTOME_pathway_list_id,
                                PANTHER_pathway_list,
                                PANTHER_pathway_list_id]       


def main():
    """The main runner for our script."""

    ## Deal with incoming.
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-o', '--output',
                        help='Output file')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='More verbose output')
    args = parser.parse_args()

    if args.verbose:
        LOG.setLevel(logging.INFO)
        LOG.info('Verbose: on')

    ## Ensure output file.
    if not args.output:
        exit_with_msg('need an output file argument')
    LOG.info('Will output to: ' + args.output)
    
    requestStr = PANTHER_API_DOWNLOAD_GENOME_URL + str(PANTHER_API_DOWNLOAD_GENOME_DEFAULT_START_INDEX);
    resp = requests.post(requestStr)
    if resp.status_code != 200:
        exit_with_msg('Unable to read from server ' + requestStr)
        return
    jret = resp.json()
    if jret and jret.get('search', False) and jret['search'].get('number_of_genes_in_genome', False):
        num_genes = jret['search']['number_of_genes_in_genome']
        if num_genes <= 0:
            exit_with_msg('Nothing to do, number of genes from server ' + requestStr + " = " + num_genes) 
        
        ## Read data and add to lookup
        gene_lookup = dict()
        
        if jret['search'].get('gene_list', False) and jret['search']['gene_list'].get('gene', False):            
            gene_list_json = jret['search']['gene_list']['gene']
            add_genes_to_lookup(gene_list_json, gene_lookup)

            cur_index = PANTHER_API_DOWNLOAD_GENOME_DEFAULT_START_INDEX + PANTHER_API_DOWNLOAD_GENOME_MAX_ENTRIES
            while cur_index <= num_genes:
                resp = requests.post(PANTHER_API_DOWNLOAD_GENOME_URL + str(cur_index))
                if resp.status_code != 200:
                    exit_with_msg('Unable to read from server ' + requestStr)
                
                jret = resp.json()
                if jret['search'].get('gene_list', False) and jret['search']['gene_list'].get('gene', False):
                    gene_list_json = jret['search']['gene_list']['gene']
                    add_genes_to_lookup(gene_list_json, gene_lookup)
                                
                cur_index += PANTHER_API_DOWNLOAD_GENOME_MAX_ENTRIES
            
            ## Ensure the number of gene entries equals number in lookup
            if num_genes != len(gene_lookup):
                LOG.warning("Number of genes expected " + str(num_genes) + " unique number found " + str(len(gene_lookup)))
                sys.stdout.write("Number of genes expected " + str(num_genes) + " unique number found " + str(len(gene_lookup)) + "\n")
                
            ## Create final json structure
            param_cols = "cols"
            param_data = "data"    
            all_data = {param_cols : ["panther_id",
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
                                    "PANTHER_GO_SLIM_protein_class_list",
                                    "PANTHER_GO_SLIM_protein_class_list_id",
                                    "REACTOME_pathway_list",
                                    "REACTOME_pathway_list_id",
                                    "PANTHER_pathway_list",
                                    "PANTHER_pathway_list_id"],
                        param_data : gene_lookup}
        
            ## Writeout of json 
            with open(args.output, 'w+') as fhandle:
                fhandle.write(json.dumps(all_data, sort_keys=True, indent=4))
        else:
            exit_with_msg('Unable to process information from server ' + requestStr)      
            
                  
        
if __name__ == '__main__':
    main()        
