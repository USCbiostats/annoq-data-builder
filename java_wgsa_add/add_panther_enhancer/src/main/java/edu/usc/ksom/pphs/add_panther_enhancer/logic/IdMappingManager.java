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
import edu.usc.ksom.pphs.add_panther_enhancer.util.IOUtils;
import edu.usc.ksom.pphs.add_panther_enhancer.util.Utils;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonValue;


public class IdMappingManager {
    public static final String FILE_PANTHER_ANNOT = ConfigFile.getProperty("file.panther.annot");    
    public static final String FILE_ID_MAPPING = ConfigFile.getProperty("file.id.mapping");
    public static final String FILE_HGNC_COMPLETE = ConfigFile.getProperty("file.hgnc.complete");
    public static final String FILE_ENHANCER_TO_PANTHER = ConfigFile.getProperty("file.enhancer.panther");
    
    public static final String FILE_LOOKUP_SEPARATOR = "\t";
    public static final String LOOKUP_VALUE_SEPARATOR = "|";
    public static final String FILE_SEPARATOR = "/";
    public static final String FILE_ENSEMBL_TO_UNIPROT = ResourceManager.PATH_WORKING + FILE_SEPARATOR + "ensembl_to_uniprot_lookup.txt";
    public static final String FILE_SYMBOL_TO_ENSEMBL = ResourceManager.PATH_WORKING + FILE_SEPARATOR + "symbol_to_ensembl_lookup.txt";   
    public static final String FILE_ENTREZ_TO_ENSEMBL = ResourceManager.PATH_WORKING + FILE_SEPARATOR + "entrez_to_ensembl_lookup.txt";
    

  

    
    
    
    public static final String ENCODING = "UTF-8";
    public static final String DELIM_HGNC = "\t";
    public static final int COL_SYMBOL = 1;
    public static final int COL_ENTREZ_ID = 18;
    public static final int COL_ENSEMBL_ID = 19;
    
    public static final String DELIM_ENHANCER = "\t";    
    public static final int COL_ENHANCER = 0;
    public static final int COL_PANTHER = 1;
    public static final int COL_ASSAY = 3;
    
    private static IdMappingManager instance;
    
    // Note PANTHER annotation labels are ordered.  The ordering of value labels in pantherIdToAnnotLookup corresponds to ordering in pantherAnnotLabels
    private static List<String> pantherAnnotLabels;
    private static HashMap<String, ArrayList<String>> pantherIdToAnnotLookup;
    public static int numPantherAnnotLabels;
    
    private static HashMap<String, String> uniprotToPantherId;
    private static String JSON_FIELD_COLS = "cols";
    private static String JSON_FIELD_DATA = "data";
    
    private static final int NUM_PANTHER_ID_PARTS = 3;    
    private static final String DELIM_PANTHER_GENE_PART = "=";    
    private static final String DELIM_PANTHER_PROTEIN_PART = "="; 
    
    // Entrez to Ensembl mapping
    public static final String DELIM_ID_MAPPING = "\t";    
    private static HashMap<String, ArrayList<String>> entrezToEnsemblLookup;
    private static HashMap<String, ArrayList<String>> symbolToEnsemblLookup;    
    private static HashMap<String, ArrayList<String>> ensemblToUniprotLookup;
    
    private static HashMap<String, ArrayList<String>> geneNameToUniprotLookup;      // Data seems to be incomplete
    private static HashMap<String, ArrayList<String>> geneOrfNameToUniprotLookup;
    private static HashMap<String, ArrayList<String>> refSeqGeneIdToUniprotLookup;
    
//    private static HashMap<String, ArrayList<String>> uniprotToEnsemblLookup;
//    private static HashMap<String, ArrayList<String>> uniprotToGeneNameLookup;
//    private static HashMap<String, ArrayList<String>> uniprotToGeneOrfNameLookup;    
//    private static HashMap<String, ArrayList<String>> uniprotToRefSeqLookup;
    private static HashMap<String, ArrayList<String>> enhancerToPantherLookup; 
    private static HashMap<String, ArrayList<String>> enhancerToAssayListLookup;
    
    private static final String LABEL_ENSEMBL = "Ensembl";
    
    private static final String LABEL_GENE_NAME = "Gene_Name";
    private static final String LABEL_REF_SEQ = "RefSeq";
    //private static final String LABEL_ENSEMBL = 'HGNC'
    private static final String LABEL_GENE_ORF_NAME = "Gene_ORFName";
    private static final Set<String> MAPPED_TYPE_SET = new HashSet<String>(Arrays.asList(LABEL_ENSEMBL, LABEL_GENE_NAME, LABEL_REF_SEQ, LABEL_GENE_ORF_NAME));
    
    public static final String DOT = ".";
    

    private IdMappingManager() {
        
    }
    public static synchronized IdMappingManager getInstance(){
        if (null != instance) {
            return instance;
        }
        try {
            // Read PANTHER id mapping information
            JsonObject pantherJson = IOUtils.parseJSONFile(FILE_PANTHER_ANNOT);
            if (false == initPantherAnnotInfo(pantherJson)) {
                System.out.println("Unable to load PANTHER annotation information");
                System.exit(-1);
                return null;
            }

            if (false == initHgncIdMappingInfo()) {
                System.out.println("Unable to load HGNC mapping information");
                System.exit(-1);
                return null;            
            }

            if (false == initIdMappingInfo()) {
                System.out.println("Unable to load ID mapping information");
                System.exit(-1);
                return null;              
            }
            
            if (false == initEnhancerPantherInfo()) {
                System.out.println("Unable to load Enhancer to PANTHER mapping information");
                System.exit(-1);
                return null;            
            }            
        }
        catch(IOException e) {
            System.out.println("Unable to load ID mapping information Exception " + e.getMessage());
            System.exit(-1);
            return null;
        }
        
        instance = new IdMappingManager();
        return instance;
    }

    private static boolean initPantherAnnotInfo(JsonObject pantherJson) {
        if (null == pantherJson) {
            return false;
        }
        JsonValue.ValueType vt = pantherJson.getValueType();
        if (JsonValue.ValueType.OBJECT == vt) {
            JsonObject pantherObj = (JsonObject) pantherJson;
            JsonArray pantherColLabels = pantherObj.getJsonArray(JSON_FIELD_COLS);
            if (null == pantherColLabels) {
                return false;
            }
            if (null == pantherColLabels) {
                return false;
            }
            ArrayList<String> colList = new ArrayList<String>(pantherColLabels.size());
            ArrayList<Boolean> includeColData = new ArrayList<Boolean>();
            for (int i = 0; i < pantherColLabels.size(); i++) {
                String label = pantherColLabels.getString(i);
                if (Utils.getIndex(Constants.EXPECTED_PANTHER_ANNOT_LABELS, label) < 0) {
                    includeColData.add(Boolean.FALSE);
                }
                else {
                    includeColData.add(Boolean.TRUE);
                    colList.add(label);                    
                }
            }
            JsonObject annotListLookup = pantherObj.getJsonObject(JSON_FIELD_DATA);
            HashMap<String, String> uniprotIdLookup = new HashMap<String, String>();
            Set<String> idSet = annotListLookup.keySet();
            HashMap<String, ArrayList<String>> pantherIdLookup = new HashMap<String, ArrayList<String>>(idSet.size());
            for (String id: idSet) {
                JsonArray annotList = annotListLookup.getJsonArray(id);
                if (annotList == null ) {
                    System.out.println("Panther id" + id + " has no associated annotations");
                    return false;
                }
                if (annotList.size() != pantherColLabels.size()) {
                    System.out.println("Panther id " + id + " has " + annotList.size() + " annotations instead of " + pantherColLabels.size());
                    return false;
                }
                ArrayList<String> mappedAnnots = new ArrayList<String>(pantherColLabels.size());
                // Only include data, if it is going to be displayed
                for (int i = 0; i < annotList.size(); i++) {
                    if (false == includeColData.get(i)) {
                        continue;
                    }
                    mappedAnnots.add(annotList.getString(i));
                }
                pantherIdLookup.put(id, mappedAnnots);
                String[] pantherParts = id.split(Constants.DELIM_PANTHER_ID_PARTS);
                if (NUM_PANTHER_ID_PARTS == pantherParts.length) {
                    String proteinPart = pantherParts[2];
                    String[] proteinParts = proteinPart.split(DELIM_PANTHER_PROTEIN_PART);
                    if (2 == proteinParts.length) {
                        uniprotIdLookup.put(proteinParts[1], id);
                    }
                }
                
            }
            for (String expected: Constants.EXPECTED_PANTHER_ANNOT_LABELS) {
                if (colList.contains(expected)) {
                    continue;
                }
                else {
                    System.out.println("Panther annotation data columns does not have expected annotation label " + expected + ". Found " + String.join(",", colList));
                    return false;
                }
            }
            pantherAnnotLabels = colList;
            numPantherAnnotLabels = pantherAnnotLabels.size();            
            pantherIdToAnnotLookup = pantherIdLookup;
            uniprotToPantherId = uniprotIdLookup;
            
        }

        return true;
    }
    

    private static boolean initHgncIdMappingInfo() throws IOException {
        Path filePath = Paths.get(FILE_HGNC_COMPLETE);
        List<String> hgncList = Files.readAllLines(filePath, Charset.forName(ENCODING));
        HashMap<String, HashSet<String>> entrezToEnsembl = new HashMap<String, HashSet<String>>();
        HashMap<String, HashSet<String>> symbolToEnsembl = new HashMap<String, HashSet<String>>();        
        for (String hgncLine: hgncList) {
            String parts[] = hgncLine.split(DELIM_HGNC);
            if (parts.length <= COL_ENSEMBL_ID) {
                System.out.println("Skipping hgnc line " + hgncLine);
                continue;
            }
            if (0 == parts[COL_ENTREZ_ID].length()) {
                continue;
            }
            HashSet<String> ensemblSet = entrezToEnsembl.get(parts[COL_ENTREZ_ID]);
            if (null == ensemblSet) {
                ensemblSet = new HashSet<String>();
                entrezToEnsembl.put(parts[COL_ENTREZ_ID], ensemblSet);
            }
            ensemblSet.add(parts[COL_ENSEMBL_ID]);

            if (0 == parts[COL_SYMBOL].length()) {
                continue;
            }            
            ensemblSet = symbolToEnsembl.get(parts[COL_SYMBOL]);
            if (null == ensemblSet) {
                ensemblSet = new HashSet<String>();
                symbolToEnsembl.put(parts[COL_SYMBOL], ensemblSet);
            }
            ensemblSet.add(parts[COL_ENSEMBL_ID]);
        }

        entrezToEnsemblLookup = convertValueToArrayList(entrezToEnsembl);
        symbolToEnsemblLookup = convertValueToArrayList(symbolToEnsembl);
        outputLookupInfoHashMap(entrezToEnsemblLookup, FILE_ENTREZ_TO_ENSEMBL);
        outputLookupInfoHashMap(symbolToEnsemblLookup, FILE_SYMBOL_TO_ENSEMBL);        
        return true;
    }
    
    private static boolean initEnhancerPantherInfo() throws IOException {
        Path filePath = Paths.get(FILE_ENHANCER_TO_PANTHER);
        List<String> enhancerPantherList = Files.readAllLines(filePath, Charset.forName(ENCODING));
        HashMap<String, HashSet<String>> lookup = new HashMap<String, HashSet<String>>();
        HashMap<String, HashSet<String>> enhancerToAssay = new HashMap<String, HashSet<String>>();
        
        for (String enhancerPantherLine: enhancerPantherList) {
            String parts[] = enhancerPantherLine.split(DELIM_ENHANCER);
            if (parts.length <= COL_ASSAY) {
                System.out.println("Skipping enhancer to PANTHER line " + enhancerPantherLine);
                continue;
            }
            HashSet<String> pantherSet = lookup.get(parts[COL_ENHANCER]);
            if (null == pantherSet) {
                pantherSet = new HashSet<String>();
                lookup.put(parts[COL_ENHANCER], pantherSet);
            }
            pantherSet.add(parts[COL_PANTHER]);
            
            HashSet<String> assaySet  = enhancerToAssay.get(parts[COL_ENHANCER]);
            if (null == assaySet) {
                assaySet = new HashSet<String>();
                enhancerToAssay.put(parts[COL_ENHANCER], assaySet);
            }
            assaySet.add(parts[COL_ASSAY]);            
        }

        enhancerToPantherLookup = convertValueToArrayList(lookup);
        enhancerToAssayListLookup = convertValueToArrayList(enhancerToAssay);
        return true;
    } 
    
    private static HashMap<String, ArrayList<String>> convertValueToArrayList(HashMap<String, HashSet<String>> lookup) {
        if (null == lookup) {
            return null;
        }
        HashMap<String, ArrayList<String>>lookupCopy = new HashMap<String, ArrayList<String>>();
        for (String id:lookup.keySet()) {
            lookupCopy.put(id, new ArrayList(lookup.get(id)));
        }
        return lookupCopy;
    }
    
    private static boolean initIdMappingInfo()throws IOException {
        Path filePath = Paths.get(FILE_ID_MAPPING);
        List<String> idMappingList = Files.readAllLines(filePath, Charset.forName(ENCODING));
        HashMap<String, HashSet<String>> ensemblToUniprot = new HashMap<String, HashSet<String>>();
        HashMap<String, HashSet<String>> geneNameToUniprot = new HashMap<String, HashSet<String>>();
        HashMap<String, HashSet<String>> geneOrfNameToUniprot = new HashMap<String, HashSet<String>>();        
        HashMap<String, HashSet<String>> refSeqGeneIdToUniprot = new HashMap<String, HashSet<String>>();
//        HashMap<String, HashSet<String>> uniprotToRefSeq = new HashMap<String, HashSet<String>>();        
        for (String idMappingInfo: idMappingList) {
            String parts[] = idMappingInfo.split(DELIM_ID_MAPPING);
            if (3 != parts.length) {
                continue;
            }
            // Check if this is one of the types that is mapped
            String type = parts[1];
            if (false == MAPPED_TYPE_SET.contains(type)) {
                continue;
            }
            HashMap<String, HashSet<String>> lookup = null;
            String uniprotId = parts[0];

            String value = parts[2];
            if (type.equals(LABEL_ENSEMBL)) {
                lookup = ensemblToUniprot;
                int index = value.lastIndexOf(DOT);
                if (index > 0) {
                    value = value.substring(0, index);
                }

            }
            else if (type.equals(LABEL_GENE_NAME)) {
                lookup = geneNameToUniprot;
            }
            else if (type.equals(LABEL_GENE_ORF_NAME)) {
                lookup = geneOrfNameToUniprot;
                int index = value.lastIndexOf(DOT);                
                if (index > 0) {
                    value = value.substring(0, index);
                }                
            }
            else if (type.equals(LABEL_REF_SEQ)) {
                lookup = refSeqGeneIdToUniprot;
                int index = value.lastIndexOf(DOT);
                if (index > 0) {
                    value = value.substring(0, index);
                }                
            }
            else {
                System.out.println("Encountered unhandled type " + type);
                return false;
            }            
            HashSet<String> uniprotIdSet = lookup.get(value);
            if (null == uniprotIdSet) {
                uniprotIdSet = new HashSet<String>();
                lookup.put(value, uniprotIdSet);
            }
            uniprotIdSet.add(uniprotId);
        }
        ensemblToUniprotLookup = convertValueToArrayList(ensemblToUniprot);
        geneNameToUniprotLookup = convertValueToArrayList(geneNameToUniprot);
        geneOrfNameToUniprotLookup = convertValueToArrayList(geneOrfNameToUniprot);
        refSeqGeneIdToUniprotLookup =  convertValueToArrayList(refSeqGeneIdToUniprot);

        outputLookupInfoHashMap(ensemblToUniprotLookup, FILE_ENSEMBL_TO_UNIPROT);
        
        return true;
    }
    
    public ArrayList<String> getEnsemblIdsForEntrez(String entrezId) {
        if (null == entrezId || null == entrezToEnsemblLookup) {
            return null;
        }
        return entrezToEnsemblLookup.get(entrezId);
    }
    
    public ArrayList<String> getEnsemblIdsForSymbol(String symbol) {
        if (null == symbol || null == symbolToEnsemblLookup) {
            return null;
        }
        return symbolToEnsemblLookup.get(symbol);        
    }
    
    public ArrayList<String> getUniprotIdsForEnsembleId(String ensemblId) {
        if (null == ensemblId || null == ensemblToUniprotLookup) {
            return null;
        }
        return ensemblToUniprotLookup.get(ensemblId);        
    }
    
//    public ArrayList<String> getUniprotIdsForGeneName(String geneName) {
//        if (null == geneName || null == geneNameToUniprotLookup ) {
//            return null;
//        }
//        return geneNameToUniprotLookup.get(geneName);        
//    }    
    
    public ArrayList<String> getUniprotIdsForGeneOrfName(String geneOrfName) {
        if (null == geneOrfName || null == geneOrfNameToUniprotLookup) {
            return null;
        }
        return geneOrfNameToUniprotLookup.get(geneOrfName);        
    }
    
    public ArrayList<String> getUniprotIdsForRefSeqGeneId(String refSeqGeneId) {
        if (null == refSeqGeneId || null == refSeqGeneIdToUniprotLookup) {
            return null;
        }
        return refSeqGeneIdToUniprotLookup.get(refSeqGeneId);        
    }

    public String getPantherIdForUniprotId(String uniprotId) {
        if (null == uniprotId || null == uniprotToPantherId) {
            return null;
        }
        return uniprotToPantherId.get(uniprotId);        
    }
    
    public ArrayList<String> getPantherAnnotationsForPantherId(String pantherId) {
        if (null == pantherId || null == pantherIdToAnnotLookup) {
            return null;
        }
        return pantherIdToAnnotLookup.get(pantherId);        
    }
    
    public List<String> getPantherAnnotLabels() {
        return pantherAnnotLabels;
    }
    
    public ArrayList<String> getPantherIdsForEnhancer(String enhancerId) {
        if (null == enhancerId || null == enhancerToPantherLookup) {
            return null;
        }
        return enhancerToPantherLookup.get(enhancerId);     
    }
    
    public ArrayList<String> getAasaysForEnhancer(String enhancerId) {
        if (null == enhancerId || null == enhancerToAssayListLookup) {
            return null;
        }
        return enhancerToAssayListLookup.get(enhancerId);        
        
    }
    
    

    
    
    public static boolean outputLookupInfoHashMap(HashMap<String, ArrayList<String>> lookup, String fileName) {
        try {
            if (null == lookup || null == fileName) {
                return false;
            }
            boolean fileCreated = Utils.createFile(fileName);
            if (false == fileCreated) {
                return false;
            }
            Path outFile = Paths.get(fileName);
            for (Entry<String, ArrayList<String>> entry : lookup.entrySet()) {
                StringBuffer sb = new StringBuffer();
                sb.append(entry.getKey());
                sb.append(FILE_LOOKUP_SEPARATOR);
                sb.append(String.join(LOOKUP_VALUE_SEPARATOR, entry.getValue()));
                sb.append(Constants.STR_NEWLINE);
                Files.write(outFile, sb.toString().getBytes(), StandardOpenOption.APPEND);

            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }
    

    
    public  ArrayList<String>  getPantherAnnotationsForPantherIdSet(HashSet<String> pantherIdSet, String delim) {
        if (null == pantherIdSet) {
            return null;
        }
        ArrayList<HashSet<String>> combinedAnnots = new ArrayList<HashSet<String>>(numPantherAnnotLabels);
        for (int i = 0; i < numPantherAnnotLabels; i++) {
            combinedAnnots.add(new HashSet<String>()); 
        }
        for (String pantherId: pantherIdSet) {
            ArrayList<String> annotations = getPantherAnnotationsForPantherId(pantherId);
            if (null == annotations || (annotations.size() != numPantherAnnotLabels)) {
                continue;
            }
            for (int i = 0; i < numPantherAnnotLabels; i++) {
                String parts[] = annotations.get(i).split(Constants.DELIM_PANTHER_ID_PARTS);
                for (String part: parts) {
                    if (part.isEmpty()) {
                        continue;
                    }
                    combinedAnnots.get(i).add(part);
                }
            }
        }
        ArrayList<String> rtnSet = new ArrayList<String>();
        for (int i = 0; i < numPantherAnnotLabels; i++) {
            if (combinedAnnots.isEmpty()) {
                rtnSet.add(Constants.STR_EMPTY);
            }
            else {
                HashSet<String> curSet = combinedAnnots.get(i);
                ArrayList<String> strList = new ArrayList(curSet);
                String cur = Utils.listToString(strList, delim);
//                if (cur.startsWith(delim)) {
//                    System.out.println(cur);
//                }
                rtnSet.add(cur);
            }
        }
       return rtnSet;
    }
    
    public ArrayList<String> getPantherAnnotationsForEnsembleIdSet(Set<String> ensemblIdList, String delim) {
        if (null == ensemblIdList) {
            ArrayList<String> rtnSet = new ArrayList<String>(numPantherAnnotLabels);
            for (int j = 0; j < numPantherAnnotLabels; j++) {
                rtnSet.add(Constants.STR_EMPTY);
            }
            return rtnSet;
        }
         Set<String> uniprotIdSet = getUniprotIdSetForEnsemblIdSet(ensemblIdList);
        return getPantherAnnotationsForUniprotIdSet(uniprotIdSet, delim);
    }
    
    public Set<String> getUniprotIdSetForEnsemblIdSet(Set<String> ensemblIdList) {
        HashSet<String> uniprotIdSet = new HashSet<String>();
        for (String ensembl : ensemblIdList) {
            ArrayList<String> uniprotIds = getUniprotIdsForEnsembleId(ensembl);
            if (null == uniprotIds) {
                continue;
            }
            uniprotIdSet.addAll(uniprotIds);
        }
        return uniprotIdSet;
    }
    
    public Set<String> getEnsembleIdsForEntrezIdSetFromVep(Set<String> entrezIdSet) {
        HashSet<String> ensemblIdSet = new HashSet<String>();
        for (String entrezId : entrezIdSet) {
            ArrayList<String> mappedEnsemblIdList = getEnsemblIdsForEntrez(entrezId);

            if (null != mappedEnsemblIdList) {
                ensemblIdSet.addAll(mappedEnsemblIdList);
            }
        }
        return ensemblIdSet;
    }

    public ArrayList<String> getPantherAnnotationsForEntrezIdSetFromVep(Set<String> entrezIdSet, String delim) {
        Set<String> ensemblIdSet = getEnsembleIdsForEntrezIdSetFromVep(entrezIdSet);
        return getPantherAnnotationsForEnsembleIdSet(ensemblIdSet, delim);
    }
    
    
    public Set<String> getEnsemblIdsForGeneSymblsFromAnnovarAndSneff(Set<String> geneSymbolSet) {
        HashSet<String> ensemblIdSet = new HashSet<String>();
        for (String geneName : geneSymbolSet) {
            ArrayList<String> ensemblIdList = getEnsemblIdsForSymbol(geneName);
            if (null != ensemblIdList) {
                ensemblIdSet.addAll(ensemblIdList);
            }
        }
        return ensemblIdSet;
    }
    
    public ArrayList<String> getPantherAnnotationsForGeneSymbolsFromAnnovarAndSneff(Set<String> geneSymbolSet, String delim) {
        Set<String> ensemblIdSet = getEnsemblIdsForGeneSymblsFromAnnovarAndSneff(geneSymbolSet);
        return getPantherAnnotationsForEnsembleIdSet(ensemblIdSet, delim);
    }
    
    
    
    public  ArrayList<String> getPantherAnnotationsForUniprotIdSet(Set<String> uniprotIdSet, String delim) {
        HashSet<String> pantherIdSet = new HashSet<String>();
        for (String uniprotId : uniprotIdSet) {
            String pantherId = getPantherIdForUniprotId(uniprotId);
            if (null == pantherId) {
                continue;
            }
            pantherIdSet.add(pantherId);
        }
        return getPantherAnnotationsForPantherIdSet(pantherIdSet, delim);
    }       
    
    
    public static void main (String args[]) {
        IdMappingManager im = IdMappingManager.getInstance();
    }
}
