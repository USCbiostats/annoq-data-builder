# Building and Running Maven Java module

## Checkout module

## Load modules to build and run application
module load intel
module load maven/3.6.3
module load openjdk/11.0.17_8



## Retrieve code and update property file
For performance, copy module to HPC scratch directory.

Update property file /add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
- file.panther.annot=/scratch1/username/java_add_panther_enhancer/load_info/panther_annot.json
- file.hgnc.complete=/scratch1/username/java_add_panther_enhancer/load_info/hgnc_complete_set.txt
- file.pep.fasta=/scratch1/username/java_add_panther_enhancer/load_info/Homo_sapiens.GRCh37.pep.all.fa
- file.id.mapping=/scratch1/username/java_add_panther_enhancer/load_info/UP000005640_9606.idmapping
- file.enhancer.chr.range.enhancer=/scratch1/username/java_add_panther_enhancer/load_info/enhancer/PEREGRINEenhancershg19
- file.enhancer.panther=/scratch1/username/java_add_panther_enhancer/load_info/enhancer/enh_gene_link_tissue_pval_snp_hg19


- dir.output.working=/scratch1/username/java_add_panther_enhancer/diagnostics
- dir.input.vcf=/scratch1/username/java_add_panther_enhancer/vcf_input/HRC_03_07_19
- dir.output.vcf=/scratch1/username/java_add_panther_enhancer/vcf_output/HRC_03_07_19


## Build project
cd add_panther_enhancer
mvn clean install

## Run project
2 options to run. Either directly or via HPC node

- From directory add_panther_enhancer
mvn exec:java -Dexec.args="-Xss64m  -Xms512m -Xmx16g"   -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF > output.txt


- If running in HPC CARC system, login into the correct server, create a sbatch script example run.sbatch  and execute.  Note, the sbatch script has to be created in directory add_panther_enhancer

Contents of script will be similar to following:
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --account=myaccount_123
#SBATCH --partition=my_partition
#SBATCH --nodelist=1-2
#SBATCH --mem-per-cpu=32G
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=myemail@myinst.org


module load jdk
module load intel/19.0.4
module load maven/3.6.3

mvn exec:java -Dexec.args="-Xss64m  -Xms512m -Xmx16g"   -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF > output.txt



Ensure that the nodes being used are free and execute command sbatch with the name of the script
sbatch run.sbatch
