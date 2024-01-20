#!/bin/bash

# Check if working directory argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <working_directory>"    
    echo "Ex bash tools/scripts/run_pre_work.sh ./../annoq_data"
    exit 1
fi

echo "Setting up the working directory and file paths..."

# Set working directory
WORK_DIR="$1"

# Check if working directory exists
if [ ! -d "$WORK_DIR" ]; then
    echo "Error: Working directory does not exist"
    exit 1
fi

# Define file paths
INPUT_DIR="$WORK_DIR/input"
OUTPUT_DIR="$WORK_DIR/output"

# Create output directory if it does not exist
mkdir -p "$OUTPUT_DIR"

# Define input files
PANTHER_DATA="$INPUT_DIR/panther_data.json"
HOMO_SAPIENS_FA="$INPUT_DIR/Homo_sapiens.GRCh37.pep.all.fa"
IDMAPPING_FILE="$INPUT_DIR/UP000005640_9606.idmapping"
ENHANCER_FILE="$INPUT_DIR/enhancer/CREbedDBenhancers_10092018"
ENHANCER_RAW_FILE="$INPUT_DIR/enhancer/enh_gene_link_tissue_pval_snp_hg19"

# Check if input files exist
for file in "$PANTHER_DATA" "$HOMO_SAPIENS_FA" "$IDMAPPING_FILE" "$ENHANCER_FILE" "$ENHANCER_RAW_FILE"; do
    if [ ! -f "$file" ]; then
        echo "Error: Missing input file - $file"
        exit 1
    fi
done

# Define output files
COORDS_FILE="$OUTPUT_DIR/coords_data.json"
INTERVAL_TREE_PKL="$OUTPUT_DIR/annoq_tree.pkl"
PANTHER_TERMS="$OUTPUT_DIR/panther_terms.json"
PANTHER_DATA_NO_LABELS="$OUTPUT_DIR/panther_data_no_labels.json"
ENHANCER_MAP_DIR="$OUTPUT_DIR/enhancer_map"

echo "Running terms_loader.py to generate the terms map ..."
python3 tools/terms_loader.py -i "$PANTHER_DATA" -o "$PANTHER_TERMS"

echo "Running panther_data_cleaner to remove the labels..."
python3 -m tools.panther_data_cleaner -i "$PANTHER_DATA" -o "$PANTHER_DATA_NO_LABELS"

echo "Running coord_to_intervaltree.py..."
python3 tools/coord_to_intervaltree.py -p "$HOMO_SAPIENS_FA" -i "$IDMAPPING_FILE" -o "$INTERVAL_TREE_PKL" -f tree
python3 tools/coord_to_intervaltree.py -p "$HOMO_SAPIENS_FA" -i "$IDMAPPING_FILE" -o "$COORDS_FILE" -f coords

echo "Running data2json_converter.py..."
python3 tools/data2json_converter.py --enhancer_file "$ENHANCER_FILE" --raw-file "$ENHANCER_RAW_FILE" --panther_file "$PANTHER_DATA_NO_LABELS" -o "$ENHANCER_MAP_DIR" --parse-col

echo "Processing complete."

# Ex: bash tools/scripts/run_pre_work.sh ./../annoq_data