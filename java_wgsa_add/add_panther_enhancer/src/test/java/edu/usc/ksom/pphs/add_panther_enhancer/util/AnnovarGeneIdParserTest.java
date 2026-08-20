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
