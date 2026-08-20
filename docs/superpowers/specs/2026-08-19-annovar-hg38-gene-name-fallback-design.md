# Gene-name fallback for `ANNOVAR_ensembl_Gene_ID` (hg38)

**Date:** 2026-08-19
**Module:** `java_wgsa_add/add_panther_enhancer` (pipeline Part 3)
**Related:** USCbiostats/annoq-site#78, branch `annoq-site-78-add-hrc-mapping-info`

---

## 1. Problem

In WGSA output for the TOPMed (hg38) dataset, the `ANNOVAR_ensembl_Gene_ID` column contains a
mix of Ensembl gene IDs and HGNC gene symbols. Examples from `data/topmed/chr18.vcf`:

| Row | Exact cell content |
|---|---|
| `18:10090` | `LINC02564\|ENSG00000263305` |
| `18:43621` | `TUBB8B` |

The current code resolves this column via
`Snp.LoadToolAnnotations.convertEnsemblGeneIdStrToSet()` → `IdMappingManager.getUniprotIdSetForEnsemblIdSet()`,
which looks each token up in `ensemblToUniprotLookup`. A gene-symbol token misses that map and is
discarded with no diagnostic, so the variant receives no PANTHER / GO / Reactome annotation from
this column.

## 2. Evidence

### 2.1 Scale of the loss

Probe of `run_3/input/chr6.vcf.gz` on CARC (`/project2/huaiyumi_1334/AnnoQ/rel/data_annoq_release_2.0_beta_1/20241016_add_panther_enhancer`),
chr6:0–36 Mb, 8,700,912 rows:

| | rows |
|---|---|
| cells empty (`.` or blank) | 2,828,070 |
| non-empty cells | 5,872,842 |
| **non-empty cells containing at least one gene name** | **4,853,213 (82.6%)** |

A 4,999-row window of `data/topmed/chr18.vcf` (chr18:10,005–45,335) shows the same pattern more
starkly: of 3,036 non-empty cells, **every one** contains a gene name; 534 (17.6%) contain *only*
gene names and therefore receive no annotation at all today.

### 2.2 The problem is hg38-specific

`data/hrc/chr18.vcf` (hg19, 448 columns) and `annoq-api-v2/sample_data/*.vcf` (hg19, 540 columns)
contain **zero** non-ENSG tokens in this column. Gating the change on genome build is therefore
well-founded, and hg19/HRC output is provably unaffected.

### 2.3 Hyphens must not be split

`convertEnsemblGeneIdStrToSet` splits each pipe-delimited token on `-` (`DELIM_ENSEMBL_ALTERNATE`).
That split exists for SnpEff's "intergenic between A and B" notation, which is confined to the
SnpEff columns:

| Column (chr18 sample) | rows containing `-` |
|---|---|
| `ANNOVAR_ensembl_Gene_ID` | **0** |
| `ANNOVAR_refseq_Gene_ID` | **0** |
| `SnpEff_ensembl_Gene_ID` | 3,441 |
| `SnpEff_refseq_Gene_ID` | many |
| `VEP_ensembl_Gene_ID` | **0** |

Real SnpEff cells, for contrast: `CHR_START-ENSG00000262352|ENSG00000263305|...` and
`ENSG00000263305-ENSG00000262181|ENSG00000173213|...`.

In `ANNOVAR_ensembl_Gene_ID`, hyphens only ever appear *inside a single gene symbol*. The chr6
probe found 104 distinct hyphenated tokens (1,971,453 occurrences); cross-referencing every one
against `hgnc_complete_set.txt` (43,840 approved symbols, of which 6,516 — 14.9% — contain a
hyphen):

- **103 of 104** are valid HGNC symbols when kept whole.
- Effect of splitting them on `-`:

| outcome | tokens | rows |
|---|---|---|
| **fabricates** annotations (whole yields none, split invents some) | 38 | 842,294 |
| **contaminates** (adds an unrelated gene's terms) | 7 | 165,233 |
| harmless (whole resolves, split adds nothing) | 26 | 261,060 |
| no annotations either way | 33 | 702,866 |
| **splitting is the only route to resolution** | **0** | **0** |

Splitting has **zero** upside and would place wrong annotations on **1,007,527 rows**. Concrete
cases, with the exact cell each was found in:

```
LY86-AS1          n=307685   6:6341470    [LY86-AS1]
GMDS-DT           n=276165   6:2240742    [GMDS|GMDS-DT]
RPS10-NUDT3       n= 73473   6:34279894   [ENSG00000225339|ENSG00000225339|NUDT3|ENSG00000225339|RPS10-NUDT3]
BLOC1S5-TXNDC5    n= 45697   6:7876526    [BMP6|TXNDC5|BLOC1S5-TXNDC5]
HLA-A             n= 50217   6:29936267   [HLA-A]
ATP6V1G2-DDX39B   n=  5501   6:31525223   [MCCD1|DDX39B|ATP6V1G2-DDX39B|DDX39B]
PPT2-EGFL8        n=  4962   6:32149403   [PRRT1|PRRT1|PPT2|PPT2|PPT2|PPT2|PPT2|PPT2-EGFL8|...]
LY6G6F-LY6G6D     n=  4179   6:31701905   [ABHD16A|ABHD16A|ENSG00000204422|LY6G6F|LY6G6F-LY6G6D|MIR4646]
```

`LY86-AS1` is an antisense lncRNA with no UniProt entry — it should carry *no* PANTHER terms.
Splitting hands it `LY86`'s terms. `ATP6V1G2-DDX39B` is a readthrough whose halves are two
independent genes.

**Decision: tokens are never split on `-` in the gene-name path.**

### 2.4 Honest ceiling on the benefit

Tracing the full chain symbol → ENSG (HGNC) → UniProt (`UP000005640_9606.idmapping`, 23,103
distinct ENSG) → PANTHER, for the 104 hyphenated tokens:

| | tokens | rows |
|---|---|---|
| chain complete — will gain PANTHER terms | 33 | 426,293 |
| ENSG found but no UniProt entry (lncRNA / antisense / pseudogene) | 69 | 1,538,951 |
| no ENSG in HGNC (`TFAP2A-AS2`, `KU-MEL-3`) | 2 | 6,209 |

(The "33" here is unrelated to the "33 tokens / 702,866 rows" row in §2.3 — different partitions of
the same 104 tokens that coincidentally have equal counts.)

Most hyphenated tokens are non-coding features that correctly have no protein annotation. The fix
recovers genuine annotations *and* correctly leaves non-coding features empty — which is precisely
what splitting would destroy.

### 2.5 Verified non-issues

- `IdMappingManager.initHgncIdMappingInfo` skips HGNC lines where `String.split` yields ≤ 19
  fields (Java drops trailing empties). This affects 136 of 43,840 data lines — **all** of which have
  an empty `ensembl_gene_id`, so they could never contribute to the chain. Harmless; no change needed.
- A missing property returns `null` from `ConfigFile.getProperty` (with a console warning) rather
  than throwing, so an old properties file degrades to current behavior.

## 3. Scope

Confirmed with the requester:

| Decision | Setting |
|---|---|
| New parameter applies to | hg38 data only |
| Columns whose parsing changes | `ANNOVAR_ensembl_Gene_ID` **only** |
| Resolution order | Ensembl gene ID first, then gene name |
| Output columns | **No** column added, removed, renamed or reordered (830 stays 830) |
| Dead-code removal | In scope |
| Unit tests | In scope |

**Out of scope:** SnpEff and VEP columns; `ANNOVAR_refseq_Gene_ID` (already symbol-based);
`annotation_tree.csv`, ES mappings, API and site changes.

**Explicitly expected:** annotation *values* change for hg38 — the ANNOVAR PANTHER columns and
`Uniprot_mapped_to_ANNOVAR_ensembl_Gene_ID` become more populated. That is the fix, not a
regression, and it means the hg38 index must be rebuilt.

## 4. Design

### 4.1 New property

`src/main/resources/add_panther_enhancer.properties`:

```properties
# Genome build of the input WGSA VCF files: hg38 or hg19.
# hg38 enables the gene-symbol fallback for ANNOVAR_ensembl_Gene_ID, which in WGSA
# hg38/TOPMed output mixes Ensembl gene ids with HGNC gene symbols.
genome.build=hg38
```

Absent, blank or any other value ⇒ current behavior exactly. `target/classes/…properties` is a
build artifact; Maven re-copies it.

### 4.2 A pure parser, separated for testability

The resolution step needs `IdMappingManager`, which loads several gigabytes of reference files at
startup. Putting the tokenizing logic inside `Snp.LoadToolAnnotations` would make the subtle part —
the tokenizer — effectively untestable. The tokenizer is therefore extracted as a **pure static
helper** with no I/O and no dependency on any manager:

`util/AnnovarGeneIdParser.java` (new)

```java
/**
 * Splits an ANNOVAR_ensembl_Gene_ID cell into Ensembl gene ids and gene-symbol candidates.
 *
 * WGSA hg38 (TOPMed) output mixes Ensembl gene ids and HGNC gene symbols in this column.
 * Tokens are pipe delimited.  Unlike the SnpEff columns, this column never uses '-' as an id
 * separator, so tokens are kept whole: of the 104 distinct hyphenated tokens observed on chr6,
 * 103 are valid HGNC symbols (HLA-A, LY86-AS1, PPT2-EGFL8, ATP6V1G2-DDX39B ...).  Splitting
 * them would place wrong annotations on ~1M rows.
 */
public class AnnovarGeneIdParser {
    public static final String DELIM_TOKEN = "\\|";
    public static final String PREFIX_ENSEMBL_GENE_ID = "ENSG";

    public static Set<String> extractEnsemblGeneIds(String cell);      // tokens starting with ENSG
    public static Set<String> extractGeneSymbolCandidates(String cell); // all other tokens
}
```

Both methods are null-safe, skip blank tokens and the `.` placeholder, trim whitespace, and
de-duplicate. `Snp` composes them with the lookup; the parser itself stays trivially testable.

Classification rule: a token is an Ensembl gene ID **iff** it starts with `ENSG`; everything else is
a gene-symbol candidate. No HGNC symbol begins with `ENSG`. A hypothetical version-suffixed token
(`ENSG00000263305.5`, never observed in this column) classifies as an Ensembl ID and misses the
lookup — identical to current behavior, so this is not a regression.

### 4.3 Wiring in `Snp.java`

`convertEnsemblGeneIdStrToSet` is **left untouched** so SnpEff and VEP cannot regress.

Cache the flag once — `Snp` is constructed per VCF line, so this must not be a per-instance
property read:

```java
private static final boolean GENE_NAME_FALLBACK_ENABLED = isGeneNameFallbackEnabled();

private static boolean isGeneNameFallbackEnabled() {
    String build = ConfigFile.getProperty(Constants.PROPERTY_GENOME_BUILD);
    return null != build && Constants.GENOME_BUILD_HG38.equalsIgnoreCase(build.trim());
}
```

New resolution method on `LoadToolAnnotations`:

```java
Set<String> resolveAnnovarEnsemblGeneIdToEnsemblIdSet(String annovarEnsemblGeneIdStr) {
    if (false == GENE_NAME_FALLBACK_ENABLED) {
        return convertEnsemblGeneIdStrToSet(annovarEnsemblGeneIdStr);   // hg19 path, unchanged
    }
    Set<String> ensemblIdSet = AnnovarGeneIdParser.extractEnsemblGeneIds(annovarEnsemblGeneIdStr);
    Set<String> symbolCandidates =
            AnnovarGeneIdParser.extractGeneSymbolCandidates(annovarEnsemblGeneIdStr);
    if (symbolCandidates.isEmpty()) {
        return ensemblIdSet;
    }
    IdMappingManager im = IdMappingManager.getInstance(Snp.this.workingDir);
    for (String symbol : symbolCandidates) {
        ArrayList<String> mapped = im.getEnsemblIdsForSymbol(symbol);
        if (null == mapped) {
            continue;
        }
        for (String ensemblId : mapped) {
            if (false == ensemblId.isEmpty()) {   // HGNC rows with blank ensembl_gene_id
                ensemblIdSet.add(ensemblId);
            }
        }
    }
    return ensemblIdSet;
}
```

Single call site change — `Snp.java:606`:

```java
- Set<String> ensemblGeneIdSet = convertEnsemblGeneIdStrToSet(AnnovarEnsemblGeneId);
+ Set<String> ensemblGeneIdSet = resolveAnnovarEnsemblGeneIdToEnsemblIdSet(AnnovarEnsemblGeneId);
```

Everything downstream (`getUniprotIdSetForEnsemblIdSet` → `getPantherAnnotationsForUniprotIdSet`)
is reused unchanged.

### 4.4 `Constants.java` additions

```java
public static final String PROPERTY_GENOME_BUILD = "genome.build";
public static final String GENOME_BUILD_HG38 = "hg38";
public static final String GENOME_BUILD_HG19 = "hg19";
```

### 4.5 `IdMappingManager.java`

No change. `getEnsemblIdsForSymbol()` already exists and is already used for the ANNOVAR/SnpEff
refseq symbol columns.

### 4.6 Rejected alternative

Also querying `geneNameToUniprotLookup` (UniProt `Gene_Name`, loaded but commented out as "data
seems to be incomplete"). It could only help the 2 tokens HGNC has no ENSG for — `TFAP2A-AS2` and
`KU-MEL-3` — and neither has a UniProt entry. No gain; not implemented.

## 5. Dead-code removal

`Snp.LoadToolAnnotations.run()` lines 595–600 assign all six `PantherAnnotsFor*` fields, and
lines 609, 619, 627, 637, 645 and 656 then recompute **every one of them by an identical code
path** and overwrite the result. All six initial calls are dead, so the module currently performs
the entire ID-mapping and PANTHER-lookup workload **twice per SNP**.

Equivalence was verified per pair; e.g. `processEnsemblGeneId(s)` expands to
`getPantherAnnotationsForEnsembleIdSet(convertEnsemblGeneIdStrToSet(s))`, which is
`getUniprotIdSetForEnsemblIdSet` followed by `getPantherAnnotationsForUniprotIdSet` — exactly what
line 609 does. The empty/null input cases also coincide. No field is read between assignment and
overwrite.

**Change:** delete lines 595–600, plus the two methods that become unreachable —
`processEnsemblGeneId` and `processRefSeqGeneId`. Keep `convertEnsemblGeneIdStrToSet` (still used
by the SnpEff and VEP paths and by the hg19 branch above) and keep `Constants.AnnotationTool`.

This is behavior-neutral and roughly halves per-SNP mapping work. It ships as a **separate commit**
from the correctness change so the two can be reviewed independently.

## 6. Testing

### 6.1 Unit tests (new)

No test infrastructure exists (`src/` has only `main`; JUnit is commented out in `pom.xml`). Add:

- `pom.xml`: JUnit 4.13.2 with `<scope>test</scope>`.
- `src/test/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParserTest.java`

Cases, all drawn from real cells found in the data:

| Input cell | expected Ensembl IDs | expected symbol candidates |
|---|---|---|
| `LINC02564\|ENSG00000263305` | `ENSG00000263305` | `LINC02564` |
| `TUBB8B` | — | `TUBB8B` |
| `ENSG00000263305` | `ENSG00000263305` | — |
| `HLA-A` | — | `HLA-A` (not `HLA`, `A`) |
| `PPT2-EGFL8` | — | `PPT2-EGFL8` (not `PPT2`, `EGFL8`) |
| `ATP6V1G2-DDX39B` | — | `ATP6V1G2-DDX39B` |
| `HLA-DQB1-AS1\|HLA-DQB1\|HLA-DQB1` | — | `HLA-DQB1-AS1`, `HLA-DQB1` (deduped) |
| `MCCD1\|DDX39B\|ATP6V1G2-DDX39B\|DDX39B` | — | `MCCD1`, `DDX39B`, `ATP6V1G2-DDX39B` |
| `ENSG00000225339\|ENSG00000225339\|NUDT3\|RPS10-NUDT3` | `ENSG00000225339` | `NUDT3`, `RPS10-NUDT3` |
| `""`, `.`, `null` | — | — |

The hyphen cases are the point of the suite: they lock in the decision from §2.3 so a future
refactor cannot silently reintroduce splitting.

### 6.2 Empirical A/B

1. Run Part 3 on a chr6 slice with `genome.build` unset — output must be **byte-identical** to the
   current build (guards the dead-code removal and the hg19 path).
2. Run with `genome.build=hg38` and diff:
   - ANNOVAR PANTHER columns and `Uniprot_mapped_to_ANNOVAR_ensembl_Gene_ID` gain values;
   - **all other columns byte-identical**;
   - spot-check `6:29936267` (`HLA-A`) now annotated, and `6:6341470` (`LY86-AS1`) still empty —
     the latter proves hyphens were not split.
3. Confirm column count is still 830.

**Verifiability caveat:** there is no `Ensembl_mapped_to_ANNOVAR_ensembl_Gene_ID` output column
(only the `Uniprot_mapped_to_` one), so symbol→ENSG resolutions are not directly visible in the
VCF — only their downstream effect. `output.debug=true` diagnostics can expose them if that
traceability is wanted.

## 7. Sequencing

1. Code change + `mvn package`.
2. Unit tests pass; chr6 A/B diff reviewed (§6.2).
3. Re-run **Part 3** on the hg38/TOPMed HRC-merged VCF with `genome.build=hg38`.
   HRC/hg19 needs no re-run.
4. Regenerate JSON → load into ES → verify counts.
5. README: note in Part 3 that hg38 runs require `genome.build=hg38`.

Because annotation values change, the existing hg38 index must be rebuilt. Column count is
unchanged, so `annotation_tree.csv`, `annoq_mappings.json`, the API and the site need no change.

## 8. Files touched

```
java_wgsa_add/add_panther_enhancer/
├── pom.xml                                               (JUnit test dep)
├── src/main/resources/add_panther_enhancer.properties    (+4 lines)
├── src/main/java/.../constants/Constants.java            (+3 constants)
├── src/main/java/.../util/AnnovarGeneIdParser.java        (new, pure)
├── src/main/java/.../datamodel/Snp.java                   (+flag, +method, 1 call site,
│                                                           -6 dead calls, -2 dead methods)
└── src/test/java/.../util/AnnovarGeneIdParserTest.java    (new)
README.md                                                  (Part 3 note)
```
