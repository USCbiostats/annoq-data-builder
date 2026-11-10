# Building and Running Maven Java module

## Checkout module

## Load modules to build and run application
module load legacy/CentOS7<br>
module load intel/19.0.4<br>
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


# Incremental PEREGRINE update (ComputeEnhancerDelta)

Use this when **only the PEREGRINE enhancer-gene data has changed** (for example
[annoq-site-v2#27](https://github.com/USCbiostats/annoq-site-v2/issues/27), where new enhancer-gene links were
added). Instead of re-running ProcessVCF on every chromosome and reloading the whole database,
`ComputeEnhancerDelta` recomputes only the PEREGRINE columns of the already-annotated files and writes just the
rows whose values changed. annoq-database then applies those rows to the existing Elasticsearch documents in place.

The enhancer calculation is shared with ProcessVCF (`logic/EnhancerAnnotator.java`), so an incremental update
produces exactly the same values as a full rebuild with the same input files.

## Columns affected
Only the 12 PEREGRINE columns are recomputed; all other columns are never read for computation and never updated.

| Column | Derived from |
|--------|--------------|
| enhancer_linked_genes | genes linked to the enhancer(s) containing the variant (file.enhancer.panther) |
| enhancer_linked_assay | assay column of those same links |
| enhancer_linked_GO_molecular_function_complete_list_id, enhancer_linked_GO_biological_process_complete_list_id, enhancer_linked_GO_cellular_component_complete_list_id, enhancer_linked_PANTHER_GO_SLIM_molecular_function_list_id, enhancer_linked_PANTHER_GO_SLIM_biological_process_list_id, enhancer_linked_PANTHER_GO_SLIM_cellular_component_list_id, enhancer_linked_PANTHER_protein_class_list_id, enhancer_linked_REACTOME_pathway_list_id, enhancer_linked_PANTHER_pathway_list_id | union of the annotations of the linked genes (file.panther.annot) |
| enhancer_linked_enhancer | enhancer region(s) containing the variant (file.enhancer.chr.range.enhancer) |

When only links are added (enhancer ranges file unchanged), enhancer_linked_enhancer does not change, so 11 columns
can change. Only variants inside an enhancer that gained links can change, so only chromosomes containing such
enhancers need to be processed.

## Overriding property values from the command line
Any property in add_panther_enhancer.properties can be overridden with a JVM system property of the same name,
so each run can point at its own input files without editing the properties file:<br>
-Dfile.enhancer.panther=/path/to/enhancer_gene_link_file<br>
This applies to ProcessVCF as well.

## Inputs
Either of the following, one file per chromosome, ending in .vcf or .tsv, in one input directory:
- the annotated output VCFs of ProcessVCF, e.g. wgsa_add/output/HRC_03_07_19/chr3.vcf
- slim TSVs extracted from the JSON that was loaded into the database, created in annoq-database with<br>
  python3 -m src.extract_enhancer_tsv -i output/HRC_03_07_19 -o /path/slim_tsv [--only chr3.vcf,chr6.vcf] [--max-records N]

The header must contain the chr (or chrom), pos, ref and alt columns. Missing PEREGRINE columns are treated as empty.
Every .vcf/.tsv file in the input directory is processed, so to process a subset of chromosomes create a directory
of symbolic links to just those files.

## Steps
1. Create the new enhancer-gene link file. For an additions-only release, append the new rows to the link file
   used for the current database (the added file has no header line):<br>
   cat enhancer_gene_link_19.tsv enhancer_gene_link_idsToAdd_only_20261105.tsv > enhancer_gene_link_19_plus_20261105.tsv

2. **Check that the current database was built from the current files.** Run ComputeEnhancerDelta with the
   **current** link file on one or two of the chromosomes. summary.tsv must show 0 for gained, changed, cleared
   and rows_with_lost_items. If it does not, the database was built with different input files (for example a
   different panther_annot.json) and the update would also change those values. Stop and investigate.

3. Run ComputeEnhancerDelta with the **new** link file, keeping every other property the same as the current build.

4. Review the output (see Output below). For an additions-only update, every *.lost.tsv file must contain only its
   header line.

5. Apply the delta in annoq-database (see Applying the update to the database below), first to a small subset.

## Run
Build as above (mvn clean install). The files are processed one at a time by default. To process files in
parallel, add the number of threads as a fourth argument.

From directory add_panther_enhancer:<br>
export MAVEN_OPTS="-Xss64m -Xms512m -Xmx16g"<br>
mvn exec:java -Dexec.mainClass=edu.usc.ksom.pphs.add_panther_enhancer.main.ComputeEnhancerDelta \
  -Dfile.enhancer.panther=/scratch1/username/java_add_panther_enhancer/load_info/enhancer/enhancer_gene_link_19_plus_20261105.tsv \
  -Dexec.args="/project/projname/delta_1/input /project/projname/delta_1/output /project/projname/delta_1/working"  > output.txt

The other file.* properties (panther annotations, id mapping, HGNC, pep fasta, enhancer ranges) must be the same
files used to build the current database. Set them in the properties file or with -D as above.

Peak memory with the release 1.2 input files was about 7 GB; -Xmx16g leaves headroom. For an sbatch job use the
sbatch example above with #SBATCH --ntasks=1 and the command above.

## Output
Written to the output directory, for each input file NAME:

| File | Content |
|------|---------|
| NAME.delta.tsv | chr, pos, ref, alt, the 12 PEREGRINE columns with their new values, and peregrine_change (GAINED: no linked genes before; CHANGED: values differ; CLEARED: no values any more). Only changed rows are written. |
| NAME.lost.tsv | one line per variant and column where a previously present item is no longer present. Should be empty (header only) when links are only added. |
| summary.tsv | per input file: rows, unchanged, gained, changed, cleared, rows_with_lost_items, skipped_lines, error, and the number of rows changed for each column. |

Values are compared as sets of ';'-separated items, because the item order in these columns is not stable between runs.

## Applying the update to the database
In annoq-database (branch with the PEREGRINE update scripts), from the repository root, with .env set to the
target ANNOQ_ES_URL and ANNOQ_ANNOTATIONS_INDEX:

1. Convert the delta files into Elasticsearch update actions. These set the PEREGRINE fields and remove fields that
   became empty; no other field is sent. An update for a variant that is not in the index fails rather than
   creating a new document.<br>
   python3 -m src.convert_enhancer_delta_to_json -i /project/projname/delta_1/output -o /path/update_json -m data/doc_type.pkl --es_index &lt;index name&gt; [--max-rows 100]

2. Save the current documents that will be updated (read only):<br>
   python3 -m src.verify_enhancer_update snapshot -d /project/projname/delta_1/output -o before.jsonl [--max-rows 100]

3. Apply the update. The script refuses to run if the index in the update files differs from ANNOQ_ANNOTATIONS_INDEX,
   and asks for confirmation (--yes to skip). Failures are written to update_failures.jsonl.<br>
   python3 -m src.update_es_json /path/update_json

4. Verify that the PEREGRINE fields have the new values and that every other field is unchanged:<br>
   python3 -m src.verify_enhancer_update check -d /project/projname/delta_1/output -b before.jsonl [--max-rows 100]

Use the same --max-rows value in steps 1, 2 and 4. --max-rows limits each chromosome's delta file to its first N
rows, for a small test before updating everything. Keep before.jsonl: it holds the previous values of every updated
document.
