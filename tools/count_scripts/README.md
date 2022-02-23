# Running the count script

There are 2 scripts count_enhancer_anno.py and add_counts.py. For efficiency purposes each chr.vcf file is counted in parallel and added together after, 

## Running it locally (small files)

```bash
python3 count_enhancer_anno.py -f [path to chr.vcf file] > [path to output file]
```

Or use the handy bash script   count_enhancer_anno.sh if you have many vcf files. Remember to change the file path.

```bash
bash count_enhancer_anno.sh
```

## Running on HPC

```bash
python3 run_enhancer_count_jobs.py
```

This will create slurm jobs using the template enahncer_count_sbatch.template for each vcf file 
