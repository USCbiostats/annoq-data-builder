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
