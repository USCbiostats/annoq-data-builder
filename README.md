# repo 1

## directory structure

annovar20180416
configs
htslib
input
README.md
res
resources
run_work.sh
scripts
slurm
snpeff
tmp
vep
WGSA08.class
work

## annotation resources

* resources (very large)

## independent tools are installed in 

* annovar20180416
* vep
* snpeff
* htslib

## input file put in 

* input

e.g. input/dbSNP/10.vcf

## configure files for running WGSA will be generated in

configs

## result folder

res

## Scaffold scripts and configure file templates

scripts

## automatic generated slurm scripts

* slurm

see to scripts/sbatch.temp

## temporary files will put in 
tmp
work


## for running a new job

1. mkdir in input folder and put all input vcf files in it
2. modify run_work.sh e.g. 
3. sh run_work.sh
