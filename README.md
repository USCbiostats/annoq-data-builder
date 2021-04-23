# Data Admin



## WGSA 08
repo for running WGSA on HPC

### directory structure

* annovar20180416
* configs
* htslib
* input
* README.md
* res
* resources
* run_work.sh
* scripts
* slurm
* snpeff
* tmp
* vep
* WGSA08.class
* work

### set

`cd wgsa_08`

`sh init.sh`

download WGSA.class
download annotation resources 
from [http://web.corral.tacc.utexas.edu/WGSAdownload/](http://web.corral.tacc.utexas.edu/WGSAdownload/)

and install annovar20180416, vep and snpeff. See [url](https://sites.google.com/site/jpopgen/wgsa/setting-up-wgsa-linux)

### annotation resources

* resources (very large)

### independent tools are installed in 

* annovar20180416
* vep
* snpeff
* htslib

### input file put in 

* input

e.g. input/dbSNP/10.vcf

### configure files for running WGSA will be generated in

configs

### result folder

res

### Scaffold scripts and configure file templates

scripts

### automatic generated slurm scripts

* slurm

see scripts/sbatch.temp

### temporary files will put in 
tmp
work


### for running a new job

1. mkdir in input folder and put all input vcf files in it
2. modify run_work.sh e.g. run_work.dbSNP.sh
3. sh run_work.sh

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
