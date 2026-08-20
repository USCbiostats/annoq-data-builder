# ANNOVAR hg38 Gene-Name Fallback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When processing hg38 WGSA input, resolve gene-symbol tokens in the `ANNOVAR_ensembl_Gene_ID` column to Ensembl gene IDs so those variants receive PANTHER/GO/Reactome annotations instead of being silently dropped.

**Architecture:** A new pure static parser (`AnnovarGeneIdParser`) splits an `ANNOVAR_ensembl_Gene_ID` cell into Ensembl-ID tokens and gene-symbol tokens with no I/O, making it unit-testable without the module's multi-gigabyte reference files. `Snp.LoadToolAnnotations` composes that parser with the existing `IdMappingManager.getEnsemblIdsForSymbol()` HGNC lookup, gated on a new `genome.build=hg38` property. The existing `convertEnsemblGeneIdStrToSet` is left untouched so the SnpEff and VEP columns cannot regress.

**Tech Stack:** Java 11, Maven 3.6.3, JUnit 4.13.2, `javax.json` 1.1, htsjdk 1.129.

## Global Constraints

- **Do not `git push`, open a PR, or otherwise publish anything.** The user instructed "Do not check anything into github." Commit steps below are **local commits only**. If the user prefers zero commits, stage the files and stop instead — confirm before the first commit.
- Module root for all paths: `java_wgsa_add/add_panther_enhancer/`. All `mvn` commands run from there.
- Java source/target level is **11** (`pom.xml` `maven.compiler.source`/`target`). Do not raise it.
- `ANNOVAR_ensembl_Gene_ID` is the **only** column whose parsing may change. `convertEnsemblGeneIdStrToSet` must remain byte-for-byte unchanged.
- **No output column may be added, removed, renamed, or reordered.** Output stays at 830 columns for the 830-column input. `Snp.COLS_TO_BE_ADDED` must not change.
- Gene-symbol tokens are **never** split on `-`. This is load-bearing: splitting resolves 0 extra tokens and would place wrong annotations on 1,007,527 rows of chr6:0–36 Mb. Task 1's tests enforce it.
- Property absent, blank, or any value other than `hg38` (case-insensitive) ⇒ behavior identical to today.
- `src/main/resources/add_panther_enhancer.properties` is version-controlled and contains `C:/...` Windows paths. Any path edits made for local validation are **environment-specific and must be reverted** before committing. Only the `genome.build` line is a real change.
- `target/classes/add_panther_enhancer.properties` is a build artifact. Never edit it; Maven re-copies from `src/main/resources`.

**Spec:** `docs/superpowers/specs/2026-08-19-annovar-hg38-gene-name-fallback-design.md`

---

## File Structure

| Path (relative to `java_wgsa_add/add_panther_enhancer/`) | Responsibility | Task |
|---|---|---|
| `pom.xml` | Add JUnit 4.13.2 test-scoped dependency | 1 |
| `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParser.java` | **New.** Pure tokenizer: split one `ANNOVAR_ensembl_Gene_ID` cell into Ensembl IDs vs gene-symbol candidates. No I/O, no manager dependencies. | 1 |
| `src/test/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParserTest.java` | **New.** Unit tests, incl. the hyphen-preservation guards | 1 |
| `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/datamodel/Snp.java` | Remove 6 dead calls + 2 orphaned methods (Task 2); add build flag, resolution method, 1 call-site change (Task 3) | 2, 3 |
| `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/constants/Constants.java` | Add 3 property/build constants | 3 |
| `src/main/resources/add_panther_enhancer.properties` | Add `genome.build=hg38` | 3 |
| `../../README.md` (repo root) | Part 3 note: hg38 runs need `genome.build=hg38` | 4 |

**Do not delete** `IdMappingManager.getPantherAnnotationsForEnsembleIdSet`, `getPantherAnnotationsForGeneSymbolsFromAnnovarAndSneff`, or `getPantherAnnotationsForEntrezIdSetFromVep` in Task 2. They become unreferenced but are public manager API; removing them widens the blast radius for no benefit. Likewise keep `Constants.AnnotationTool`.

---

### Task 1: Pure `AnnovarGeneIdParser` + unit tests

Adds a new, initially-unused class. No pipeline behavior changes in this task.

**Files:**
- Modify: `pom.xml` (JUnit dependency, replacing the commented-out block)
- Create: `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParser.java`
- Test: `src/test/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParserTest.java`

**Interfaces:**
- Consumes: `Constants.VCF_PLACEHOLDER_EMPTY` (`"."`) — already exists in `constants/Constants.java`. Loading `Constants` is safe from tests: its static initializer only builds an in-memory `HashMap` and never touches `ConfigFile` or the filesystem.
- Produces, both used by Task 3:
  - `public static Set<String> AnnovarGeneIdParser.extractEnsemblGeneIds(String cell)`
  - `public static Set<String> AnnovarGeneIdParser.extractGeneSymbolCandidates(String cell)`
  - Both return a `LinkedHashSet<String>` (insertion-ordered, de-duplicated), never `null`, empty for `null`/blank/`"."` input.
  - `public static final String AnnovarGeneIdParser.PREFIX_ENSEMBL_GENE_ID = "ENSG"`

- [ ] **Step 1: Add the JUnit test dependency**

In `pom.xml`, find the commented-out **junit** block at **lines 32–37**. Note there is a *second*
commented-out `<dependency>` block at lines 15–20 for `org.json` — **leave that one alone**. The
block to replace is:

```xml
<!--        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <type>jar</type>
        </dependency>-->
```

Replace it entirely with (note `4.13.2`, not `4.12` — 4.12 carries CVE-2020-15250 — and `test` scope so it is not packaged):

```xml
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.13.2</version>
            <scope>test</scope>
        </dependency>
```

- [ ] **Step 2: Write the failing test**

Create `src/test/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParserTest.java`.

Every input string below is a real cell observed in WGSA hg38 output — `chr18` cells from `data/topmed/chr18.vcf`, `chr6` cells from the CARC probe of `run_3/input/chr6.vcf.gz`.

```java
package edu.usc.ksom.pphs.add_panther_enhancer.util;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class AnnovarGeneIdParserTest {

    private static Set<String> setOf(String... values) {
        return new HashSet<String>(Arrays.asList(values));
    }

    private static Set<String> empty() {
        return Collections.<String>emptySet();
    }

    // ---------- mixed id + symbol: chr18:10090 ----------

    @Test
    public void mixedCellSplitsIntoIdAndSymbol() {
        String cell = "LINC02564|ENSG00000263305";
        assertEquals(setOf("ENSG00000263305"), AnnovarGeneIdParser.extractEnsemblGeneIds(cell));
        assertEquals(setOf("LINC02564"), AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
    }

    // ---------- symbol only: chr18:43621 ----------

    @Test
    public void symbolOnlyCellYieldsNoEnsemblIds() {
        String cell = "TUBB8B";
        assertEquals(empty(), AnnovarGeneIdParser.extractEnsemblGeneIds(cell));
        assertEquals(setOf("TUBB8B"), AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
    }

    // ---------- id only ----------

    @Test
    public void ensemblOnlyCellYieldsNoSymbols() {
        String cell = "ENSG00000263305";
        assertEquals(setOf("ENSG00000263305"), AnnovarGeneIdParser.extractEnsemblGeneIds(cell));
        assertEquals(empty(), AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
    }

    // ---------- HYPHEN GUARDS: these must never be split on '-' ----------
    // Splitting resolves 0 extra tokens and would place wrong annotations on
    // 1,007,527 rows of chr6:0-36Mb.  See spec section 2.3.

    @Test
    public void hlaSymbolIsKeptWhole() {           // chr6:29936267
        assertEquals(setOf("HLA-A"), AnnovarGeneIdParser.extractGeneSymbolCandidates("HLA-A"));
    }

    @Test
    public void readthroughSymbolIsKeptWhole() {   // chr6:32149403
        assertEquals(setOf("PPT2-EGFL8"),
                AnnovarGeneIdParser.extractGeneSymbolCandidates("PPT2-EGFL8"));
    }

    @Test
    public void readthroughWithBothHalvesValidIsKeptWhole() {  // chr6:31525223
        String cell = "MCCD1|DDX39B|ATP6V1G2-DDX39B|DDX39B";
        assertEquals(setOf("MCCD1", "DDX39B", "ATP6V1G2-DDX39B"),
                AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
        assertEquals(empty(), AnnovarGeneIdParser.extractEnsemblGeneIds(cell));
    }

    @Test
    public void antisenseSymbolIsKeptWhole() {     // chr6:6341470
        assertEquals(setOf("LY86-AS1"),
                AnnovarGeneIdParser.extractGeneSymbolCandidates("LY86-AS1"));
    }

    @Test
    public void multiHyphenSymbolIsKeptWhole() {   // chr6:32654891
        String cell = "HLA-DQB1-AS1|HLA-DQB1|HLA-DQB1";
        assertEquals(setOf("HLA-DQB1-AS1", "HLA-DQB1"),
                AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
    }

    // ---------- de-duplication and mixed content: chr6:34279894 ----------

    @Test
    public void duplicateTokensAreCollapsed() {
        String cell = "ENSG00000225339|ENSG00000225339|NUDT3|ENSG00000225339|RPS10-NUDT3";
        assertEquals(setOf("ENSG00000225339"), AnnovarGeneIdParser.extractEnsemblGeneIds(cell));
        assertEquals(setOf("NUDT3", "RPS10-NUDT3"),
                AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
    }

    // ---------- degenerate input ----------

    @Test
    public void emptyStringYieldsEmptySets() {
        assertEquals(empty(), AnnovarGeneIdParser.extractEnsemblGeneIds(""));
        assertEquals(empty(), AnnovarGeneIdParser.extractGeneSymbolCandidates(""));
    }

    @Test
    public void vcfPlaceholderYieldsEmptySets() {
        assertEquals(empty(), AnnovarGeneIdParser.extractEnsemblGeneIds("."));
        assertEquals(empty(), AnnovarGeneIdParser.extractGeneSymbolCandidates("."));
    }

    @Test
    public void nullYieldsEmptySets() {
        assertEquals(empty(), AnnovarGeneIdParser.extractEnsemblGeneIds(null));
        assertEquals(empty(), AnnovarGeneIdParser.extractGeneSymbolCandidates(null));
    }

    @Test
    public void blankAndPlaceholderTokensAreSkipped() {
        String cell = "TUBB8B||.| ENSG00000263305 ";
        assertEquals(setOf("ENSG00000263305"), AnnovarGeneIdParser.extractEnsemblGeneIds(cell));
        assertEquals(setOf("TUBB8B"), AnnovarGeneIdParser.extractGeneSymbolCandidates(cell));
    }
}
```

- [ ] **Step 3: Run the test to verify it fails**

```bash
cd java_wgsa_add/add_panther_enhancer
mvn -q test -Dtest=AnnovarGeneIdParserTest
```

Expected: **compilation failure**, `cannot find symbol: class AnnovarGeneIdParser`. That is the correct failure — the class does not exist yet.

- [ ] **Step 4: Write the minimal implementation**

Create `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParser.java`:

```java
/*
* MIT License
* Copyright (c) 2024 HUAIYU MI
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
package edu.usc.ksom.pphs.add_panther_enhancer.util;

import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Splits a single ANNOVAR_ensembl_Gene_ID cell into Ensembl gene ids and gene-symbol candidates.
 *
 * WGSA hg38 (TOPMed) output mixes Ensembl gene ids and HGNC gene symbols in this column, for
 * example "LINC02564|ENSG00000263305" and "TUBB8B".  Tokens are pipe delimited.
 *
 * Tokens are deliberately NOT split on '-'.  The SnpEff columns use '-' to mean "intergenic
 * between gene A and gene B", but that notation never appears in this column; here a hyphen only
 * ever occurs inside a single gene symbol.  Of the 104 distinct hyphenated tokens observed in
 * chr6:0-36Mb, 103 are valid HGNC symbols (HLA-A, LY86-AS1, PPT2-EGFL8, ATP6V1G2-DDX39B ...).
 * Splitting them resolves no additional tokens and would attach wrong annotations to roughly
 * one million rows, so tokens are kept whole.
 *
 * This class is intentionally free of I/O and of any IdMappingManager dependency so it can be
 * unit tested without the module's reference data files.
 */
public class AnnovarGeneIdParser {

    public static final String DELIM_TOKEN = "\\|";
    public static final String PREFIX_ENSEMBL_GENE_ID = "ENSG";

    private AnnovarGeneIdParser() {
    }

    /**
     * @return insertion-ordered, de-duplicated tokens that are Ensembl gene ids.  Never null.
     */
    public static Set<String> extractEnsemblGeneIds(String cell) {
        return extractTokens(cell, true);
    }

    /**
     * @return insertion-ordered, de-duplicated tokens that are not Ensembl gene ids and are
     *         therefore candidate HGNC gene symbols.  Never null.
     */
    public static Set<String> extractGeneSymbolCandidates(String cell) {
        return extractTokens(cell, false);
    }

    private static Set<String> extractTokens(String cell, boolean wantEnsemblGeneIds) {
        LinkedHashSet<String> tokens = new LinkedHashSet<String>();
        if (null == cell) {
            return tokens;
        }
        String parts[] = cell.split(DELIM_TOKEN);
        for (int i = 0; i < parts.length; i++) {
            String token = parts[i].trim();
            if (token.isEmpty()) {
                continue;
            }
            if (Constants.VCF_PLACEHOLDER_EMPTY.equals(token)) {
                continue;
            }
            boolean isEnsemblGeneId = token.startsWith(PREFIX_ENSEMBL_GENE_ID);
            if (isEnsemblGeneId == wantEnsemblGeneIds) {
                tokens.add(token);
            }
        }
        return tokens;
    }
}
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
mvn -q test -Dtest=AnnovarGeneIdParserTest
```

Expected: `Tests run: 13, Failures: 0, Errors: 0, Skipped: 0`.

If `mvn -q` suppresses the summary, re-run without `-q`.

- [ ] **Step 6: Confirm the main build still compiles**

```bash
mvn -q clean package -DskipTests
```

Expected: exit code 0, `target/add_panther_enhancer-1.0-SNAPSHOT.jar` produced.

- [ ] **Step 7: Local commit (do NOT push)**

```bash
git add java_wgsa_add/add_panther_enhancer/pom.xml \
        java_wgsa_add/add_panther_enhancer/src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParser.java \
        java_wgsa_add/add_panther_enhancer/src/test/java/edu/usc/ksom/pphs/add_panther_enhancer/util/AnnovarGeneIdParserTest.java
git commit -m "Add pure AnnovarGeneIdParser with unit tests for #78

Splits an ANNOVAR_ensembl_Gene_ID cell into Ensembl gene ids and gene-symbol
candidates without splitting on '-'.  Tests lock in hyphen preservation."
```

---

### Task 2: Remove dead double-computation in `Snp.LoadToolAnnotations.run()`

Behavior-neutral. Verified by byte-identical pipeline output in Task 4.

**Why:** `run()` assigns all six `PantherAnnotsFor*` fields at lines 595–600, then lines 609, 619, 627, 637, 645 and 656 recompute every one of them through an identical code path and overwrite the result. No field is read in between. The module therefore performs the entire ID-mapping and PANTHER-lookup workload **twice per SNP**.

Equivalence, verified pair by pair:
- `processEnsemblGeneId(s)` = `getPantherAnnotationsForEnsembleIdSet(convertEnsemblGeneIdStrToSet(s))`, and `getPantherAnnotationsForEnsembleIdSet` = `getUniprotIdSetForEnsemblIdSet` then `getPantherAnnotationsForUniprotIdSet` — exactly what lines 606–609 do.
- `processRefSeqGeneId(s, ANNOVAR|SNEFF)` = `getPantherAnnotationsForGeneSymbolsFromAnnovarAndSneff(...)` = `getEnsemblIdsForGeneSymblsFromAnnovarAndSneff` → `getUniprotIdSetForEnsemblIdSet` → `getPantherAnnotationsForUniprotIdSet` — exactly lines 614–619 and 632–637.
- `processRefSeqGeneId(s, VEP)` = `getPantherAnnotationsForEntrezIdSetFromVep(...)` = `getEnsembleIdsForEntrezIdSetFromVep` → `getUniprotIdSetForEnsemblIdSet` → `getPantherAnnotationsForUniprotIdSet` — exactly lines 651–656.
- Empty/null input coincides too: at line 619 an empty `AnnovarRefSeqGeneId` gives `geneSymbolSet = {""}`, `getEnsemblIdsForSymbol("")` returns `null`, so the Ensembl set is empty — the same result as `processRefSeqGeneId`'s explicit empty branch.

**Files:**
- Modify: `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/datamodel/Snp.java` (delete lines 595–600; delete methods `processEnsemblGeneId` at 694–696 and `processRefSeqGeneId` at 698–725)

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: no new API. After this task `convertEnsemblGeneIdStrToSet`, `parsetRefSeqGeneIdStrFromAnnovarSnpEffToSet` and `parseRefSeqGeneIdStrFromVep` all remain, still called from `run()`.

- [ ] **Step 1: Record a baseline output for comparison**

Build and run the current code on the small hg38 fixture, before touching anything. This baseline is reused in Task 4.

```bash
cd /home/muruganu/projects/temp/top_med/annoq-data-builder/java_wgsa_add/add_panther_enhancer
mvn -q clean package -DskipTests
mvn -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
```

The properties file points at `C:/projects/...`, which does not resolve under WSL. Temporarily repoint it (**revert before any commit** — see Global Constraints):

```bash
cd /home/muruganu/projects/temp/top_med/annoq-data-builder
cp java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties /tmp/props.backup
sed -i 's#C:/projects/annoq_data_builder_add_panther_enhancer#/mnt/c/projects/annoq_data_builder_add_panther_enhancer#g' \
    java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
grep '^file\.' java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
```

Expected: all five `file.*` values now begin `/mnt/c/projects/...`. Verify each exists:

```bash
for f in $(grep '^file\.' java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties | cut -d= -f2); do
  [ -f "$f" ] && echo "OK   $f" || echo "MISS $f"
done
```

Expected: five `OK` lines. Then run the baseline:

```bash
cd java_wgsa_add/add_panther_enhancer
mvn -q clean package -DskipTests
B=/tmp/ab_baseline
rm -rf $B && mkdir -p $B/in $B/out $B/work
cp /home/muruganu/projects/temp/top_med/data/topmed/chr18.vcf $B/in/
java -cp target/classes:$(cat target/cp.txt) \
     edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF $B/in $B/out $B/work
```

Expected: `Finished processing files`, and `$B/out/chr18.vcf` exists. Record its checksum and column count:

```bash
md5sum $B/out/chr18.vcf | tee /tmp/ab_baseline.md5
head -1 $B/out/chr18.vcf | awk -F'\t' '{print NF" columns"}'
```

Expected: `830 columns`.

- [ ] **Step 2: Delete the six dead assignments**

In `Snp.java`, inside `LoadToolAnnotations.run()`, delete exactly these six lines (595–600):

```java
            PantherAnnotsForAnnovarEnsemblGeneId = processEnsemblGeneId(AnnovarEnsemblGeneId);
            PantherAnnotsForAnnovarRefSeqGeneId = processRefSeqGeneId(AnnovarRefSeqGeneId, Constants.AnnotationTool.ANNOVAR);
            PantherAnnotsForSnpEffEnsemblGeneId = processEnsemblGeneId(SnpEffEnsemblGeneId);
            PantherAnnotsForSnpEffRefSeqGeneId = processRefSeqGeneId(SnpEffRefSeqGeneId, Constants.AnnotationTool.SNEFF);
            PantherAnnotsForVepEnsemblGeneId = processEnsemblGeneId(VepEnsemblGeneId);
            PantherAnnotsForVepRefSeqGeneId = processRefSeqGeneId(VepRefSeqGeneId, Constants.AnnotationTool.VEP);
```

Leave the commented-out `PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic` lines that follow, and leave everything from `IdMappingManager im = IdMappingManager.getInstance(...)` onward intact.

- [ ] **Step 3: Delete the two now-orphaned methods**

Delete `processEnsemblGeneId` (lines 694–696):

```java
        ArrayList<String> processEnsemblGeneId(String ensemblGeneIdStr) {
            return IdMappingManager.getInstance(Snp.this.workingDir).getPantherAnnotationsForEnsembleIdSet(convertEnsemblGeneIdStrToSet(ensemblGeneIdStr), DELIM_ADDED_ANNOTATIONS);
        }
```

Delete `processRefSeqGeneId` in full (lines 698–725) — the method signature, the null/empty guard, the `switch (annotTool)` block with its `ANNOVAR`/`SNEFF` and `VEP` cases including the commented-out body inside, and the trailing `return null;` and closing brace.

Do **not** delete `convertEnsemblGeneIdStrToSet`, `parsetRefSeqGeneIdStrFromAnnovarSnpEffToSet`, `parseRefSeqGeneIdStrFromVep`, `Constants.AnnotationTool`, or any `IdMappingManager` method.

- [ ] **Step 4: Verify it compiles and nothing references the deleted methods**

```bash
cd java_wgsa_add/add_panther_enhancer
mvn -q clean package -DskipTests
grep -rn "processEnsemblGeneId\|processRefSeqGeneId" src/ || echo "no references remain"
```

Expected: build succeeds; `no references remain`.

- [ ] **Step 5: Verify output is byte-identical to the baseline**

```bash
mvn -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
A=/tmp/ab_nodead
rm -rf $A && mkdir -p $A/in $A/out $A/work
cp /home/muruganu/projects/temp/top_med/data/topmed/chr18.vcf $A/in/
java -cp target/classes:$(cat target/cp.txt) \
     edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF $A/in $A/out $A/work
diff -q /tmp/ab_baseline/out/chr18.vcf $A/out/chr18.vcf && echo "IDENTICAL - dead code removal is behavior-neutral"
```

Expected: `IDENTICAL - dead code removal is behavior-neutral`.

**If the files differ, stop and do not proceed.** A difference means the equivalence argument above is wrong somewhere; report the first differing column rather than adjusting the test.

- [ ] **Step 6: Run the unit tests**

```bash
mvn -q test
```

Expected: `Tests run: 13, Failures: 0, Errors: 0`.

- [ ] **Step 7: Local commit (do NOT push)**

```bash
cd /home/muruganu/projects/temp/top_med/annoq-data-builder
git add java_wgsa_add/add_panther_enhancer/src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/datamodel/Snp.java
git commit -m "Remove dead double-computation in Snp.LoadToolAnnotations for #78

Lines 595-600 computed all six PantherAnnotsFor* values which were then
recomputed identically and overwritten, doing the whole ID-mapping and
PANTHER-lookup workload twice per SNP.  Verified byte-identical output."
```

Note: `add_panther_enhancer.properties` is intentionally **not** staged — its path edit is local-only.

---

### Task 3: `genome.build` property and the gene-name fallback

The behavior change.

**Files:**
- Modify: `src/main/resources/add_panther_enhancer.properties`
- Modify: `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/constants/Constants.java`
- Modify: `src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/datamodel/Snp.java`

**Interfaces:**
- Consumes from Task 1: `AnnovarGeneIdParser.extractEnsemblGeneIds(String)` and `AnnovarGeneIdParser.extractGeneSymbolCandidates(String)`, both `static`, both returning `Set<String>`.
- Consumes existing: `IdMappingManager.getEnsemblIdsForSymbol(String)` returning `ArrayList<String>` or `null`; `ConfigFile.getProperty(String)` returning `String` or `null`.
- Produces: `Snp.LoadToolAnnotations.resolveAnnovarEnsemblGeneIdToEnsemblIdSet(String)` returning `Set<String>`; `Constants.PROPERTY_GENOME_BUILD`, `Constants.GENOME_BUILD_HG38`, `Constants.GENOME_BUILD_HG19`.

- [ ] **Step 1: Add the constants**

In `constants/Constants.java`, add immediately after the existing `public static final String VCF_PLACEHOLDER_EMPTY = ".";` line:

```java
    // Genome build of the input WGSA VCF files.  hg38 (TOPMed) output mixes Ensembl gene ids and
    // HGNC gene symbols in the ANNOVAR_ensembl_Gene_ID column; hg19 (HRC) output does not.
    public static final String PROPERTY_GENOME_BUILD = "genome.build";
    public static final String GENOME_BUILD_HG38 = "hg38";
    public static final String GENOME_BUILD_HG19 = "hg19";
```

- [ ] **Step 2: Add the property**

In `src/main/resources/add_panther_enhancer.properties`, add at the end, just above the existing `output.debug=false` line:

```properties
# Genome build of the input WGSA VCF files: hg38 or hg19.
# hg38 enables the gene-symbol fallback for ANNOVAR_ensembl_Gene_ID, which in WGSA
# hg38/TOPMed output mixes Ensembl gene ids with HGNC gene symbols.  Any other value,
# a blank value, or omitting the property entirely leaves parsing unchanged.
genome.build=hg38

```

- [ ] **Step 3: Add the imports and the cached build flag to `Snp`**

In `Snp.java`, add these two imports alongside the existing `edu.usc.ksom.pphs...` imports:

```java
import edu.usc.ksom.pphs.add_panther_enhancer.util.AnnovarGeneIdParser;
import edu.usc.ksom.pphs.add_panther_enhancer.util.ConfigFile;
```

Then, in the **outer** `Snp` class body, immediately after the existing line
`public static final String COLS_TO_BE_ADDED[] = getColsToBeAdded();`, add:

```java
    // Resolved once at class load, not per SNP: Snp is constructed for every VCF line.
    private static final boolean GENE_NAME_FALLBACK_ENABLED = isGeneNameFallbackEnabled();

    private static boolean isGeneNameFallbackEnabled() {
        String build = ConfigFile.getProperty(Constants.PROPERTY_GENOME_BUILD);
        return null != build && Constants.GENOME_BUILD_HG38.equalsIgnoreCase(build.trim());
    }
```

`ConfigFile.getProperty` returns `null` and prints a "Key ... doesn't exist" warning when the property is absent, so an old properties file degrades to the previous behavior rather than failing.

- [ ] **Step 4: Add the resolution method**

In `Snp.java`, inside the inner class `LoadToolAnnotations`, add this method directly after `convertEnsemblGeneIdStrToSet` (which must remain unchanged):

```java
        /**
         * Resolves an ANNOVAR_ensembl_Gene_ID cell to a set of Ensembl gene ids.
         *
         * WGSA hg38 (TOPMed) output mixes Ensembl gene ids and HGNC gene symbols in this column.
         * Ensembl gene ids are used directly; any other token is looked up as an HGNC gene symbol.
         * Tokens are never split on '-' - see AnnovarGeneIdParser.
         *
         * When the input is not hg38 this delegates to the original parsing, unchanged.
         */
        Set<String> resolveAnnovarEnsemblGeneIdToEnsemblIdSet(String annovarEnsemblGeneIdStr) {
            if (false == GENE_NAME_FALLBACK_ENABLED) {
                return convertEnsemblGeneIdStrToSet(annovarEnsemblGeneIdStr);
            }
            Set<String> ensemblIdSet =
                    AnnovarGeneIdParser.extractEnsemblGeneIds(annovarEnsemblGeneIdStr);
            Set<String> symbolCandidates =
                    AnnovarGeneIdParser.extractGeneSymbolCandidates(annovarEnsemblGeneIdStr);
            if (symbolCandidates.isEmpty()) {
                return ensemblIdSet;
            }
            IdMappingManager im = IdMappingManager.getInstance(Snp.this.workingDir);
            for (String symbol : symbolCandidates) {
                ArrayList<String> mappedEnsemblIds = im.getEnsemblIdsForSymbol(symbol);
                if (null == mappedEnsemblIds) {
                    continue;
                }
                for (String ensemblId : mappedEnsemblIds) {
                    // HGNC rows with a blank ensembl_gene_id contribute an empty string
                    if (false == ensemblId.isEmpty()) {
                        ensemblIdSet.add(ensemblId);
                    }
                }
            }
            return ensemblIdSet;
        }
```

- [ ] **Step 5: Change the single call site**

In `LoadToolAnnotations.run()`, the ANNOVAR Ensembl block currently reads:

```java
            Set<String> ensemblGeneIdSet = convertEnsemblGeneIdStrToSet(AnnovarEnsemblGeneId);
```

Change that one line to:

```java
            Set<String> ensemblGeneIdSet = resolveAnnovarEnsemblGeneIdToEnsemblIdSet(AnnovarEnsemblGeneId);
```

This is the **only** call-site change. The later `convertEnsemblGeneIdStrToSet(SnpEffEnsemblGeneId)` and `convertEnsemblGeneIdStrToSet(VepEnsemblGeneId)` calls must remain exactly as they are.

- [ ] **Step 6: Verify it compiles and the unit tests still pass**

```bash
cd java_wgsa_add/add_panther_enhancer
mvn -q clean package
```

Expected: build succeeds, `Tests run: 13, Failures: 0, Errors: 0`.

- [ ] **Step 7: Verify the hg19 path is unchanged**

Temporarily set the property to hg19 and confirm output still matches the Task 2 baseline:

```bash
sed -i 's/^genome.build=hg38$/genome.build=hg19/' src/main/resources/add_panther_enhancer.properties
mvn -q clean package -DskipTests
mvn -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
H=/tmp/ab_hg19
rm -rf $H && mkdir -p $H/in $H/out $H/work
cp /home/muruganu/projects/temp/top_med/data/topmed/chr18.vcf $H/in/
java -cp target/classes:$(cat target/cp.txt) \
     edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF $H/in $H/out $H/work
diff -q /tmp/ab_baseline/out/chr18.vcf $H/out/chr18.vcf && echo "IDENTICAL - hg19 path unaffected"
sed -i 's/^genome.build=hg19$/genome.build=hg38/' src/main/resources/add_panther_enhancer.properties
```

Expected: `IDENTICAL - hg19 path unaffected`, and the property restored to `hg38`.

- [ ] **Step 8: Local commit (do NOT push)**

Stage the properties file **only after** reverting its `C:/` paths:

```bash
cd /home/muruganu/projects/temp/top_med/annoq-data-builder
sed -i 's#/mnt/c/projects/annoq_data_builder_add_panther_enhancer#C:/projects/annoq_data_builder_add_panther_enhancer#g' \
    java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
git diff --stat java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
```

Expected diff: **only** the added `genome.build` block — no path changes. Then:

```bash
git add java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties \
        java_wgsa_add/add_panther_enhancer/src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/constants/Constants.java \
        java_wgsa_add/add_panther_enhancer/src/main/java/edu/usc/ksom/pphs/add_panther_enhancer/datamodel/Snp.java
git commit -m "Resolve gene symbols in ANNOVAR_ensembl_Gene_ID for hg38 for #78

WGSA hg38/TOPMed output mixes Ensembl gene ids and HGNC gene symbols in this
column; symbol tokens previously missed ensemblToUniprotLookup and were dropped,
losing PANTHER/GO/Reactome annotations.  Gated on new genome.build=hg38 property.
Output columns unchanged."
```

Re-apply the `/mnt/c` paths afterwards if continuing to Task 4 locally.

---

### Task 4: Validate on real hg38 data and document

**Files:**
- Modify: `README.md` (repo root, Part 3 section)

**Interfaces:**
- Consumes: the built jar from Task 3 and the Task 2 baseline at `/tmp/ab_baseline/out/chr18.vcf`.
- Produces: no code API.

- [ ] **Step 1: Run with the fallback enabled**

With `genome.build=hg38` and the `/mnt/c` paths in place:

```bash
cd /home/muruganu/projects/temp/top_med/annoq-data-builder/java_wgsa_add/add_panther_enhancer
mvn -q clean package -DskipTests
mvn -q dependency:build-classpath -Dmdep.outputFile=target/cp.txt
F=/tmp/ab_hg38
rm -rf $F && mkdir -p $F/in $F/out $F/work
cp /home/muruganu/projects/temp/top_med/data/topmed/chr18.vcf $F/in/
java -cp target/classes:$(cat target/cp.txt) \
     edu.usc.ksom.pphs.add_panther_enhancer.main.ProcessVCF $F/in $F/out $F/work
```

- [ ] **Step 2: Confirm the column count did not change**

```bash
head -1 /tmp/ab_baseline/out/chr18.vcf | awk -F'\t' '{print "baseline: "NF}'
head -1 $F/out/chr18.vcf              | awk -F'\t' '{print "hg38    : "NF}'
```

Expected: both `830`. If they differ, an output column was added — stop and fix.

- [ ] **Step 3: Confirm only the expected columns changed**

```bash
head -1 /tmp/ab_baseline/out/chr18.vcf | tr '\t' '\n' > /tmp/hdr.txt
awk -F'\t' 'NR==FNR{for(i=1;i<=NF;i++)a[FNR,i]=$i; if(FNR==1)nf=NF; next}
{for(i=1;i<=nf;i++) if(a[FNR,i]!=$i) diff[i]++}
END{ while((getline h < "/tmp/hdr.txt")>0) hdr[++j]=h
     print "columns whose values changed:"
     for(i=1;i<=nf;i++) if(diff[i]) printf "  col %-4d %-45s %d rows\n", i, hdr[i], diff[i] }' \
  /tmp/ab_baseline/out/chr18.vcf $F/out/chr18.vcf
```

This holds the whole baseline file in an awk array — fine for this 4,999-row fixture, but do not
reuse it unmodified on a full-chromosome file.

Expected: every listed column is either `Uniprot_mapped_to_ANNOVAR_ensembl_Gene_ID` or one of the nine `ANNOVAR_ensembl_*_list_id` PANTHER columns. **Any other column appearing here is a bug** — in particular no `SnpEff_*`, `VEP_*`, `flanking_*`, or `enhancer_*` column may change.

- [ ] **Step 4: Confirm annotations were actually gained**

`18:43621` has cell `TUBB8B` — symbol only, so it got nothing before:

```bash
C=$(head -1 $F/out/chr18.vcf | tr '\t' '\n' | grep -n -x "Uniprot_mapped_to_ANNOVAR_ensembl_Gene_ID" | cut -d: -f1)
echo "Uniprot_mapped_to_ANNOVAR_ensembl_Gene_ID is column $C"
echo "baseline:"; awk -F'\t' -v c=$C 'NR>1 && $2==43621 {print "  ["$c"]"; exit}' /tmp/ab_baseline/out/chr18.vcf
echo "hg38:";     awk -F'\t' -v c=$C 'NR>1 && $2==43621 {print "  ["$c"]"; exit}' $F/out/chr18.vcf
```

Expected: baseline empty, hg38 populated with UniProt accession(s).

Then count how many rows gained a value in that column:

```bash
awk -F'\t' -v c=$C 'NR==FNR{if(FNR>1) b[FNR]=$c; next} FNR>1 && b[FNR]=="" && $c!="" {n++} END{print n+0" rows newly populated"}' \
  /tmp/ab_baseline/out/chr18.vcf $F/out/chr18.vcf
```

Expected: a non-zero count. `data/topmed/chr18.vcf` has 534 symbol-only rows and 2,502 mixed rows; the symbol-only rows are the ones that can newly populate, bounded by whether `LINC02564`/`TUBB8B` reach UniProt.

- [ ] **Step 5: Note the fixture's coverage limit**

`data/topmed/chr18.vcf` spans only chr18:10,005–45,335 and contains just two distinct gene-name tokens (`LINC02564`, `TUBB8B`), **neither hyphenated**. Hyphen behavior is therefore covered by Task 1's unit tests, not by this run.

For end-to-end hyphen confirmation, an hg38 chr6 slice is needed (`run_3/input/chr6.vcf.gz` on CARC, `/project2/huaiyumi_1334/AnnoQ/rel/data_annoq_release_2.0_beta_1/20241016_add_panther_enhancer`). The checks there: `6:29936267` (`HLA-A`) should gain annotations, and `6:6341470` (`LY86-AS1`) should stay empty — the latter proving hyphens were not split. Record whichever of these was or was not run; do not claim hyphen validation from the chr18 fixture.

- [ ] **Step 6: Revert the local-only path edits**

```bash
cd /home/muruganu/projects/temp/top_med/annoq-data-builder
sed -i 's#/mnt/c/projects/annoq_data_builder_add_panther_enhancer#C:/projects/annoq_data_builder_add_panther_enhancer#g' \
    java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
git diff java_wgsa_add/add_panther_enhancer/src/main/resources/add_panther_enhancer.properties
```

Expected: no diff (Task 3 already committed the `genome.build` block, and the paths are back to `C:/`).

- [ ] **Step 7: Document in the README**

In `README.md`, in the `## Part 3: AnnoQ Adding PANTHER, GO, Reactome and ENHANCER annotations` section, after the existing numbered list (which ends with the `copy panther_annot.json ...` item), add:

```markdown
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
```

- [ ] **Step 8: Local commit (do NOT push)**

```bash
git add README.md
git commit -m "Document genome.build property for Part 3 for #78"
```

---

## Post-implementation

Remaining pipeline work, outside this plan (tracked in the spec, section 7):

1. Re-run Part 3 on the hg38/TOPMed HRC-merged VCF with `genome.build=hg38`. HRC/hg19 needs no re-run.
2. Regenerate JSON → load into Elasticsearch → verify counts.
3. Rebuild the hg38 index, since annotation values changed.

No `annotation_tree.csv`, `annoq_mappings.json`, API, or site changes are required — the column set is unchanged.
