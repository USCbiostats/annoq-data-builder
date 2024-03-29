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

package edu.usc.ksom.pphs.add_panther_enhancer.constants;


public class Constants {

    public static final String DELIM_VCF = "\t";
    public static final String STR_EMPTY = "";
    public static final String STR_NEWLINE = "\n";
    public static final String STR_COLON = ":";
    public static final String STR_EQUAL = "=";
    public static final String STR_COMMA = ",";    
    public static final int[] FLANKING_REGIONS = new int[]{0, 10000, 20000};
    
   public static enum AnnotationTool {ANNOVAR, SNEFF, VEP};    
    
    
    public static final String[] EXPECTED_PANTHER_ANNOT_LABELS = new String[]{"GO_molecular_function_complete_list_id",
                                                                    "GO_biological_process_complete_list_id",
                                                                    "GO_cellular_component_complete_list_id",
                                                                    "PANTHER_GO_SLIM_molecular_function_list_id",
                                                                    "PANTHER_GO_SLIM_biological_process_list_id",
                                                                    "PANTHER_GO_SLIM_cellular_component_list_id",
                                                                    "PANTHER_protein_class_list_id",
                                                                    "REACTOME_pathway_list_id",
                                                                    "PANTHER_pathway_list_id"};
    
    public static final String COL_ANNOVAR_ENSEMBL_GENE_ID = "ANNOVAR_ensembl_Gene_ID";
    public static final String COL_ANNOVAR_REFSEQ_GENE_ID = "ANNOVAR_refseq_Gene_ID";
    public static final String COL_SNEFF_ENSEMBL_GENE_ID = "SnpEff_ensembl_Gene_ID";
    public static final String COL_SNEFF_REFSEQ_GENE_ID = "SnpEff_refseq_Gene_ID";    
    public static final String COL_VEP_ENSEMBL_GENE_ID = "VEP_ensembl_Gene_ID";
    public static final String COL_VEP_REFSEQ_GENE_ID = "VEP_refseq_Gene_ID";
    
    public static final String COL_PREFIX_UNIPROT_MAPPED_TO = "Uniprot_mapped_to_";
    public static final String COL_PREFIX_ENSEMBL_MAPPED_TO = "Ensembl_mapped_to_";
    public static final String COL_PREFIX_PANTHER_MAPPED_TO = "PANTHER_mapped_to_";
    
//    public static final String COL_ANNOVAR_CLOSEST_ENSEMBL_GENE_ID = "ANNOVAR_ensembl_Closest_gene(intergenic_only)";
//    public static final String COL_ANNOVAR_CLOSEST_REFSEQ_GENE_ID = "ANNOVAR_refseq_Closest_gene(intergenic_only)";

    public static final String ANNOT_COL_SET[] = new String[]{COL_ANNOVAR_ENSEMBL_GENE_ID,
                                                                            COL_ANNOVAR_REFSEQ_GENE_ID,
                                                                            COL_SNEFF_ENSEMBL_GENE_ID,
                                                                            COL_SNEFF_REFSEQ_GENE_ID,
                                                                            COL_VEP_ENSEMBL_GENE_ID,
                                                                            COL_VEP_REFSEQ_GENE_ID};
                                                                            //COL_ANNOVAR_CLOSEST_ENSEMBL_GENE_ID,
                                                                            //COL_ANNOVAR_CLOSEST_REFSEQ_GENE_ID};
    
    public static final String PREFIX_COL_FLANKING = "flanking_";
    public static final String SUFFIX_FLANKING_REGION = "_flanking_region";
    public static final String MID_COL_FLANKING = "_";

    public static final String PREFIX_LABEL_ANNOVAR_ENSEMBL_GENE_ID = "ANNOVAR_ensembl_";
    public static final String PREFIX_LABEL_ANNOVAR_REFSEQ_GENE_ID = "ANNOVAR_refseq_";
    public static final String PREFIX_LABEL_SNEFF_ENSEMBL_GENE_ID = "SnpEff_ensembl_";
    public static final String PREFIX_LABEL_SNEFF_REFSEQ_GENE_ID = "SnpEff_refseq_";    
    public static final String PREFIX_LABEL_VEP_ENSEMBL_GENE_ID = "VEP_ensembl_";
    public static final String PREFIX_LABEL_VEP_REFSEQ_GENE_ID = "VEP_refseq_";    
//    public static final String PREFIX_LABEL_ANNOVAR_CLOSEST_ENSEMBL_GENE_ID = "ANNOVAR_ensembl_Closest_gene_";
//    public static final String PREFIX_LABEL_ANNOVAR_CLOSEST_REFSEQ_GENE_ID = "ANNOVAR_refseq_Closest_gene_";
    
    public static final String PREFIX_LABEL_ADD_ANNOT_SET[] = new String[]{PREFIX_LABEL_ANNOVAR_ENSEMBL_GENE_ID,
                                                                                PREFIX_LABEL_ANNOVAR_REFSEQ_GENE_ID,
                                                                                PREFIX_LABEL_SNEFF_ENSEMBL_GENE_ID,
                                                                                PREFIX_LABEL_SNEFF_REFSEQ_GENE_ID,
                                                                                PREFIX_LABEL_VEP_ENSEMBL_GENE_ID,
                                                                                PREFIX_LABEL_VEP_REFSEQ_GENE_ID};
//                                                                                PREFIX_LABEL_ANNOVAR_CLOSEST_ENSEMBL_GENE_ID,
//                                                                                PREFIX_LABEL_ANNOVAR_CLOSEST_REFSEQ_GENE_ID};
    
    public static final String PREFIX_LABEL_PEREGRINE_ENHANCER_LINKED = "enhancer_linked_";
    public static final String LABEL_PEREGRINE_ENHANCER_LINKED_ASSAY = "enhancer_linked_assay";    
    public static final String LABEL_PEREGRINE_ENHANCER_LINKED_GENES = "enhancer_linked_genes"; 
    public static final String LABEL_PEREGRINE_ENHANCER_LINKED_ENHANCER = "enhancer_linked_enhancer";
    public static final String LABEL_PEREGRINE_MAPPED_ANNOTATIONS = "enhancer_associated_annotations";

    
    public static final String STR_PIPE = "|";
    public static final String DELIM_PANTHER_ID_PARTS = "\\|";
    public static final String VCF_PLACEHOLDER_EMPTY = ".";
    public static final String VCF_NONE_ENTRY = "NONE:NONE(dist=NONE)";
    public static final String VCF_DELIM_ALTERNATE = ",";    

    
  
}
