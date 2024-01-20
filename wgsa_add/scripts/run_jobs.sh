#!/bin/bash

# Function to display usage information
show_usage() {
    echo "Usage: $0 --work-name <WORK_NAME> --base-dir <BASE_DIR> --annoq-data-dir <ANNOQ_DATA_DIR> [--local]"
    echo "Arguments:"
    echo "    --work-name: Name of the work to process."
    echo "    --base-dir: Base directory for processing."
    echo "    --annoq-data-dir: Annotation data file path."
    echo "    --local: Optional. Run locally using bash instead of sbatch."
}

# Parse named arguments
LOCAL_RUN=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --work-name) WORK_NAME="$2"; shift ;;
        --base-dir) BASE_DIR="$2"; shift ;;
        --annoq-data-dir) ANNOQ_DATA_DIR="$2"; shift ;;
        --local) LOCAL_RUN=true ;;
        *) echo "Unknown parameter passed: $1"; show_usage; exit 1 ;;
    esac
    shift
done

# Check if all required arguments are provided
if [ -z "$WORK_NAME" ] || [ -z "$BASE_DIR" ] || [ -z "$ANNOQ_DATA_DIR" ]; then
    echo "Error: --work-name, --base-dir, and --annoq-data-dir arguments are required."
    show_usage
    exit 1
fi

echo "Running work name: $WORK_NAME using base directory: $BASE_DIR and annotation data file: $ANNOQ_DATA_DIR"

# Setting up directories and checking their existence
IN_DIR="${BASE_DIR}/wgsa_add/input/${WORK_NAME}"
OUT_DIR="${BASE_DIR}/wgsa_add/output/${WORK_NAME}"
SLURM_DIR="${BASE_DIR}/wgsa_add/slurm/${WORK_NAME}"
SBATCH_TEMPLATE="${BASE_DIR}/wgsa_add/scripts/hrc_batch.template"

for dir in "$IN_DIR" "$ANNOQ_DATA_DIR" "$SBATCH_TEMPLATE"; do
    if [ ! -d "$(dirname "$dir")" ]; then
        echo "Error: Directory does not exist: $(dirname "$dir")"
        exit 1
    fi
done

mkdir -p "$SLURM_DIR"
mkdir -p "$OUT_DIR"

# Process each .vcf file
for FP in $(ls "$IN_DIR" | grep .vcf$); do
    echo "Processing file: $IN_DIR/$FP"
    BASE_DIR="$BASE_DIR" IN_FILE="$IN_DIR/$FP" OUT_FILE="$OUT_DIR/$FP" ANNOQ_DATA_DIR="$ANNOQ_DATA_DIR" \
    envsubst '$BASE_DIR, $IN_FILE, $OUT_FILE, $ANNOQ_DATA_DIR' < "$SBATCH_TEMPLATE" > "$SLURM_DIR/slurm_${FP}.slurm"
    if [ "$LOCAL_RUN" = true ]; then
       bash "$SLURM_DIR/slurm_${FP}.slurm"
    else
       sbatch "$SLURM_DIR/slurm_${FP}.slurm"
    fi
done
