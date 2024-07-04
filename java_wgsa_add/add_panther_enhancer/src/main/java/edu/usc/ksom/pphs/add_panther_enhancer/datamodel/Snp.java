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
package edu.usc.ksom.pphs.add_panther_enhancer.datamodel;

import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import edu.usc.ksom.pphs.add_panther_enhancer.util.Utils;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.ChrRangeManager;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.IdMappingManager;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;


public class Snp {
    private boolean error = false;
    private String chromosome;
    private VCFHeader header;
    private int position;
    private String[] vcfParts;
    private int num_cols;
    private String[] cleanedVcfParts;
    
    private LoadToolAnnotations loadToolWorker;
    private LoadPepAnnotations loadPepWorker;
    private LoadEnhancerAnnotations loadEnhancerWorker;    

    // Results from Flanking region mapping
    private LinkedHashMap<Integer, ArrayList<String>> flankingToAnnotationLookup;
    private boolean captureAnnotDetails = false;

    public static final String DELIM_ADDED_ANNOTATIONS = ";";
    
    // Results from Tool Annotations
    private ArrayList<String> PantherAnnotsForAnnovarEnsemblGeneId;
    private ArrayList<String> PantherAnnotsForAnnovarRefSeqGeneId;
    private ArrayList<String> PantherAnnotsForSnpEffEnsemblGeneId;
    private ArrayList<String> PantherAnnotsForSnpEffRefSeqGeneId;
    private ArrayList<String> PantherAnnotsForVepEnsemblGeneId;
    private ArrayList<String> PantherAnnotsForVepRefSeqGeneId;
//    private ArrayList<String> PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic;
//    private ArrayList<String> PantherAnnotsForAnnovarRefSeqClosestGeneIdIntergenic;
    

    // Results from Enhancer mapping
    private ArrayList<String> enhancerPantherAnnots;
    private String enhancerIdList;
    private String genes;
    private String assays;
    
    public static final String COLS_TO_BE_ADDED[] = getColsToBeAdded();    
    
    private static String[] getColsToBeAdded() {
        ArrayList<String> addedCols = new ArrayList<String>();
        for (int i = 0; i < Constants.FLANKING_REGIONS.length; i++) {
            String prefix = Constants.PREFIX_COL_FLANKING + Constants.FLANKING_REGIONS[i] + Constants.MID_COL_FLANKING;
            for (int j = 0; j < Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length; j++) {
                addedCols.add(prefix + Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID[j]);
            }
        }
        for (int i = 0; i < Constants.ANNOT_COL_SET.length; i++) {
            for (int j = 0; j < Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length; j++) {
                addedCols.add(Constants.PREFIX_LABEL_ADD_ANNOT_SET[i] + Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID[j]);
            }
        }
        
        
        for (int j = 0; j < Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length; j++) {
            addedCols.add(Constants.PREFIX_LABEL_PEREGRINE_ENHANCER_LINKED + Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID[j]);
        }
        
        addedCols.add(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_ASSAY);
        addedCols.add(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_GENES);
        addedCols.add(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_ENHANCER);
        
        
        for (int i = 0; i < Constants.FLANKING_REGIONS.length; i++) {
            addedCols.add(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO + Constants.FLANKING_REGIONS[i] + Constants.SUFFIX_FLANKING_REGION);
            addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.FLANKING_REGIONS[i] + Constants.SUFFIX_FLANKING_REGION);            
        }
        
        addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.COL_ANNOVAR_ENSEMBL_GENE_ID); 
        addedCols.add(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO + Constants.COL_ANNOVAR_REFSEQ_GENE_ID); 
        addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.COL_ANNOVAR_REFSEQ_GENE_ID);
        
        addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.COL_SNEFF_ENSEMBL_GENE_ID); 
        addedCols.add(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO + Constants.COL_SNEFF_REFSEQ_GENE_ID); 
        addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.COL_SNEFF_REFSEQ_GENE_ID);

        addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.COL_VEP_ENSEMBL_GENE_ID); 
        addedCols.add(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO + Constants.COL_VEP_REFSEQ_GENE_ID); 
        addedCols.add(Constants.COL_PREFIX_UNIPROT_MAPPED_TO + Constants.COL_VEP_REFSEQ_GENE_ID);
        
        String[] strArray = new String[addedCols.size()];
        strArray = addedCols.toArray(strArray);
        return strArray;
    }
    
    public String getUpdatedVCFLine() {
        ArrayList list = new ArrayList(Arrays.asList(cleanedVcfParts));
        list.addAll(Arrays.asList(getValuesForColumnsToBeAdded()));
        return Utils.listToString(list, Constants.DELIM_VCF) + Constants.STR_NEWLINE;
        //return String.join(Constants.DELIM_VCF, cleanedVcfParts) + Constants.DELIM_VCF + String.join(Constants.DELIM_VCF, getValuesForColumnsToBeAdded()) + Constants.STR_NEWLINE;
    }
    
    public String getDetailsAboutAddedInfo() {
        if (false == this.captureAnnotDetails) {
            return null;
        }
        StringBuffer sb = new StringBuffer();
        sb.append(VCFHeader.COL_CHROMOSOME);
        sb.append(Constants.STR_COLON);
        sb.append(chromosome);
        sb.append(Constants.STR_NEWLINE);      
        sb.append(VCFHeader.COL_POSITION);
        sb.append(Constants.STR_COLON);
        sb.append(position);
        sb.append(Constants.STR_NEWLINE);
        
        for (int i = 0; i < Constants.FLANKING_REGIONS.length; i++) {
            sb.append(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO + Constants.FLANKING_REGIONS[i]);
            sb.append(Constants.SUFFIX_FLANKING_REGION);
            sb.append(Constants.STR_COLON);
            sb.append(loadPepWorker.flankingToMatchingEnsemblIdStr.get(Constants.FLANKING_REGIONS[i]));
            sb.append(Constants.STR_NEWLINE);
            sb.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO  + Constants.FLANKING_REGIONS[i]);
            sb.append(Constants.SUFFIX_FLANKING_REGION);
            sb.append(Constants.STR_COLON);
            sb.append(loadPepWorker.flankingToMatchingUniprotStr.get(Constants.FLANKING_REGIONS[i]));
            sb.append(Constants.STR_NEWLINE);
            sb.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO + Constants.FLANKING_REGIONS[i]);
            sb.append(Constants.SUFFIX_FLANKING_REGION);
            sb.append(Constants.STR_COLON);
            sb.append(loadPepWorker.flankingToMatchingPantherAnnotStr.get(Constants.FLANKING_REGIONS[i]));
            sb.append(Constants.STR_NEWLINE);            
        }
        
        // Tools information
        sb.append(getToolAnnotDetails().toString());

        sb.append(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_ENHANCER);
        sb.append(Constants.STR_COLON);
        sb.append(loadEnhancerWorker.enhancerList);
        sb.append(Constants.STR_NEWLINE);
        sb.append(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_ASSAY);
        sb.append(Constants.STR_COLON);
        sb.append(loadEnhancerWorker.assays);
        sb.append(Constants.STR_NEWLINE);        
        sb.append(Constants.LABEL_PEREGRINE_ENHANCER_LINKED_GENES);
        sb.append(Constants.STR_COLON);
        sb.append(loadEnhancerWorker.pantherIdsStr);
        sb.append(Constants.STR_NEWLINE);        
        sb.append(Constants.LABEL_PEREGRINE_MAPPED_ANNOTATIONS);
        sb.append(Constants.STR_COLON);
        sb.append(loadEnhancerWorker.annotStr);
        sb.append(Constants.STR_NEWLINE);
        sb.append(Constants.STR_NEWLINE);        
        return sb.toString();
    }
    
    private StringBuffer getToolAnnotDetails() {
        if (false == captureAnnotDetails) {
            return null;
        }

        StringBuffer annotDetailsBuf = new StringBuffer();
        annotDetailsBuf.append(Constants.COL_ANNOVAR_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.AnnovarEnsemblGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_ANNOVAR_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.uniprotIdMappedToAnnovarEnsemblGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_ANNOVAR_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(getPantherAnnotsAsStr(loadToolWorker.PantherAnnotsForAnnovarEnsemblGeneId));
        annotDetailsBuf.append(Constants.STR_NEWLINE);

        annotDetailsBuf.append(Constants.COL_ANNOVAR_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.AnnovarRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_ANNOVAR_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.ensemblGeneIdMappedToAnnovarRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_ANNOVAR_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.uniprotIdMappedToAnnovarRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_ANNOVAR_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(getPantherAnnotsAsStr(loadToolWorker.PantherAnnotsForAnnovarRefSeqGeneId));
        annotDetailsBuf.append(Constants.STR_NEWLINE);

        annotDetailsBuf.append(Constants.COL_SNEFF_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.SnpEffEnsemblGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_SNEFF_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.uniprotIdMappedToSnpEffEnsemblGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_SNEFF_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(getPantherAnnotsAsStr(loadToolWorker.PantherAnnotsForSnpEffEnsemblGeneId));
        annotDetailsBuf.append(Constants.COL_SNEFF_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_NEWLINE);

        annotDetailsBuf.append(Constants.COL_SNEFF_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.SnpEffRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_SNEFF_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.ensemblGeneIdMappedToSnpEffRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_SNEFF_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.uniprotIdMappedToSnpEffSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_SNEFF_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(getPantherAnnotsAsStr(loadToolWorker.PantherAnnotsForSnpEffRefSeqGeneId));
        annotDetailsBuf.append(Constants.STR_NEWLINE);

        annotDetailsBuf.append(Constants.COL_VEP_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.VepEnsemblGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_VEP_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.uniprotIdMappedToVepEnsemblGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_VEP_ENSEMBL_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(getPantherAnnotsAsStr(loadToolWorker.PantherAnnotsForVepEnsemblGeneId));
        annotDetailsBuf.append(Constants.STR_NEWLINE);

        annotDetailsBuf.append(Constants.COL_VEP_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.VepRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_ENSEMBL_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_VEP_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.ensembleGeneIdMappedToVepRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_UNIPROT_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_VEP_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(loadToolWorker.uniprotIdMappedToVepRefSeqGeneId);
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        annotDetailsBuf.append(Constants.COL_PREFIX_PANTHER_MAPPED_TO);
        annotDetailsBuf.append(Constants.COL_VEP_REFSEQ_GENE_ID);
        annotDetailsBuf.append(Constants.STR_COLON);
        annotDetailsBuf.append(getPantherAnnotsAsStr(loadToolWorker.PantherAnnotsForVepRefSeqGeneId));
        annotDetailsBuf.append(Constants.STR_NEWLINE);
        return annotDetailsBuf;

    }
    
    private String[] getValuesForColumnsToBeAdded() {
        ArrayList<String> valuesList = new ArrayList<String>(COLS_TO_BE_ADDED.length);
        for (int i = 0; i < Constants.FLANKING_REGIONS.length; i++) {
            ArrayList<String> curFlankingRegionAnnots = flankingToAnnotationLookup.get(Constants.FLANKING_REGIONS[i]);
            for (int j = 0; j < Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length; j++) {
                valuesList.add(curFlankingRegionAnnots.get(j));
            }
        }
        
        ArrayList<ArrayList<String>> listOfAnnotResults = new ArrayList<ArrayList<String>>();
        listOfAnnotResults.add(PantherAnnotsForAnnovarEnsemblGeneId);
        listOfAnnotResults.add(PantherAnnotsForAnnovarRefSeqGeneId);
        listOfAnnotResults.add(PantherAnnotsForSnpEffEnsemblGeneId);
        listOfAnnotResults.add(PantherAnnotsForSnpEffRefSeqGeneId);
        listOfAnnotResults.add(PantherAnnotsForVepEnsemblGeneId);
        listOfAnnotResults.add(PantherAnnotsForVepRefSeqGeneId);
//        listOfAnnotResults.add(PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic);
//        listOfAnnotResults.add(PantherAnnotsForAnnovarRefSeqClosestGeneIdIntergenic);        
        
        
        for (ArrayList<String> results : listOfAnnotResults) {
            for (String result : results) {
                valuesList.add(result);
            }
        }

        for (String result : enhancerPantherAnnots) {
            valuesList.add(result);
        }
        
        valuesList.add(assays);
        valuesList.add(genes);
        valuesList.add(enhancerIdList);

        for (int i = 0; i < Constants.FLANKING_REGIONS.length; i++) {
            valuesList.add(loadPepWorker.flankingToMatchingEnsemblIdStr.get(Constants.FLANKING_REGIONS[i]));
            valuesList.add(loadPepWorker.flankingToMatchingUniprotStr.get(Constants.FLANKING_REGIONS[i]));
        }
        
        valuesList.add(loadToolWorker.uniprotIdMappedToAnnovarEnsemblGeneId);
        valuesList.add(loadToolWorker.ensemblGeneIdMappedToAnnovarRefSeqGeneId);
        valuesList.add(loadToolWorker.uniprotIdMappedToAnnovarRefSeqGeneId);        

        valuesList.add(loadToolWorker.uniprotIdMappedToSnpEffEnsemblGeneId);
        valuesList.add(loadToolWorker.ensemblGeneIdMappedToSnpEffRefSeqGeneId);
        valuesList.add(loadToolWorker.uniprotIdMappedToSnpEffSeqGeneId); 

        valuesList.add(loadToolWorker.uniprotIdMappedToVepEnsemblGeneId);
        valuesList.add(loadToolWorker.ensembleGeneIdMappedToVepRefSeqGeneId);
        valuesList.add(loadToolWorker.uniprotIdMappedToVepRefSeqGeneId);         
        
        String[] array = new String[valuesList.size()];
        valuesList.toArray(array);
        return array;
    }
    
    
    public Snp(VCFHeader header, String vcfLine, boolean captureAnotDetails) {
        this.captureAnnotDetails = captureAnotDetails;
        if (this.captureAnnotDetails) {
            this.header = header;
        }
        if (null == header || null == vcfLine) {
            error = true;
            return;
        }
        vcfParts = vcfLine.split(Constants.DELIM_VCF);
        if ( header.getNumOrigCols() != vcfParts.length) {
            error = true;
            return;
        }
        num_cols = header.getNumOrigCols();
        this.chromosome = vcfParts[header.getChromosomeCol()];
        this.position = Integer.parseInt(vcfParts[header.getPositionCol()]);
        cleanupVcf();
        
        // Add annotations to the SNP
        // There are three types of annotations to be added:
        // 1. Tool
        // 2. Flanking region based
        // 3. Enhancer
        
//        ExecutorService executor = Executors.newFixedThreadPool(3);
//        LoadToolAnnotations loadToolWorker = new LoadToolAnnotations(cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_ENSEMBL_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_REFSEQ_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_SNEFF_ENSEMBL_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_SNEFF_REFSEQ_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_VEP_ENSEMBL_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_VEP_REFSEQ_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_CLOSEST_ENSEMBL_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_CLOSEST_REFSEQ_GENE_ID)]);
//        executor.execute(loadToolWorker);
//        LoadPepAnnotations loadPepWorker = new LoadPepAnnotations(chromosome, position);
//        executor.execute(loadPepWorker);        
//        LoadEnhancerAnnotations loadEnhancerWorker = new LoadEnhancerAnnotations(chromosome, position);
//        executor.execute(loadEnhancerWorker);        
//        executor.shutdown();
//        
//        // Wait until all threads finish
//        while (!executor.isTerminated()) {
//
//        }

//        ExecutorService executor = Executors.newFixedThreadPool(3);
        loadToolWorker = new LoadToolAnnotations(cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_ENSEMBL_GENE_ID)],
                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_REFSEQ_GENE_ID)],
                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_SNEFF_ENSEMBL_GENE_ID)],
                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_SNEFF_REFSEQ_GENE_ID)],
                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_VEP_ENSEMBL_GENE_ID)],
                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_VEP_REFSEQ_GENE_ID)]);
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_CLOSEST_ENSEMBL_GENE_ID)],
//                                                                        cleanedVcfParts[header.getColumnForAnnotationColumn(Constants.COL_ANNOVAR_CLOSEST_REFSEQ_GENE_ID)]);
        loadToolWorker.run();
        loadPepWorker = new LoadPepAnnotations(chromosome, position);
        loadPepWorker.run();
//        executor.execute(loadPepWorker);        
        loadEnhancerWorker = new LoadEnhancerAnnotations(chromosome, position);
        loadEnhancerWorker.run();
//        executor.execute(loadEnhancerWorker);        
//        executor.shutdown();
        
        // Wait until all threads finish
//        while (!executor.isTerminated()) {
//
//        }
        
        PantherAnnotsForAnnovarEnsemblGeneId = loadToolWorker.PantherAnnotsForAnnovarEnsemblGeneId;
        PantherAnnotsForAnnovarRefSeqGeneId = loadToolWorker.PantherAnnotsForAnnovarRefSeqGeneId;
        PantherAnnotsForSnpEffEnsemblGeneId = loadToolWorker.PantherAnnotsForSnpEffEnsemblGeneId;
        PantherAnnotsForSnpEffRefSeqGeneId = loadToolWorker.PantherAnnotsForSnpEffRefSeqGeneId;
        PantherAnnotsForVepEnsemblGeneId = loadToolWorker.PantherAnnotsForVepEnsemblGeneId;
        PantherAnnotsForVepRefSeqGeneId = loadToolWorker.PantherAnnotsForVepRefSeqGeneId;
//        PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic = loadToolWorker.PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic;
//        PantherAnnotsForAnnovarRefSeqClosestGeneIdIntergenic = loadToolWorker.PantherAnnotsForAnnovarRefSeqClosestGeneIdIntergenic;
        
        flankingToAnnotationLookup = loadPepWorker.flankingToAnnotationLookup;
        
        enhancerPantherAnnots = loadEnhancerWorker.pantherAnnots;
        enhancerIdList  = loadEnhancerWorker.enhancerList;
        genes  = loadEnhancerWorker.genes;
        assays  = loadEnhancerWorker.assays;
        
    }
    
    public void cleanupVcf() {
        String cleanedVcf[] = new String[num_cols];
        for (int i = 0; i < num_cols; i++) {
            String current = vcfParts[i];
            String cleaned = current.trim();
            String parts[] = cleaned.split(Constants.DELIM_PANTHER_ID_PARTS);
            ArrayList<String> validEntries = new ArrayList<String>();
            for (String part: parts) {
                if (Constants.VCF_PLACEHOLDER_EMPTY.equals(part)) {
                    continue;
                }
                if (part.contains(Constants.VCF_NONE_ENTRY)) {
                    ArrayList<String> nonNoneEntries = new ArrayList<String>();
                    String noneParts[] = part.split(Constants.VCF_DELIM_ALTERNATE);
                    for (String none: noneParts) {
                        if (none.equalsIgnoreCase(Constants.VCF_NONE_ENTRY)) {
                            continue;
                        }
                        if (false == nonNoneEntries.contains(none)) {
                            nonNoneEntries.add(none);
                        }
                    }
                    part = String.join(Constants.VCF_DELIM_ALTERNATE, nonNoneEntries);
                }
                if (false == validEntries.contains(part)) {
                    validEntries.add(part);
                }

            }
            if (0 == validEntries.size()) {
                cleanedVcf[i] = Constants.STR_EMPTY;
            } else {
                cleanedVcf[i] = String.join(Constants.STR_PIPE, validEntries);
            }
        }
        cleanedVcfParts = cleanedVcf;
    }
    
    public static String getPantherAnnotsAsStr(ArrayList<String> annots) {
        if (null == annots) {
            return Constants.STR_EMPTY;
        }
        if (annots.size() != Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length) {
            return Constants.STR_EMPTY;
        }
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length - 1; i++) {
            sb.append(Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID[i]);
            sb.append(Constants.STR_EQUAL);
            sb.append(annots.get(i));
            sb.append(Constants.STR_COMMA);
        }

        // Append the last item without delimiter
        sb.append(Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID[Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length - 1]);
        sb.append(Constants.STR_EQUAL);
        sb.append(annots.get(Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID.length - 1));   
        
        return sb.toString();
    }
    
    
    public class LoadToolAnnotations implements Runnable {
    public String AnnovarEnsemblGeneId;
    public String AnnovarRefSeqGeneId;
    public String SnpEffEnsemblGeneId;
    public String SnpEffRefSeqGeneId;
    public String VepEnsemblGeneId;
    public String VepRefSeqGeneId;
//    public String AnnovarEnsemblClosestGeneIntergenic;
//    public String AnnovarRefSeqClosestGeneIntergenic;
    
    
    public String uniprotIdMappedToAnnovarEnsemblGeneId;
//    public String annovarEnsemblGeneIdPantherAnnotStr;    
    public String ensemblGeneIdMappedToAnnovarRefSeqGeneId;
    public String uniprotIdMappedToAnnovarRefSeqGeneId;
//    public String annovarRefSeqGeneIdPantherAnnotStr;  
    
    public String uniprotIdMappedToSnpEffEnsemblGeneId;
//    public String snpEffEnsemblGeneIdPantherAnnotStr;    
    public String ensemblGeneIdMappedToSnpEffRefSeqGeneId;
    public String uniprotIdMappedToSnpEffSeqGeneId; 
//    public String snpEffRefSeqGeneIdPantherAnnotStr;
    
    
    public String uniprotIdMappedToVepEnsemblGeneId;
//    public String vepEnsemblGeneIdPantherAnnotStr;    
    public String ensembleGeneIdMappedToVepRefSeqGeneId;
    public String uniprotIdMappedToVepRefSeqGeneId;   
//    public String vepRefSeqGeneIdPantherAnnotStr;
    
//    public StringBuffer annotDetailsBuf;
    
    public ArrayList<String> PantherAnnotsForAnnovarEnsemblGeneId;
    public ArrayList<String> PantherAnnotsForAnnovarRefSeqGeneId;
    public ArrayList<String> PantherAnnotsForSnpEffEnsemblGeneId;
    public ArrayList<String> PantherAnnotsForSnpEffRefSeqGeneId;
    public ArrayList<String> PantherAnnotsForVepEnsemblGeneId;
    public ArrayList<String> PantherAnnotsForVepRefSeqGeneId;
//    public ArrayList<String> PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic;
//    public ArrayList<String> PantherAnnotsForAnnovarRefSeqClosestGeneIdIntergenic;

    public static final String DELIM_ENSEMBL = "\\|";
    public static final String DELIM_ENSEMBL_ALTERNATE = "-";    
    public static final String DELIM_REFSEQ = "\\|";
    public static final String DELIM_REFSEQ_ALTERNATE = "-";
    public static final String DELIM_VEP_REFSEQ = "\\|";
    public static final String DELIM_ANNOVAR_CLOSEST_GENE = "\\|";    
    public static final String DELIM_ANNOVAR_CLOSEST_GENE_PAIR = ","; 
    public static final String DELIM_ANNOVAR_CLOSEST_GENE_ID_SEPARATOR = ":"; 
    
    public LoadToolAnnotations(String AnnovarEnsemblGeneId,
                                    String AnnovarRefSeqGeneId,
                                    String SnpEffEnsemblGeneId,
                                    String SnpEffRefSeqGeneId,
                                    String VepEnsemblGeneId,
                                    String VepRefSeqGeneId) {
//                                    String AnnovarEnsemblClosestGeneIntergenic,
//                                    String AnnovarRefSeqClosestGeneIntergenic) {
            this.AnnovarEnsemblGeneId = AnnovarEnsemblGeneId;
            this.AnnovarRefSeqGeneId = AnnovarRefSeqGeneId;
            this.SnpEffEnsemblGeneId = SnpEffEnsemblGeneId;
            this.SnpEffRefSeqGeneId = SnpEffRefSeqGeneId;
            this.VepEnsemblGeneId = VepEnsemblGeneId;
            this.VepRefSeqGeneId = VepRefSeqGeneId;
//            this.AnnovarEnsemblClosestGeneIntergenic = AnnovarEnsemblClosestGeneIntergenic;
//            this.AnnovarRefSeqClosestGeneIntergenic = AnnovarRefSeqClosestGeneIntergenic;      
        }

        @Override
        public void run() {
            PantherAnnotsForAnnovarEnsemblGeneId = processEnsemblGeneId(AnnovarEnsemblGeneId);
            PantherAnnotsForAnnovarRefSeqGeneId = processRefSeqGeneId(AnnovarRefSeqGeneId, Constants.AnnotationTool.ANNOVAR);
            PantherAnnotsForSnpEffEnsemblGeneId = processEnsemblGeneId(SnpEffEnsemblGeneId);
            PantherAnnotsForSnpEffRefSeqGeneId = processRefSeqGeneId(SnpEffRefSeqGeneId, Constants.AnnotationTool.SNEFF);
            PantherAnnotsForVepEnsemblGeneId = processEnsemblGeneId(VepEnsemblGeneId);
            PantherAnnotsForVepRefSeqGeneId = processRefSeqGeneId(VepRefSeqGeneId, Constants.AnnotationTool.VEP);
//            PantherAnnotsForAnnovarEnsemblClosestGeneIdIntergenic = processEnsemblClosestGeneId(AnnovarEnsemblClosestGeneIntergenic);
//            PantherAnnotsForAnnovarRefSeqClosestGeneIdIntergenic = processEnsemblClosestRefSeq(AnnovarRefSeqClosestGeneIntergenic);
//            if (true == captureAnnotDetails) {
//                annotDetailsBuf = new StringBuffer();
            IdMappingManager im = IdMappingManager.getInstance();
            Set<String> ensemblGeneIdSet = convertEnsemblGeneIdStrToSet(AnnovarEnsemblGeneId);
            Set<String> uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblGeneIdSet);
            uniprotIdMappedToAnnovarEnsemblGeneId = Utils.listToString(new ArrayList<String>(uniprotIdSet), DELIM_ADDED_ANNOTATIONS);
            PantherAnnotsForAnnovarEnsemblGeneId = im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS);
//                annovarEnsemblGeneIdPantherAnnotStr = getPantherAnnotsAsStr(PantherAnnotsForAnnovarEnsemblGeneId);
//                Assert.assertEquals(getPantherAnnotsAsStr(PantherAnnotsForAnnovarEnsemblGeneId), annovarEnsemblGeneIdPantherAnnotStr);

            // Annovar refSeqGeneId
            Set<String> geneSymbolSet = parsetRefSeqGeneIdStrFromAnnovarSnpEffToSet(AnnovarRefSeqGeneId);
            ensemblGeneIdSet = im.getEnsemblIdsForGeneSymblsFromAnnovarAndSneff(geneSymbolSet);
            uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblGeneIdSet);
            ensemblGeneIdMappedToAnnovarRefSeqGeneId = Utils.listToString(new ArrayList<String>(ensemblGeneIdSet), DELIM_ADDED_ANNOTATIONS);
            uniprotIdMappedToAnnovarRefSeqGeneId = Utils.listToString(new ArrayList<String>(uniprotIdSet), DELIM_ADDED_ANNOTATIONS);
            PantherAnnotsForAnnovarRefSeqGeneId = im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS);
//                annovarRefSeqGeneIdPantherAnnotStr = getPantherAnnotsAsStr(PantherAnnotsForAnnovarRefSeqGeneId);
//                Assert.assertEquals(getPantherAnnotsAsStr(PantherAnnotsForAnnovarRefSeqGeneId), annovarEnsemblGeneIdPantherAnnotStr);

            //SnpEff
            ensemblGeneIdSet = convertEnsemblGeneIdStrToSet(SnpEffEnsemblGeneId);
            uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblGeneIdSet);
            uniprotIdMappedToSnpEffEnsemblGeneId = Utils.listToString(new ArrayList<String>(uniprotIdSet), DELIM_ADDED_ANNOTATIONS);
            PantherAnnotsForSnpEffEnsemblGeneId = im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS);
//                snpEffEnsemblGeneIdPantherAnnotStr = getPantherAnnotsAsStr(PantherAnnotsForSnpEffEnsemblGeneId);
//                Assert.assertEquals(getPantherAnnotsAsStr(PantherAnnotsForSnpEffEnsemblGeneId), snpEffEnsemblGeneIdPantherAnnotStr);

            // SnpEff refSeqGeneId
            geneSymbolSet = parsetRefSeqGeneIdStrFromAnnovarSnpEffToSet(SnpEffRefSeqGeneId);
            ensemblGeneIdSet = im.getEnsemblIdsForGeneSymblsFromAnnovarAndSneff(geneSymbolSet);
            uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblGeneIdSet);
            ensemblGeneIdMappedToSnpEffRefSeqGeneId = Utils.listToString(new ArrayList<String>(ensemblGeneIdSet), DELIM_ADDED_ANNOTATIONS);
            uniprotIdMappedToSnpEffSeqGeneId = Utils.listToString(new ArrayList<String>(uniprotIdSet), DELIM_ADDED_ANNOTATIONS);
            PantherAnnotsForSnpEffRefSeqGeneId = im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS);
//                snpEffRefSeqGeneIdPantherAnnotStr = getPantherAnnotsAsStr(PantherAnnotsForSnpEffRefSeqGeneId);
//                Assert.assertEquals(getPantherAnnotsAsStr(PantherAnnotsForSnpEffRefSeqGeneId), snpEffRefSeqGeneIdPantherAnnotStr);

            // VEP
            ensemblGeneIdSet = convertEnsemblGeneIdStrToSet(VepEnsemblGeneId);
            uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblGeneIdSet);
            uniprotIdMappedToVepEnsemblGeneId = Utils.listToString(new ArrayList<String>(uniprotIdSet), DELIM_ADDED_ANNOTATIONS);
            PantherAnnotsForVepEnsemblGeneId = im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS);
//                vepEnsemblGeneIdPantherAnnotStr = getPantherAnnotsAsStr(PantherAnnotsForVepEnsemblGeneId);
//                Assert.assertEquals(getPantherAnnotsAsStr(PantherAnnotsForVepEnsemblGeneId), vepEnsemblGeneIdPantherAnnotStr);
//                
//                Assert.assertEquals(getPantherAnnotsAsStr(PantherAnnotsForVepRefSeqGeneId), vepEffRefSeqGeneIdPantherAnnotStr);

            Set<String> entrezIdSet = parseRefSeqGeneIdStrFromVep(VepRefSeqGeneId);
            Set<String> ensemblIdSet = im.getEnsembleIdsForEntrezIdSetFromVep(entrezIdSet);
            ensembleGeneIdMappedToVepRefSeqGeneId = Utils.listToString(new ArrayList<String>(ensemblIdSet), DELIM_ADDED_ANNOTATIONS);
            uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblIdSet);
            uniprotIdMappedToVepRefSeqGeneId = Utils.listToString(new ArrayList<String>(uniprotIdSet), DELIM_ADDED_ANNOTATIONS);
            PantherAnnotsForVepRefSeqGeneId = im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS);
//                vepRefSeqGeneIdPantherAnnotStr = getPantherAnnotsAsStr(PantherAnnotsForVepRefSeqGeneId);

//            }
        }
        
        Set<String> convertEnsemblGeneIdStrToSet(String ensemblGeneIdStr) {
            HashSet<String> ensemblIdSet = new HashSet<String>();
            String parts[] = ensemblGeneIdStr.split(DELIM_ENSEMBL);
            for (int i = 0; i < parts.length; i++) {
                String secParts[] = parts[i].split(DELIM_ENSEMBL_ALTERNATE);
                ensemblIdSet.addAll(Arrays.asList(secParts));
            }
            return ensemblIdSet;
        }
        
        Set<String> parsetRefSeqGeneIdStrFromAnnovarSnpEffToSet(String refSeqGeneId) {
            HashSet<String> geneSymbolSet = new HashSet<String>();
            String parts[] = refSeqGeneId.split(DELIM_REFSEQ);
            for (int i = 0; i < parts.length; i++) {
                String secParts[] = parts[i].split(DELIM_REFSEQ_ALTERNATE);
                geneSymbolSet.addAll(Arrays.asList(secParts));
            }
            return geneSymbolSet;
        }
        
        Set<String> parseRefSeqGeneIdStrFromVep(String refSeqGeneId) {
            HashSet<String> geneSymbolSet = new HashSet<String>();
            String parts[] = refSeqGeneId.split(DELIM_VEP_REFSEQ);
            for (int i = 0; i < parts.length; i++) {
                String secParts[] = parts[i].split(DELIM_REFSEQ_ALTERNATE);
                for (int j = 0; j < secParts.length; j++) {
                    geneSymbolSet.add(secParts[j]);
                }
            }
            return geneSymbolSet;
        }
        
        ArrayList<String> processEnsemblGeneId(String ensemblGeneIdStr) {
            return IdMappingManager.getInstance().getPantherAnnotationsForEnsembleIdSet(convertEnsemblGeneIdStrToSet(ensemblGeneIdStr), DELIM_ADDED_ANNOTATIONS);
        }

        ArrayList<String> processRefSeqGeneId(String refSeqGeneId, Constants.AnnotationTool annotTool) {
            IdMappingManager im = IdMappingManager.getInstance();
            if (null == refSeqGeneId || refSeqGeneId.equalsIgnoreCase(Constants.STR_EMPTY)) {
                return im.getPantherAnnotationsForEnsembleIdSet(new HashSet<String>(), DELIM_ADDED_ANNOTATIONS);
            }

            switch (annotTool) {    
                case ANNOVAR:
                case SNEFF: {
                    
                    //For Annovar, SNEFF refSeqGeneIds are gene Symbols
                    return im.getPantherAnnotationsForGeneSymbolsFromAnnovarAndSneff(parsetRefSeqGeneIdStrFromAnnovarSnpEffToSet(refSeqGeneId), DELIM_ADDED_ANNOTATIONS);
//                    HashSet<String> ensemblIdSet = new HashSet<String>();
//                    for (String geneName: geneSymbolSet) {
//                        ArrayList<String> ensemblIdList = im.getEnsemblIdsForSymbol(geneName);
//                        if (null != ensemblIdList) {
//                            ensemblIdSet.addAll(ensemblIdList);
//                        }
//                    }
//                    return im.getPantherAnnotationsForEnsembleIdSet(ensemblIdSet, DELIM_ADDED_ANNOTATIONS);
                }
                case VEP: {
                    // For VEP, refSeqGeneId is an entrez id.  This can be mapped in Ensembl and PANTHER
                    return im.getPantherAnnotationsForEntrezIdSetFromVep(parseRefSeqGeneIdStrFromVep(refSeqGeneId), DELIM_ADDED_ANNOTATIONS);
                 }
            }
            return null;
        }

//        ArrayList<String> processEnsemblClosestGeneId(String ensemblClosestGeneStr) {
//            HashSet<String> ensemblIdSet = new HashSet<String>();
//            String parts[] = ensemblClosestGeneStr.split(DELIM_ANNOVAR_CLOSEST_GENE);
//            for (int i = 0; i < parts.length; i++) {
//                String pairs[] = parts[i].split(DELIM_ANNOVAR_CLOSEST_GENE_PAIR); // Is this always two part?
//                for (int j = 0; j < pairs.length; j++) {
//                    String details = pairs[j];
//                    int index = details.indexOf(DELIM_ANNOVAR_CLOSEST_GENE_ID_SEPARATOR);
//                    if (index > 0) {
//                        ensemblIdSet.add(details.substring(0, index));
//                    }
//                }
//            }
//            return AnnotationHelper.getPantherAnnotationsForEnsembleIdSet(ensemblIdSet, DELIM_ADDED_ANNOTATIONS);
//        }
        
//        ArrayList<String> processEnsemblClosestRefSeq(String ensemblClosestRefSeqGeneStr) {
//            IdMappingManager idm = IdMappingManager.getInstance();
//            //For Annovar, refSeqGeneIds are gene Symbols.  Thsse can be mapped to Ensembl ids
//            HashSet<String> ensemblIdSet = new HashSet<String>();
//            String parts[] = ensemblClosestRefSeqGeneStr.split(DELIM_ANNOVAR_CLOSEST_GENE);
//            for (int i = 0; i < parts.length; i++) {
//                String pairs[] = parts[i].split(DELIM_ANNOVAR_CLOSEST_GENE_PAIR); // Is this always two part?
//                for (int j = 0; j < pairs.length; j++) {
//                    String details = pairs[j];
//                    int index = details.indexOf(DELIM_ANNOVAR_CLOSEST_GENE_ID_SEPARATOR);
//                    if (index > 0) {
//                        ArrayList<String> ensemblIdList = idm.getEnsemblIdsForSymbol(details.substring(0, index));
//                        if (null != ensemblIdList) {
//                            ensemblIdSet.addAll(ensemblIdList);
//                        }
//                    }
//                }
//            }
//
//            return AnnotationHelper.getPantherAnnotationsForEnsembleIdSet(ensemblIdSet, DELIM_ADDED_ANNOTATIONS);
//        }        
    }    
   
    public class LoadPepAnnotations implements Runnable {
        public String chromosome;
        public int position;
        
        public LinkedHashMap<Integer, ArrayList<String>> flankingToAnnotationLookup = new LinkedHashMap<Integer, ArrayList<String>>();
        public LinkedHashMap<Integer, String> flankingToMatchingEnsemblIdStr = new LinkedHashMap<Integer, String>();
        public LinkedHashMap<Integer, String> flankingToMatchingUniprotStr = new LinkedHashMap<Integer, String>();
        public LinkedHashMap<Integer, String> flankingToMatchingPantherAnnotStr = new LinkedHashMap<Integer, String>();
        
        LoadPepAnnotations(String chromosome, int position) {
            this.chromosome = chromosome;
            this.position = position;
        }

        @Override
        public void run() {
            ChrRangeManager cm = ChrRangeManager.getInstance();
            IdMappingManager im = IdMappingManager.getInstance();
            for (int i = 0; i < Constants.FLANKING_REGIONS.length; i++) {
                HashSet<String> ensemblIdList = cm.getPepMappings(chromosome, position, Constants.FLANKING_REGIONS[i]);
                if (null == ensemblIdList) {
                    ensemblIdList = new  HashSet<String>();
                }
                //flankingToAnnotationLookup.put(Constants.FLANKING_REGIONS[i], im.getPantherAnnotationsForEnsembleIdSet(ensemblIdList, DELIM_ADDED_ANNOTATIONS));
                flankingToMatchingEnsemblIdStr.put(Constants.FLANKING_REGIONS[i], Utils.listToString(new ArrayList(ensemblIdList), DELIM_ADDED_ANNOTATIONS));
                Set<String> uniprotIdSet = im.getUniprotIdSetForEnsemblIdSet(ensemblIdList);
                flankingToMatchingUniprotStr.put(Constants.FLANKING_REGIONS[i], Utils.listToString(new ArrayList(uniprotIdSet), DELIM_ADDED_ANNOTATIONS));
                flankingToMatchingPantherAnnotStr.put(Constants.FLANKING_REGIONS[i], getPantherAnnotsAsStr(im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS)));                        
                flankingToAnnotationLookup.put(Constants.FLANKING_REGIONS[i], im.getPantherAnnotationsForUniprotIdSet(uniprotIdSet, DELIM_ADDED_ANNOTATIONS)); 
            }
        }
    }
    
    public class LoadEnhancerAnnotations implements Runnable {
        public String chromosome;
        public int position;
        public ArrayList<String> pantherAnnots;
        public String enhancerList;
        public String genes;
        public String assays;
        
        // Used for debugging
        public String pantherIdsStr;
        public String annotStr;
        LoadEnhancerAnnotations(String chromosome, int position) {
            this.chromosome = chromosome;
            this.position = position;
        }

        @Override
        public void run() {
            ArrayList<String> enhancerIdList = ChrRangeManager.getInstance().getEnhancerMapping(chromosome, position);
            if (null == enhancerIdList) {
                enhancerIdList = new ArrayList<String>();
            }
            IdMappingManager im = IdMappingManager.getInstance();
            HashSet<String> pantherIds = new HashSet<String>();
            HashSet<String> assayIdSet = new HashSet<String>();
            for (String enhancerId: enhancerIdList) {
                
                ArrayList<String> pantherLongIds = im.getPantherIdsForEnhancer(enhancerId);
                if (null != pantherLongIds) {
                    pantherIds.addAll(pantherLongIds);
                }

                ArrayList<String> assayIds = im.getAasaysForEnhancer(enhancerId);
                if (null != assayIds) {
                    assayIdSet.addAll(assayIds);
                }                
            }
            if (true == captureAnnotDetails) {
                pantherIdsStr = Utils.listToString(new ArrayList(pantherIds), DELIM_ADDED_ANNOTATIONS);
                ArrayList<String> annotList = im.getPantherAnnotationsForPantherIdSet(pantherIds, DELIM_ADDED_ANNOTATIONS);
                annotStr = getPantherAnnotsAsStr(annotList);
              
            }
            genes = String.join(DELIM_ADDED_ANNOTATIONS, pantherIds);
            assays  = String.join(DELIM_ADDED_ANNOTATIONS, assayIdSet);
            enhancerList  = String.join(DELIM_ADDED_ANNOTATIONS, enhancerIdList);            
            pantherAnnots = im.getPantherAnnotationsForPantherIdSet(pantherIds, DELIM_ADDED_ANNOTATIONS);
        }
    }    
    
    public boolean isError() {
        return this.error;
    }
}
