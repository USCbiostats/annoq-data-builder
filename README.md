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


## Part 2: Add HRC mapping columns (TOPMed only) — run after WGSA, before Part 3

Run this **immediately after WGSA (Part 1) and before the Part-3 PANTHER/GO/Reactome/enhancer
step**. It applies to the **TOPMed** dataset only — it maps TOPMed hg38 variants back to HRC r1.1
(hg19) — and is not run for the HRC dataset. Because it runs before the functional-annotation step,
it does **not** read or compare any PANTHER/Uniprot columns.

```bash
python3 wgsa_add/merge_hrc_topmed.py <hrc_dir> <topmed_dir> <output_dir>
```

- `hrc_dir` — the **raw HRC r1.1 reference VCFs**, one per chromosome (e.g. `18.vcf`; standard
  8-column VCF `CHROM POS ID REF ALT QUAL FILTER INFO`, hg19, bare chromosome `18`).
- `topmed_dir` — the TOPMed WGSA-output `.vcf` files.
- `output_dir` — merged output; also gets `merge_hrc_topmed_stats.json` (mapping counts only).

**SNPs only** — indels and multiallelic rows are ignored. The script matches each TOPMed file to
the HRC VCF for the same chromosome and appends **four** columns to every row:

- `chr_pos` — hg38 `chr:pos`, always populated (basic info).
- `Mapped_in_HRC` — `Y` if the hg19-equivalent SNP is in HRC r1.1, `N` if not found, `.` if
  `ref_hg19 != ref_hg38`.
- `HRC_chr_pos` — hg19 `chr:pos` when `Mapped_in_HRC = Y`, else empty (HG19 info).
- `HRC_chr_pos_ref_alt` — hg19 `chr:posREF>ALT` (e.g. `18:10005A>T`) when `Mapped_in_HRC = Y`,
  else empty (HG19 info).

The HRC rsID is **not** carried: the raw HRC ID column never provides an rsID that TOPMed's own
`rs_dbSNP` lacks (verified on chr18), so HRC-by-RSID search uses `rs_dbSNP` + `Mapped_in_HRC=Y`.

These fields must then be registered in `annoq-site/metadata/annotation_tree.csv` — `chr_pos` under
basic info, and the three HRC/HG19 fields under **HG19 Info** (see Part 4).

> **Ordering invariant:** the Part-3 PANTHER/enhancer (Java) module also performs the dbNSFP cell
> cleanup (`.` → `""`). It must run **after** this merge and **before** VCF→JSON conversion, so the
> raw WGSA `.` markers in numeric fields are cleaned before indexing — otherwise Elasticsearch
> rejects every document (`mapper_parsing_exception`, `count=0`).

## Part 3: AnnoQ Adding PANTHER, GO, Reactome and ENHANCER annotations

Run this **after** the Part-2 HRC merge (TOPMed) — for the HRC dataset it runs directly after Part 1.

The Java Module in /java_wgsa_add can be used to add the PANTHER and Enhancer annotations
The Java module requires the annotation file generated via PANTHER API.  It can be generated as follows:
1.    cd  annoq-data-builder
2.    Setup environment as follows:
     * python3 -m venv env
     * . env/bin/activate
     * pip3 install -r requirements.txt
3.   python3 tools/api_extractor/panther_gene_extractor.py --output panther_annot.json
4.   copy panther_annot.json to location specified in ./annoq-data-builder/java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties or modify the property to point to location of file
5.   Set `genome.build` in `./annoq-data-builder/java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties`
     to match the input build — `hg38` for TOPMed, `hg19` for HRC.

     For **hg38** this enables a gene-symbol fallback for the `ANNOVAR_ensembl_Gene_ID` column.
     WGSA hg38 output mixes Ensembl gene ids and HGNC gene symbols in that column (e.g.
     `LINC02564|ENSG00000263305` at chr18:10090, `TUBB8B` at chr18:43621); without the fallback the
     symbol tokens are silently dropped and those variants lose their PANTHER/GO/Reactome
     annotations. On chr6:0-36Mb, 82.6% of non-empty cells in this column contain at least one
     gene symbol. hg19/HRC output contains no such tokens, so the setting has no effect there.

     Note: enabling this changes annotation **values** (not the column set) for hg38, so an hg38
     Elasticsearch index built before this change must be rebuilt.

## Part 4: Generate and or copy over files to be used by annoq-database, annoq-api and annoq-site
1.  Module /java_wgsa_add generates the json term lookup file (panther_terms.json).  It will be avaiable in the diagnostics directory.  This file has to be copied into /path/to/annoq-site/src/@annoq.common/data/panther_terms.json

2.  Update file annoq-site/metadata/annotation_tree.csv to reflect any metadata changes, including the HRC mapping fields added in Part 2: Mapped_in_HRC, HRC_chr_pos and HRC_chr_pos_ref_alt under HG19 Info, and chr_pos under basic info.  Module (tools/gen_col_update_info.py) maybe used to track column changes.

3.  Setup environment as follows:
python3 -m venv env\
 . env/bin/activate\
pip3 install -r requirements.txt


#### Part 4.1 Generate json and mappings files and copy over
python3 -m tools.annotation_tree_gen --input_csv /path/to/annoq-site/metadata/annotation_tree.csv --output_csv /do/not/use/annotation_tree_output.csv --output_json /path/to/annoq-api/data/anno_tree.json --mappings_json /path/to/annoq-database/data/annoq_mappings.json --api_mappings_json /path/to/annoq-api-v2/data/api_mapping_anno_tree.json 
1.  Copy anno_tree.json into /annoq-api/data/anno_tree.json
2.  Copy anno_tree.json into /annoq-api-v2/data/anno_tree.json
3.  Copy api_mapping_anno_tree.json into /annoq-api-v2/data/api_mapping_anno_tree.json
4.  Copy annoq_mappings.json and into annoq-database/data/annoq_mappings.json

DO NOT overwrite file annoq-site/metadata/annotation_tree.csv with /do/not/use/annotation_tree_output.csv since some fields may get lost

## Legacy / unused code (superseded — do not use)

The PANTHER/GO/Reactome/Enhancer annotations and the dbNSFP cell cleanup (`.` → `""`) are now
produced by the **Java module** (`java_wgsa_add/add_panther_enhancer`, see Part 3). An older
**Python annotation path** in `wgsa_add/` predates it and is **no longer part of the pipeline** —
retained for reference only, not invoked by `run_work.sh` / Part 3:

- `wgsa_add/add_annotations.py` — orchestrator (adds PANTHER + Enhancer, then cleans via `clean_line`).
- `wgsa_add/add_panther_anno.py`, `wgsa_add/add_enhancer_anno.py` — the per-annotation adders.
- `wgsa_add/clean_annotations.py` — cell cleanup; the Java module performs this now.
- `wgsa_add/base.py`, `wgsa_add/utils.py` — helpers used **only** by the modules above.
- Driver scripts: `wgsa_add/scripts/hrc_add.sh`, `hrc_add_enhancer.sh`, `hrc_add_all.sh`, `hrc_batch.template`.
- `wgsa_add/create_sbatch.py` — orphaned SLURM-script generator (no references anywhere in the repo).

Current, in-use `wgsa_add/` code: **`merge_hrc_topmed.py`** (Part 2, HRC mapping columns) and
**`check_hrc_rsid.py`** (one-off HRC-vs-TOPMed rsID validation).

python3 /path/to/annoq-data-builder/tools/mappings_data_type_gen.py --input /path/to/annoq-site/metadata/annotation_tree.csv --output /annoq-database/data/doc_type.pkl --anno_tree /do/not/use/do_not_use_anno_tree.json -d ,

copy doc_type.pkl into /annoq-database/data/doc_type.pkl
DO NOT overwrite file  /annoq-api/data/anno_tree.json with /do/not/use/anno_tree.json since some fields are not generated by this script





