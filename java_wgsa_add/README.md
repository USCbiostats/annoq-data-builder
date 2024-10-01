# Building and Running Maven Java module

## Checkout module

## Load modules to build and run application
module load intel<br>
module load maven/3.6.3<br>
module load jdk<br>



## Retrieve code and update property file
For performance, copy module to HPC scratch directory.

Update property file /add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
- file.panther.annot=/scratch1/username/java_add_panther_enhancer/load_info/panther_annot.json
- file.hgnc.complete=/scratch1/username/java_add_panther_enhancer/load_info/hgnc_complete_set.txt
- file.pep.fasta=/scratch1/username/java_add_panther_enhancer/load_info/Homo_sapiens.GRCh37.pep.all.fa
- file.id.mapping=/scratch1/username/java_add_panther_enhancer/load_info/UP000005640_9606.idmapping
- file.enhancer.chr.range.enhancer=/scratch1/username/java_add_panther_enhancer/load_info/enhancer/PEREGRINEenhancershg19
- file.enhancer.panther=/scratch1/username/java_add_panther_enhancer/load_info/enhancer/enh_gene_link_tissue_pval_snp_hg19




## Build project
cd add_panther_enhancer<br>
mvn clean install

## Run project
2 options to run. Either directly or via HPC node

- From directory add_panther_enhancer.  Update memory parameters if necessary<br>
  export MAVEN_OPTS="-Xss64m -Xms512m -Xmx16g"
  mvn exec:java -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF -Dexec.args="/project/projname/run_1/input /project/projname/run_1/output /project/projname/run_1/working"  > output.txt

Or use the following command to execute in parallel(br>
  mvn exec:java -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCFParallel -Dexec.args="/project/projname/run_1/input /project/projname/run_1/output /project/projname/run_1/working"  > output.txt

  

- If running in HPC CARC system, login into the correct server, create a sbatch script example run.sbatch  and execute.  Note, the sbatch script has to be created in directory add_panther_enhancer

Contents of script will be similar to following for processing 5 chromosomes in parallel:<br>
#!/bin/bash<br>
#SBATCH --ntasks=5<br>
#SBATCH --cpus-per-task=5<br>
#SBATCH --time=12:00:00<br>
#SBATCH --account=myaccount_123<br>
#SBATCH --partition=my_partition<br>
#SBATCH --nodelist=1-2<br>
#SBATCH --mem-per-cpu=32G<br>
#SBATCH --mail-type=end,fail<br>
#SBATCH --mail-user=myemail@myinst.org<br>


module load jdk<br>
module load intel/19.0.4<br>
module load maven/3.6.3<br>

export MAVEN_OPTS="-Xss64m -Xms512m -Xmx16g"
mvn exec:java -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF -Dexec.args="/project/projname/run_1/input /project/projname/run_1/output /project/projname/run_1/working"  > output.txt

or execute the following command to run in parallel
mvn exec:java -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCFParallel -Dexec.args="/project/projname/run_1/input /project/projname/run_1/output /project/projname/run_1/working"  > output.txt



Ensure that the nodes being used are free and execute command sbatch with the name of the script<br>
sbatch run.sbatch
