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
package edu.usc.ksom.pphs.add_panther_enhancer.main;

import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.ChrRangeManager;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.EnhancerAnnotator;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.IdMappingManager;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Incremental PEREGRINE update.
 *
 * Reads already-annotated tab-delimited files (the output VCFs of ProcessVCF, or the slim
 * TSVs produced by annoq-database/src/extract_enhancer_tsv.py), recomputes ONLY the 12
 * PEREGRINE enhancer-derived columns with the currently configured enhancer files
 * (file.enhancer.chr.range.enhancer / file.enhancer.panther / file.panther.annot), and writes
 * just the rows whose values changed. All other columns are untouched by design.
 *
 * Values are compared as sets of ';'-separated items, because the pipeline joins HashSets
 * and item order is not stable between runs.
 *
 * Outputs, per input file NAME:
 *   NAME.delta.tsv   chr pos ref alt + 12 enhancer columns (new values) + peregrine_change
 *   NAME.lost.tsv    rows where a previously present item is no longer present (should be empty
 *                    for an additions-only PEREGRINE update)
 * and summary.tsv with one line of counts per input file.
 *
 * Usage: ComputeEnhancerDelta inputDir outputDir workingDir [numThreads]
 * Files are processed one at a time unless numThreads (> 1) is given.
 */
public class ComputeEnhancerDelta {

    public static final String COL_REF = "ref";
    public static final String COL_ALT = "alt";
    public static final String COL_CHANGE = "peregrine_change";
    public static final String SUFFIX_DELTA = ".delta.tsv";
    public static final String SUFFIX_LOST = ".lost.tsv";
    public static final String FILE_SUMMARY = "summary.tsv";

    public static final String CHANGE_GAINED = "GAINED";    // no linked genes before, has now
    public static final String CHANGE_CHANGED = "CHANGED";  // linked genes before and values differ
    public static final String CHANGE_CLEARED = "CLEARED";  // had values, now none

    /** The 12 enhancer columns, in the same order ProcessVCF appends them. */
    public static final String[] ENHANCER_COLS = buildEnhancerCols();

    private static String[] buildEnhancerCols() {
        ArrayList<String> cols = new ArrayList<String>();
        for (String id : Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID) {
            cols.add(Constants.PREFIX_LABEL_PEREGRINE_ENHANCER_LINKED + id);
        }
        cols.add(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_ASSAY);
        cols.add(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_GENES);
        cols.add(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_ENHANCER);
        return cols.toArray(new String[0]);
    }

    private static final int IDX_GENES = ENHANCER_COLS.length - 2;

    private final String outputDir;
    private final String workingDir;

    public ComputeEnhancerDelta(String outputDir, String workingDir) {
        this.outputDir = outputDir;
        this.workingDir = workingDir;
        // Load lookups once, before any worker threads start
        ChrRangeManager.getInstance();
        IdMappingManager.getInstance(workingDir);
    }

    static class Stats {
        String file;
        long rows, unchanged, gained, changed, cleared, rowsWithLostItems, skipped;
        long[] fieldChanged = new long[ENHANCER_COLS.length];
        String error;
    }

    static HashSet<String> toSet(String value) {
        HashSet<String> set = new HashSet<String>();
        if (null == value || value.isEmpty()) {
            return set;
        }
        // limit -1 keeps empty items, e.g. an empty assay in "3;" is part of the value
        set.addAll(Arrays.asList(value.split(EnhancerAnnotator.DELIM, -1)));
        return set;
    }

    private static int indexOf(String[] header, String... names) {
        for (int i = 0; i < header.length; i++) {
            for (String n : names) {
                if (n.equalsIgnoreCase(header[i].trim())) {
                    return i;
                }
            }
        }
        return -1;
    }

    Stats processFile(Path input) {
        Stats st = new Stats();
        String name = input.getFileName().toString();
        st.file = name;
        Path deltaPath = Paths.get(outputDir, name + SUFFIX_DELTA);
        Path lostPath = Paths.get(outputDir, name + SUFFIX_LOST);
        try (BufferedReader in = Files.newBufferedReader(input, StandardCharsets.UTF_8);
             BufferedWriter delta = Files.newBufferedWriter(deltaPath, StandardCharsets.UTF_8);
             BufferedWriter lost = Files.newBufferedWriter(lostPath, StandardCharsets.UTF_8)) {

            String headerLine = in.readLine();
            if (null == headerLine) {
                st.error = "empty file";
                return st;
            }
            String[] header = headerLine.split(Constants.DELIM_VCF, -1);
            int iChr = indexOf(header, "chr", "chrom");
            int iPos = indexOf(header, "pos");
            int iRef = indexOf(header, COL_REF);
            int iAlt = indexOf(header, COL_ALT);
            if (iChr < 0 || iPos < 0 || iRef < 0 || iAlt < 0) {
                st.error = "header must contain chr, pos, ref and alt columns";
                return st;
            }
            int[] iEnh = new int[ENHANCER_COLS.length];
            for (int f = 0; f < ENHANCER_COLS.length; f++) {
                iEnh[f] = indexOf(header, ENHANCER_COLS[f]);   // -1 => treated as empty
            }

            delta.write("chr\tpos\tref\talt\t" + String.join("\t", ENHANCER_COLS) + "\t" + COL_CHANGE + "\n");
            lost.write("chr\tpos\tref\talt\tfield\tmissing_items\n");

            String line;
            while ((line = in.readLine()) != null) {
                if (line.isEmpty()) {
                    continue;
                }
                String[] p = line.split(Constants.DELIM_VCF, -1);
                int pos;
                try {
                    pos = Integer.parseInt(p[iPos].trim());
                } catch (RuntimeException e) {
                    st.skipped++;
                    continue;
                }
                st.rows++;
                String chr = p[iChr].trim();
                EnhancerAnnotator.Result r = EnhancerAnnotator.annotate(chr, pos, workingDir);
                String[] newVals = new String[ENHANCER_COLS.length];
                for (int f = 0; f < Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length; f++) {
                    newVals[f] = (null == r.pantherAnnots) ? "" : r.pantherAnnots.get(f);
                }
                newVals[ENHANCER_COLS.length - 3] = r.assays;
                newVals[ENHANCER_COLS.length - 2] = r.genes;
                newVals[ENHANCER_COLS.length - 1] = r.enhancerList;

                boolean differs = false;
                boolean oldAny = false;
                boolean newAny = false;
                boolean lostAny = false;
                String key = p[iChr] + "\t" + p[iPos] + "\t" + p[iRef] + "\t" + p[iAlt];
                for (int f = 0; f < ENHANCER_COLS.length; f++) {
                    String oldVal = (iEnh[f] >= 0 && iEnh[f] < p.length) ? p[iEnh[f]] : "";
                    HashSet<String> oldSet = toSet(oldVal);
                    HashSet<String> newSet = toSet(newVals[f]);
                    oldAny |= !oldSet.isEmpty();
                    newAny |= !newSet.isEmpty();
                    if (!oldSet.equals(newSet)) {
                        differs = true;
                        st.fieldChanged[f]++;
                        TreeSet<String> missing = new TreeSet<String>(oldSet);
                        missing.removeAll(newSet);
                        if (!missing.isEmpty()) {
                            lostAny = true;
                            lost.write(key + "\t" + ENHANCER_COLS[f] + "\t" + String.join(EnhancerAnnotator.DELIM, missing) + "\n");
                        }
                    }
                }
                if (lostAny) {
                    st.rowsWithLostItems++;
                }
                if (!differs) {
                    st.unchanged++;
                    continue;
                }
                String change;
                if (!newAny) {
                    change = CHANGE_CLEARED;
                    st.cleared++;
                } else if (toSet(iEnh[IDX_GENES] >= 0 && iEnh[IDX_GENES] < p.length ? p[iEnh[IDX_GENES]] : "").isEmpty()) {
                    change = CHANGE_GAINED;
                    st.gained++;
                } else {
                    change = CHANGE_CHANGED;
                    st.changed++;
                }
                delta.write(key + "\t" + String.join("\t", newVals) + "\t" + change + "\n");
            }
        } catch (IOException e) {
            st.error = e.getMessage();
        }
        System.out.println("Finished " + name + ": rows=" + st.rows + " changed rows=" + (st.gained + st.changed + st.cleared)
                + " rows with lost items=" + st.rowsWithLostItems + (st.error != null ? " ERROR " + st.error : ""));
        return st;
    }

    public List<Stats> run(String inputDir, int numThreads) throws Exception {
        List<Path> inputs;
        try (Stream<Path> s = Files.list(Paths.get(inputDir))) {
            inputs = s.filter(Files::isRegularFile)
                      .filter(x -> x.toString().endsWith(".vcf") || x.toString().endsWith(".tsv"))
                      .sorted()
                      .collect(Collectors.toList());
        }
        Files.createDirectories(Paths.get(outputDir));
        List<Stats> results = new ArrayList<Stats>();
        if (numThreads <= 1) {
            for (int i = 0; i < inputs.size(); i++) {
                System.out.println("Processing file " + (i + 1) + " of " + inputs.size() + " " + inputs.get(i).getFileName());
                results.add(processFile(inputs.get(i)));
            }
        } else {
            ExecutorService ex = Executors.newFixedThreadPool(numThreads);
            List<Future<Stats>> futures = new ArrayList<Future<Stats>>();
            for (Path in : inputs) {
                futures.add(ex.submit(() -> processFile(in)));
            }
            for (Future<Stats> f : futures) {
                results.add(f.get());
            }
            ex.shutdown();
        }
        writeSummary(results);
        return results;
    }

    private void writeSummary(List<Stats> results) throws IOException {
        Collections.sort(results, (a, b) -> a.file.compareTo(b.file));
        try (BufferedWriter w = Files.newBufferedWriter(Paths.get(outputDir, FILE_SUMMARY), StandardCharsets.UTF_8)) {
            StringBuilder h = new StringBuilder("file\trows\tunchanged\tgained\tchanged\tcleared\trows_with_lost_items\tskipped_lines\terror");
            for (String c : ENHANCER_COLS) {
                h.append("\tchanged_").append(c);
            }
            w.write(h.append("\n").toString());
            for (Stats s : results) {
                StringBuilder b = new StringBuilder();
                b.append(s.file).append('\t').append(s.rows).append('\t').append(s.unchanged).append('\t')
                 .append(s.gained).append('\t').append(s.changed).append('\t').append(s.cleared).append('\t')
                 .append(s.rowsWithLostItems).append('\t').append(s.skipped).append('\t')
                 .append(null == s.error ? "" : s.error);
                for (long n : s.fieldChanged) {
                    b.append('\t').append(n);
                }
                w.write(b.append("\n").toString());
            }
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 3) {
            System.out.println("Usage: ComputeEnhancerDelta inputDir outputDir workingDir [numThreads]");
            System.out.println("  Recomputes only the PEREGRINE enhancer columns of already-annotated files and writes changed rows.");
            System.out.println("  Files are processed one at a time unless numThreads > 1 is given.");
            return;
        }
        int threads = args.length > 3 ? Integer.parseInt(args[3]) : 1;
        Files.createDirectories(Paths.get(args[2]));
        List<Stats> results = new ComputeEnhancerDelta(args[1], args[2]).run(args[0], threads);
        boolean failed = results.stream().anyMatch(s -> s.error != null);
        System.out.println("Summary written to " + Paths.get(args[1], FILE_SUMMARY));
        if (failed) {
            System.exit(1);
        }
    }
}
