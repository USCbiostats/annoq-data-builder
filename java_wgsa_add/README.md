# Building and Running the Maven Java module (`add_panther_enhancer`)

This module is **Part 3** of the AnnoQ data build: it adds the PANTHER / GO / Reactome /
enhancer annotation columns to WGSA output VCFs, and performs the dbNSFP cell cleanup
(`.` -> `""`).

It appends **108 columns** to whatever it is given, so a 722-column WGSA input yields 830
columns out, and a 726-column HRC-merged input yields 834.

---

## 1. Input prerequisites

**Ordering:** for the TOPMed dataset, the Part 2 HRC merge (`wgsa_add/merge_hrc_topmed.py`)
must run **before** this module, and this module must run **before** VCF -> JSON conversion.

**Every data row must have the same field count as the header.** `Snp`'s constructor rejects
any row where they differ, logging `Unable to create SNP information for ...` to
`status.txt` and dropping the variant. Because Java's `String.split(regex)` discards
*trailing* empty fields, a row ending in empty tab-separated values silently comes up short.

This is a real failure mode: the HRC merge appends `chr_pos`, `Mapped_in_HRC`,
`HRC_chr_pos`, `HRC_chr_pos_ref_alt`, and the last two are unset for every variant with
`Mapped_in_HRC != 'Y'` (the majority). Writing `''` there made every such row fail. The merge
now writes `.` instead, which this module cleans back to `""`. Verify before a long run:

```bash
for f in "$IN"/*.vcf; do
  awk -F'\t' -v F="$(basename "$f")" '
    NR==1 { h=NF; next }
    { n=NF; while(n>0 && $n=="") n--; if(n!=h) bad++; else good++ }
    NR>200000 { exit }
    END { printf "%-14s header=%d accepted=%d rejected=%d %s\n", F, h, good+0, bad+0, (bad+0?"<-- BROKEN":"ok") }
  ' "$f"
done
```

Every file must report `rejected=0`. Otherwise the job will "run" for days while producing
an empty output and a `status.txt` that grows by hundreds of MB per minute.

---

## 2. Load modules

On CARC the build tools live in the **legacy CentOS7** tree, and `maven` sits under the
`intel/19.0.4` branch of the Lmod hierarchy. Order matters — loading `maven` first fails
with *"exist but cannot be loaded as requested"*.

```bash
module load legacy/CentOS7
module load intel/19.0.4     # hierarchy unlock for maven; NOT used to compile Java
module load maven jdk

java -version                # expect 17.0.5 (needs 11+, module targets Java 11)
mvn -version                 # expect Apache Maven 3.6.3
```

At **runtime** only `legacy/CentOS7` and `jdk` are needed. `intel` and `maven` are
build-time only.

---

## 3. Update the property file

`add_panther_enhancer/src/main/resources/add_panther_enhancer.properties`

The properties file is baked into `target/classes` at package time, so **edit it before
building**. Point the reference files at the build matching your input:

```properties
# hg38 / TOPMed
file.panther.annot=/path/to/annot_info/panther_annot.json
file.hgnc.complete=/path/to/annot_info/hgnc_complete_set.txt
file.pep.fasta=/path/to/annot_info/Homo_sapiens.GRCh38.pep.all.fa
file.id.mapping=/path/to/annot_info/UP000005640_9606.idmapping
file.enhancer.chr.range.enhancer=/path/to/annot_info/PEREGRINEenhancershg38
file.enhancer.panther=/path/to/annot_info/enhancer_gene_link_19.tsv

# Genome build of the input VCFs: hg38 or hg19.
genome.build=hg38

output.debug=false
```

For **hg19 / HRC** input use `Homo_sapiens.GRCh37.pep.all.fa`, `PEREGRINEenhancershg19`,
`enh_gene_link_tissue_pval_snp_hg19`, and `genome.build=hg19`.

**Do not mix builds.** `file.pep.fasta` supplies the coordinate ranges for the
`flanking_*` columns (33 columns in total), so a GRCh37 FASTA against hg38 positions
produces wrong genes silently.

### `genome.build`

| Value | Effect |
|---|---|
| `hg38` | Enables the gene-symbol fallback for `ANNOVAR_ensembl_Gene_ID` |
| `hg19`, blank, other, or absent | Parsing unchanged |

WGSA hg38/TOPMed output mixes Ensembl gene ids and HGNC gene symbols in that one column
(e.g. `LINC02564|ENSG00000263305`, or a bare `TUBB8B`). Without the fallback the symbol
tokens miss the Ensembl->UniProt lookup and are dropped, so those variants lose their
PANTHER/GO/Reactome annotations. On chr6:0-36Mb, 82.6% of non-empty cells in that column
contain at least one gene symbol. hg19/HRC output contains none, so the setting is inert
there.

Symbols are **never** split on `-`. Hyphens in this column occur inside single symbols
(`HLA-A`, `LY86-AS1`, `PPT2-EGFL8`), and splitting them attaches wrong annotations to
roughly a million rows on chr6 alone. `AnnovarGeneIdParserTest` locks this in.

Enabling `hg38` changes annotation **values** (not the column set), so an Elasticsearch
index built from earlier hg38 output must be rebuilt.

---

## 4. Build

```bash
cd add_panther_enhancer
grep -E '^genome\.build|^file\.' src/main/resources/add_panther_enhancer.properties

mvn -q clean package -DskipTests
mvn -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
```

- **`-DskipTests`**: Maven 3.6.3 defaults to surefire 2.12.4, which predates JDK 17 and
  tends to fail. Run the unit tests on a JDK 11 machine (`mvn test`, 13 tests).
- **`build-classpath` must follow `package`** — `mvn clean` deletes `target/cp.txt`.

Verify the build, not just the source:

```bash
ls target/classes/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParser.class
grep -E '^genome\.build|^file\.pep' target/classes/add_panther_enhancer.properties
wc -c target/cp.txt
```

If `genome.build` appears only in `src/main/resources` and not in `target/classes`, the run
silently does nothing.

---

## 5. Run

Three positional arguments — **input dir, output dir, working dir**. The `dir.*` entries in
the properties file are **not read**; they are inert.

`ProcessVCF` processes every `*.vcf` in the input directory, so keep unrelated VCFs out.

```bash
java -Dfile.encoding=UTF-8 -Xms4g -Xmx32g \
     -cp "target/classes:$(cat target/cp.txt)" \
     edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF \
     /path/run_1/input /path/run_1/output /path/run_1/working
```

Prefer this over `mvn exec:java`: it needs no Maven at runtime and makes the heap explicit.

### Required JVM flags

| Flag | Why |
|---|---|
| `-Xmx32g` (16 GB minimum) | `IdMappingManager` reads `enhancer_gene_link_19.tsv` (~1.5 GB) wholly into a `List<String>` via `Files.readAllLines`. The default heap is not enough. |
| `-Dfile.encoding=UTF-8` | The input VCF is read with `new FileReader(...)` and output written with `String.getBytes()` — both use the *platform* default charset, which on CARC is `ANSI_X3.4-1968` (US-ASCII). Also `export LANG=en_US.UTF-8; export LC_ALL=en_US.UTF-8`. |

### Where to put the output

The module calls `Files.write(..., APPEND)` **once per variant**, and writes the working-dir
lookup files with one append **per map entry** (~110,000 at startup). On a shared parallel
filesystem that syscall volume dominates runtime.

- Small inputs: point output and working dirs at node-local scratch and copy back.
- **Check what "local" means first.** On stateless nodes `$TMPDIR` is *tmpfs* (RAM) and
  counts against the job's memory cgroup — staging a large file there gets the job
  OOM-killed. `df -h "$TMPDIR"` will tell you.
- Full chromosomes (output 200+ GB): write straight to project storage. Never to `$HOME`.

### `ProcessVCFParallel`

Parallelises **across files**, one thread per input `.vcf` — not within a file.

**Known data race:** `VCFHeader.ANNOTATION_COL_LOOKUPS` is a static mutable `HashMap`
written from the `VCFHeader` constructor, and this class builds one per file concurrently.
It also sizes its pool as `newFixedThreadPool(numFiles)`, uncapped. To use many cores
safely, run **separate JVMs** (a Slurm job array) instead.

---

## 6. Example `run.sbatch`

The shebang must be the **first byte** of the file — a leading blank line makes `sbatch`
reject it. Run `bash -n run.sbatch` before submitting.

```bash
#!/bin/bash
#SBATCH --job-name=apenh_chr6
#SBATCH --account=myaccount_123
#SBATCH --partition=my_partition
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=13-00:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=myemail@myinst.org

set -uo pipefail

echo "=== host: $(hostname)  job: ${SLURM_JOB_ID:-none}  start: $(date) ==="

module load legacy/CentOS7
module load jdk
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
module list 2>&1; java -version 2>&1

RUN=/path/to/run_1
BUILD=$RUN/annoq-data-builder/java_wgsa_add
MODULE=$BUILD/add_panther_enhancer
IN=$RUN/input
OUT=$RUN/output
WORK=$RUN/working

for d in "$RUN" "$BUILD" "$MODULE" "$IN"; do
  [ -d "$d" ] || { echo "ERROR: not a directory: $d" >&2; exit 1; }
done
[ -f "$MODULE/target/cp.txt" ] || { echo "ERROR: no cp.txt -- run mvn dependency:build-classpath" >&2; exit 1; }

CP="$MODULE/target/classes:$(cat "$MODULE/target/cp.txt")"
mkdir -p "$OUT" "$WORK"

# status.txt is written once per FILE, so a single large input gives no progress for days
( while sleep 1800; do echo "[progress $(date +%F_%H:%M)] $(du -sh "$OUT" 2>/dev/null | cut -f1)"; done ) &
PROG=$!
trap 'kill $PROG 2>/dev/null || true' EXIT

echo "=== run start $(date) ==="
java -Dfile.encoding=UTF-8 -Xms4g -Xmx48g -cp "$CP" \
     edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF "$IN" "$OUT" "$WORK"
RC=$?
echo "=== run end $(date)  java exit=$RC ==="

for f in "$OUT"/*.vcf; do
  echo "$(basename "$f"): $(head -1 "$f" | awk -F'\t' '{print NF}') columns, $(du -h "$f" | cut -f1)"
done
exit $RC
```

Sizing notes:

- **`--cpus-per-task=8`.** One `ProcessVCF` saturates about four threads: a main thread that
  busy-waits on `while (!executor.isTerminated()) {}` plus the 3-thread pool `Snp` creates
  *per variant*. More cores idle — observed CPU efficiency is ~9% on 8 cores, as the process
  is syscall- and I/O-bound.
- **`--mem`** needs to cover the heap plus anything staged in tmpfs. Request memory as
  `--mem` rather than `--mem-per-cpu`; `--mem-per-cpu=32G` with 5 tasks x 5 CPUs asks for
  800 GB and will never schedule.
- **`--nodelist`** takes node *names* (`c02-11`), not a range.

Submit with:

```bash
bash -n run.sbatch && sbatch run.sbatch
```

---

## 7. After the run

1. `status.txt` in the working dir should contain **no** `Unable to create SNP` lines. Any
   such line means a field-count mismatch (see section 1) and that variant was dropped.
2. Output column count = input + 108.
3. `panther_terms.json` is written to the working dir; copy it to
   `annoq-site/src/@annoq.common/data/panther_terms.json` (Part 4).
