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
