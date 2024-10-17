# AnnoQ Data Builder

## Part 1: AnnoQ WGS Annotator (WGSA) - Version 095

WGSA is an annotation pipeline designed for human genome re-sequencing studies. It integrates various annotation resources and bioinformatics tools to provide comprehensive annotations for both single nucleotide variants (SNVs) and insertions/deletions (indels).

### Directory Structure

- annovar20200608: ANNOVAR installation directory
- configs: Configuration files for running WGSA
- htslib: HTSlib installation directory
- input: Input files (e.g., input/dbSNP/10.vcf)
- res: Result folder
- resources: Annotation resources (very large)
- scripts: Scaffold scripts and configuration file templates
- slurm: Automatically generated SLURM scripts
- snpeff: SnpEff installation directory
- tmp: Temporary files
- vep: VEP installation directory
- work: Work directory
- WGSA08.class: WGSA class file

### Installation

Create the directory structure:

```bash
bash wgsa_095_pipeline/create_dir.sh wgsa_095
cd wgsa_095
```

Download WGSA.class and annotation resources from [WGSA Page](https://sites.google.com/site/jpopgen/wgsa).

Install ANNOVAR, VEP, and SnpEff. See the provided URL for instructions.

### Usage

Create a new directory in the input folder and place all input VCF files in it.

Modify run_work.sh (e.g., run_work.dbSNP.sh).

### Run Work Scripts

- config.py: Generates specific configurations for each VCF file using a template (config.temp).
- sbatch.py: Creates SLURM batch files for each VCF file, based on the sbatch.temp template.
- sbatch.temp: A template for an HPC SLURM batch file, specifying resources and running the WGSA pipeline.

These scripts are integrated into the run_work.sh workflow and can be customized as needed.

#### More Detail

**config.py**
This Python script reads a template file (config.temp) and takes five command-line arguments to format the template with specific paths for the base directory, input, output, work, and temporary directories. The formatted template is then printed to the standard output.

**sbatch.py**
This Python script reads a template file (sbatch.temp) and takes five command-line arguments to format the template with specific paths for the base directory, configuration file, configuration directory, SLURM output, and SLURM error logs. The formatted template is then printed to the standard output.

**sbatch.temp**
This is a template for an HPC SLURM batch file. It specifies the resources required for the job (e.g., number of tasks, time, memory) and includes placeholders for various paths and configurations. The script loads the Java Development Kit (JDK) module, runs the WGSA pipeline with specific parameters, and executes a bash script to redirect the output and error logs.

### Integration with run_work.sh

The run_work.sh script utilizes these files as part of the workflow:

- It uses config.py to generate specific configurations for each VCF file.
- It uses sbatch.py to create SLURM batch files for each VCF file, based on the sbatch.temp template.
- It submits the SLURM batch files to the HPC cluster for processing.

### Run the script

!important: Make sure you know what's in the script and change placeholder values

```bash
bash run_work.sh [work_name] [base_wgsa_dir]
```

where
work_name might be HRC_2023 and
base_wgsa_dir is the base abs path for your wgsa resources folder created above  i.e. /scratch2/username/annoq_data_builder/wgsa_095

### Output

Results will be generated in the res folder.
Temporary files will be placed in the tmp and work directories.
SLURM scripts can be found in the slurm directory (see scripts/sbatch.temp).


## Part 2: AnnoQ Adding PANTHER and ENHANCER annotations
The Java Module in /java_wgsa_add can be used to add the PANTHER and Enhancer annotations
The Java module requires the annotation file generated via PANTHER API.  It can be generated as follows:
1.    cd  annoq-data-builder
2.    Setup environment as follows:
     * python3 -m venv env
     * . env/bin/activate
     * pip3 install -r requirements.txt
3.   python3 tools/api_extractor/panther_gene_extractor.py --output panther_annot.json
4.   copy panther_annot.json to location specified in ./annoq-data-builder/java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties or modify the property to point to location of file

### Part 2.1 Pre-Work Script for Annotation Preparation

This part scripts designed for data preparation and processing, a crucial pre-step for before adding annotations. The scripts automate various tasks to clean and organize data for efficient annotation.

## Overview

The `tools/scripts/run_pre_work.sh` script automates several Python scripts, each handling a specific part of data preparation. This script streamlines the process, ensuring data is correctly formatted and optimized for future AnnoQ tasks.

## Pre-Work Process Steps

1. **Extracting Terms from Panther Data**: 
   This step extracts terms from the `panther_data.json` file to create a map of IDs and labels. This map is essential for future term label lookups on the site.

2. **Removing Labels from Panther Data**:
   Labels are not required in the Elasticsearch index, so this step removes them from the `panther_data.json` file, resulting in a cleaner dataset for indexing.

3. **Creating an Interval Tree**:
   An interval tree is generated for quick searches and efficient data retrieval, using the `Homo_sapiens.GRCh38.pep.all.fa` and `UP000005640_9606.idmapping` files.

4. **Creating an Enhancer Map**:
   The final step creates an enhancer map using the label-free `panther_data.json` file. This map facilitates faster data annotation processes.

### Data Transformation Example

#### Panther Data Sample Before Processing

The `panther_data.json` initially contains columns for both labels and IDs. For example:

```json
{
  "cols": [
    "GO_molecular_function_complete_list",
    "GO_molecular_function_complete_list_id",
    // other columns...
  ],
  "data": {
    "HGNC:2602": [
      "label1|label2|label3",
      "GO:0008403|GO:0020037|GO:0030342",
      // other data...
    ]
  }
}
```

### Panther Data After Term Removal

The script processes this file to remove label columns, leaving only the ID columns:

```json

{
  "cols": [
    "GO_molecular_function_complete_list_id",
    // other columns...
  ],
  "data": {
    "HGNC:2602": [
      "GO:0008403|GO:0020037|GO:0030342",
      // other data...
    ]
  }
}

```

### Panther Terms Output

The extracted terms are then formatted as a simple key-value pair:

```json
{
  "GO:0010070": {
    "id": "GO:0010070",
    "label": "zygote asymmetric cell division"
  },
  // other terms...
}
```

### Enhancer Map Output

The enhancer map is an expanded file, formatted for quick reference and efficient processing:

```json
[
    {
        "chrNum": "chr21",
        // other enhancer data...
        "data": {
            "GO_molecular_function_complete_list_id": ["GO:0004620", /* more IDs */],
            // other data...
        }
    },
    // other entries...
]
```

Usage
Run the script with the command below from the repository's root directory:

```bash
bash tools/scripts/run_pre_work.sh ./../annoq_data
```

Ensure the annoq_data directory is correctly located relative to the script's path.






# To Be Continued, this is Old DOc

## Running Decode Pickle for visualization 

'pip install -r requirements.txt
`cd tools`

Take a look in scripts/run_decode-pickle.sh and add files accordingly outside the repo

Then run

`sh scripts/run_decode_pickle.sh`

## Running tools/coord_to_intervaltree.py
The `coord_to_intervaltree.py` script contains wrapper classes for `IntervalTree` and `Interval` objects: `PantherIntervalTree` and `PantherInterval`. You can quickly extract TSV and JSON formatted coordinates given a HUMAN peptide FASTA `--pep_fasta` file and Reference Proteome HUMAN ID mapping `--idmapping` file:
```
wget ftp://ftp.ensembl.org/pub/release-80/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.idmapping.gz
gunzip Homo_sapiens.GRCh38.pep.all.fa.gz
gunzip UP000005640_9606.idmapping.gz
python3 tools/coord_to_intervaltree.py -p Homo_sapiens.GRCh38.pep.all.fa -i UP000005640_9606.idmapping > parsed_coords.tsv
python3 tools/coord_to_intervaltree.py -p Homo_sapiens.GRCh38.pep.all.fa -i UP000005640_9606.idmapping --json > parsed_coords.json
```
### Example output
TSV:
```
ENSG00000228985 14      22449113        22449125        1
ENSG00000223997 14      22438547        22438554        1       HGNC:12254
ENSG00000282253 CHR_HSCHR7_2_CTG6       142847306       142847317       1       HGNC:12158
```
JSON:
```
[
    [
        "ENSG00000228985",
        ["14", 22449113, 22449125, "1"]
    ],
    [
        "ENSG00000223997",
        ["14", 22438547, 22438554, "1"],
        "HGNC:12254"
    ],
    [
        "ENSG00000282253",
        ["CHR_HSCHR7_2_CTG6", 142847306, 142847317, "1"],
        "HGNC:12158"
    ],
]
```

## Part 3: Generate and or copy over files to be used by annoq-database, annoq-api and annoq-site
1.  Module /java_wgsa_add generates the json term lookup file (panther_terms.json).  It will be avaiable in the diagnostics directory.  This file has to be copied into /path/to/annoq-site/src/@annoq.common/data/panther_terms.json

2.  Update file annoq-site/metadata/annotation_tree.csv to reflect any metadata changes.  Module (tools/gen_col_update_info.py) maybe used to track column changes.

3.  Setup environment as follows:
python3 -m venv env\
 . env/bin/activate\
pip3 install -r requirements.txt

#### Part 3.1 Generate json and mappings files and copy over
python3 -m tools.annotation_tree_gen --input_csv /path/to/annoq-site/metadata/annotation_tree.csv --output_csv /do/not/use/annotation_tree_output.csv --output_json /path/to/annoq-api/data/anno_tree.json --mappings_json /path/to/annoq-database/metadata/annoq_mappings.json --api_mappings_json /path/to/annoq-api-v2/data/api_mapping_anno_tree.json 
1.  Copy anno_tree.json into /annoq-api/data/anno_tree.json
2.  Copy anno_tree.json into /annoq-api-v2/data/anno_tree.json
3.  Copy api_mapping_anno_tree.json into /annoq-api-v2/data/api_mapping_anno_tree.json
4.  Copy annoq_mappings.json and into annoq-database/data/annoq_mappings.json

DO NOT overwrite file annoq-site/metadata/annotation_tree.csv with /do/not/use/annotation_tree_output.csv since some fields may get lost

python3 /path/to/annoq-data-builder/tools/mappings_data_type_gen.py --input /path/to/annoq-site/metadata/annotation_tree.csv --output /annoq-database/data/doc_type.pkl --anno_tree /do/not/use/do_not_use_anno_tree.json -d ,

copy doc_type.pkl into /annoq-database/data/doc_type.pkl
DO NOT overwrite file  /annoq-api/data/anno_tree.json with /do/not/use/anno_tree.json since some fields are not generated by this script





