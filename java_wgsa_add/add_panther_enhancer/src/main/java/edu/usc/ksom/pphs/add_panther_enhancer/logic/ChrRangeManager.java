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
package edu.usc.ksom.pphs.add_panther_enhancer.logic;

import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import edu.usc.ksom.pphs.add_panther_enhancer.util.ConfigFile;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import htsjdk.samtools.util.IntervalTree;
//import htsjdk.samtools.
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;


public class ChrRangeManager {
    public static final String FILE_PEP_FASTA = ConfigFile.getProperty("file.pep.fasta");    
    public static final String FILE_ENHANCER_CHR_RANGE = ConfigFile.getProperty("file.enhancer.chr.range.enhancer");
    
    public static final String ENCODING = "UTF-8";
    public static final String PREFIX_FASTA = ">";
    public static final String DELIM_WHITESPACE = "\\s+";
    public static final String DELIM_COORDINATES = ":";
    public static final String DELIM_GENE = ":";    
    public static final String DOT = ".";
    
    public static final String ENHANCER_DELIM = "\t";
    public static final String CHR_PREFIX = "chr";
        
    
    // If the ids being inserted into the Interval tree are not unique, the system will overwrite the previous value.
    // Therefore, generate unique identifiers when adding intervals
    private static HashMap<String, HashMap<Integer, IntervalTree>> pepChrToFlankingToIntervalTreeLookup;
    private static HashMap<String, String> ensemblKeyEnsemblIdLookup;
    
    private static HashMap<String, IntervalTree> chrToEnhancerTree;
    private static HashMap<String, String> enhancerKeyToIdLookup;
    
    
    private static ChrRangeManager instance;
    
    private ChrRangeManager() {
    }

    public static synchronized ChrRangeManager getInstance() {
        if (null != instance) {
            return instance;
        }
        try {
            if (false == initPepInfo()) {
                System.out.println("Unable to load PEP Interval tree");
                System.exit(-1);
                return null;
            }
            if (false == initEnhancerInfo()) {
                System.out.println("Unable to load Enhancer Interval tree");
                System.exit(-1);
                return null;
            }            
            
        } catch (IOException e) {
            System.out.println("Unable to load chromosome interval tree information Exception " + e.getMessage());
            System.exit(-1);
            return null;
        }
        instance = new ChrRangeManager();
        return instance;
    }
    
    private static boolean initPepInfo() throws IOException {
        Path filePath = Paths.get(FILE_PEP_FASTA);
        List<String> fastaList = Files.readAllLines(filePath, Charset.forName(ENCODING));
        HashMap<String, HashMap<Integer, IntervalTree>> chrToFlankingRegion = new HashMap<String, HashMap<Integer, IntervalTree>>();
        int counter = 0;
        HashMap<String, String> ensembleLookup = new HashMap<String, String>();
        for (String line: fastaList) {
            if (false == line.startsWith(PREFIX_FASTA)) {
                continue;
            }
            String parts[] = line.split(DELIM_WHITESPACE);
            if (3 > parts.length) {
                continue;
            }
            String coordinates = parts[2];
            String coord_parts[] = coordinates.split(DELIM_COORDINATES);
            if (6 > coord_parts.length) {
                continue;
            }
            String chrNum = coord_parts[2];
//            String direction = coord_parts[5];
            int start;
            int end;

            try {
                start = Integer.parseInt(coord_parts[3]);
                end = Integer.parseInt(coord_parts[4]);
                //dir = Integer.parseInt(direction);
            }
            catch(NumberFormatException e) {
                e.printStackTrace();
                continue;
            }
            
            String geneId = parts[3];
            String ensembleParts[] = geneId.split(DELIM_GENE);
            if (2 != ensembleParts.length) {
                continue;
            }
            String ensembleGeneId = ensembleParts[1];
            int index = ensembleGeneId.lastIndexOf(DOT);
            if (index > 0) {
                ensembleGeneId = ensembleGeneId.substring(0, index);
            }
            String ensembleKey = counter + "-" + ensembleGeneId;
            for (int flankingRegion : Constants.FLANKING_REGIONS) {
                HashMap<Integer, IntervalTree> flankingLookup = chrToFlankingRegion.get(chrNum);
                if (null == flankingLookup) {
                    flankingLookup = new HashMap<Integer, IntervalTree>();
                    chrToFlankingRegion.put(chrNum, flankingLookup);
                }
                IntervalTree it = flankingLookup.get(flankingRegion);
                if (null == it) {
                    it = new IntervalTree();
                    flankingLookup.put(flankingRegion, it);
                }
                ensembleLookup.put(ensembleKey, ensembleGeneId);
                int low = Math.max(0, start - flankingRegion);
                int high = end + flankingRegion;
                IntervalTree.Node  existing = it.find(low, high);
                if (null != existing) {
                    HashSet<String> existingValSet = (HashSet<String>)existing.getValue();
                    System.out.println("Chromosome " + chrNum  + " adding to previous " + String.join(",", new ArrayList<String>(existingValSet)) + " key position information in flanking region " + flankingRegion + " with  " + ensembleKey);
                    existingValSet.add(ensembleKey);
                    it.put(low, high, existingValSet);                    
                }    
                else {
                    HashSet<String> ensembleSet =  new HashSet<String>();
                    ensembleSet.add(ensembleKey);
                    it.put(low, high, ensembleSet);
                }
//                
//                Object previous = (String) it.put(Math.max(0, start - flankingRegion), end + flankingRegion, ensembleKey);
//                if (null != previous) {
//                }
            }
            counter++;
//            
//        coordinates = header_bits[2]
//        field_name, build_name, chr_num, start, end, strand = coordinates.split(":", maxsplit=5)
//        gene_id = header_bits[3]
//        field_name, ensembl_id = gene_id.split(":", maxsplit=1)
//        ensembl_id = ensembl_id.split(".", maxsplit=1)[0]
//        return cls(ensembl_id, chr_num, int(start), int(end))       
            
            
            
        }
        
        
        
//        for (String chr: intervalTreeLookup.keySet()) {
//            System.out.println("Printing interval tree for chromosome " + chr + "\n");
//            HashMap<Integer, IntervalTree> dirTree = intervalTreeLookup.get(chr);
//            for (Integer flankingRegion: dirTree.keySet()) {
//                System.out.println("Printing tree for flanking region " + flankingRegion + "\n");
//                dirTree.get(flankingRegion).printTree();
//            }
//        }
        
        pepChrToFlankingToIntervalTreeLookup = chrToFlankingRegion;
        ensemblKeyEnsemblIdLookup = ensembleLookup;
        return true;
    }
    
    private static boolean initEnhancerInfo() throws IOException {
        Path filePath = Paths.get(FILE_ENHANCER_CHR_RANGE);
        List<String> enhancerLines = Files.readAllLines(filePath, Charset.forName(ENCODING));
        HashMap<String, IntervalTree> intervalTreeLookup = new HashMap<String, IntervalTree>();
        HashMap<String, String> enhancerIdLookup = new HashMap<String, String>();
        int counter = 0;
        for (String line: enhancerLines) {
            String parts[] = line.split(ENHANCER_DELIM);
            if (4 > parts.length) {
                continue;
            }
            String chr = parts[0];
            if (chr.toLowerCase().startsWith(CHR_PREFIX)) {
                chr = chr.substring(CHR_PREFIX.length());
            }
            int start;
            int end;
            try {
                start = Integer.parseInt(parts[1]);
                end = Integer.parseInt(parts[2]);
            }
            catch(NumberFormatException e) {
                continue;
            }
            
            IntervalTree it = intervalTreeLookup.get(chr);
            if (null == it) {
                it = new IntervalTree();
                intervalTreeLookup.put(chr, it);
            }
            String enhancerIdKey = counter + "-" + parts[3];

            enhancerIdLookup.put(enhancerIdKey, parts[3]);
            IntervalTree.Node existing = it.find(start, end);
            if (null != existing) {
                HashSet<String> existingValSet = (HashSet<String>)existing.getValue();
                System.out.println("Enhancer adding to previous " + String.join(",", new ArrayList<String>(existingValSet)) + " for range " + start + " to end " + end + " for  " + enhancerIdKey);
                existingValSet.add(enhancerIdKey);
                it.put(start, end, existingValSet);
            }
            else {
                HashSet<String> enhancerSet = new HashSet<String>();
                enhancerSet.add(enhancerIdKey);
                it.put(start, end, enhancerSet);
            }
//            String previous = (String)it.put(start, end,enhancerIdKey);
//            if (null != previous) {
//                System.out.println("Overwriting previous " + previous + " enhancer information with enhancer information for " + enhancerIdKey);
//            }
        }
//        for (String chr: intervalTreeLookup.keySet()) {
//            System.out.println("Processing Enhancer interval tree for chromosome " + chr);
//            intervalTreeLookup.get(chr).printTree();
//        }
        chrToEnhancerTree = intervalTreeLookup;
        enhancerKeyToIdLookup = enhancerIdLookup;
        return true;
    }
    
    public HashSet<String> getPepMappings(String chromosome, int pos, int flankingRegion) {
        if (null == chromosome) {
            return null;
        }
        HashMap<Integer, IntervalTree> flankingLookup = pepChrToFlankingToIntervalTreeLookup.get(chromosome);
        if (null == flankingLookup) {
            System.out.println("No flanking tree defined for chromosome " + chromosome);
            return null;
        }
        IntervalTree it = flankingLookup.get(flankingRegion);
        if (null == it) {
            System.out.println("No tree defined for flanking region " + flankingRegion);
        }
        Iterator<IntervalTree.Node<HashSet<String>>> overlappers = it.overlappers(pos, pos);
        if (null == overlappers) {
            return null;
        }
        HashSet<String> matches = new HashSet<String>();
        while (overlappers.hasNext()) {
            IntervalTree.Node<HashSet<String>> item = overlappers.next();
            HashSet<String> keySet = (HashSet<String>) item.getValue();
            for (String ensembleKey : keySet) {
                matches.add(ensemblKeyEnsemblIdLookup.get(ensembleKey));
            }
        }
        return matches;
    }
    
    public ArrayList<String> getEnhancerMapping(String chromosome, int pos) {
        IntervalTree it = chrToEnhancerTree.get(chromosome);
        if (null == it) {
            System.out.println("No tree defined for chromosome " + chromosome);
        }
        Iterator<IntervalTree.Node<HashSet<String>>> overlappers = it.overlappers(pos, pos);
        if (null == overlappers) {
            return null;
        }
        ArrayList<String> matches = new ArrayList<String>();
        while (overlappers.hasNext()) {
            IntervalTree.Node<HashSet<String>> item = overlappers.next();
            HashSet<String> keySet = (HashSet<String>) item.getValue();
            for (String enhancerKey : keySet) {
                matches.add(enhancerKeyToIdLookup.get(enhancerKey));
            }
        }

        return matches;
    }
    
    public static void main (String args[]) {
        ChrRangeManager crm = ChrRangeManager.getInstance();
    }    
}
