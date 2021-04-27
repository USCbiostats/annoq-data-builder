/**
 * Copyright 2021 University Of Southern California
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package edu.usc.ksom.pm.extractor.annotation;

import edu.usc.ksom.pm.extractor.dataModel.Gene;
import edu.usc.ksom.pm.extractor.logic.CategoryManager;
import edu.usc.ksom.pm.extractor.utils.DBConnectionPool;
import java.io.IOException;
import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map.Entry;
import java.util.regex.Pattern;
import org.apache.log4j.Logger;
import org.json.JSONObject;

public class GeneExtractor {

    private String directory;
    private String species;

    public static final String QUERY_GENE = "select gene_ext_acc, panther_mf, panther_bp, panther_cc, panther_pc, pathway, fullgo_mf_comp,  fullgo_bp_comp, fullgo_cc_comp, reactome from panther.genelist_agg  \n"
            + "where species like '%1';";

    public static final String PARAM_1 = "%1";

    public static final String COLUMN_GENE_EXT_ACC = "gene_ext_acc";
    public static final String COLUMN_PANTHER_MF = "panther_mf";
    public static final String COLUMN_PANTHER_BP = "panther_bp";
    public static final String COLUMN_PANTHER_CC = "panther_cc";
    public static final String COLUMN_PANTHER_PC = "panther_pc";
    public static final String COLUMN_PANTHER_PATHWAY = "pathway";
    public static final String COLUMN_FULL_GO_MF = "fullgo_mf_comp";
    public static final String COLUMN_FULL_GO_BP = "fullgo_bp_comp";
    public static final String COLUMN_FULL_GO_CC = "fullgo_cc_comp";
    public static final String COLUMN_REACTOME = "reactome";

    public static final String DELIM_LONG_ID = Pattern.quote("|");
    public static final int INDEX_GENE_PART = 2;
    public static final String DELIM_GENE_PART = Pattern.quote("=");
    public static final int NUM_GENE_PARTS = 2;
    public static final String FORMATTED_GENE_DELIM = ":";

    public static final String DELIM_PANTHER_CAT = Pattern.quote(";");
    public static final String DELIM_PANTHER_CAT_PARTS = Pattern.quote(",");
    public static final String DELIM_CATS = Pattern.quote(",");
    public static final String DELIM_PATHWAY = Pattern.quote(";");
    public static final String SEPARATOR_PATHWAY_COMP = ">";
    public static final String DELIM_PATHWAY_PARTS = Pattern.quote("#");
    public static final int NUM_PATHWAY_PARTS = 3;

    public static CategoryManager CM = CategoryManager.getInstance();

    public static final String STR_EMPTY = "";
    public static final String DELIM_FIELDS = "|";
    public static final String WRAPPER_FIELDS = "\"";

    public static final String FILE_SEPARATOR = "/";
    public static final String FILE_NAME_GENES = "genes.json";

    public static final String JSON_COLS = "cols";
    public static final String JSON_DATA = "data";
    public static final String JSON_PANTHER_ID = "panther_id";
    public static final String JSON_GO_MF_LIST = "GO_molecular_function_complete_list";
    public static final String JSON_GO_MF_LIST_ID = "GO_molecular_function_complete_list_id";
    public static final String JSON_GO_BP_LIST = "GO_biological_process_complete_list";
    public static final String JSON_GO_BP_LIST_ID = "GO_biological_process_complete_list_id";
    public static final String JSON_GO_CC_LIST = "GO_cellular_component_complete_list";
    public static final String JSON_GO_CC_LIST_ID = "GO_cellular_component_complete_list_id";
    public static final String JSON_PANTHER_MF_LIST = "PANTHER_GO_SLIM_molecular_function_list";
    public static final String JSON_PANTHER_MF_LIST_ID = "PANTHER_GO_SLIM_molecular_function_list_id";
    public static final String JSON_PANTHER_BP_LIST = "PANTHER_GO_SLIM_biological_process_list";
    public static final String JSON_PANTHER_BP_LIST_ID = "PANTHER_GO_SLIM_biological_process_list_id";
    public static final String JSON_PANTHER_CC_LIST = "PANTHER_GO_SLIM_cellular_component_list";
    public static final String JSON_PANTHER_CC_LIST_ID = "PANTHER_GO_SLIM_cellular_component_list_id";
    public static final String JSON_PANTHER_PC_LIST = "PANTHER_GO_SLIM_protein_class_list";
    public static final String JSON_PANTHER_PC_LIST_ID = "PANTHER_GO_SLIM_protein_class_list_id";
    public static final String JSON_REACTOME_LIST = "REACTOME_pathway_list";
    public static final String JSON_REACTOME_LIST_ID = "REACTOME_pathway_list_id";
    public static final String JSON_PATHWAY_LIST = "PANTHER_pathway_list";
    public static final String JSON_PATHWAY_LIST_ID = "PANTHER_pathway_list_id";

    public GeneExtractor(String directory, String species) {
        this.directory = directory;
        this.species = species;

        Connection con = null;
        Statement stmt = null;
        ResultSet rst = null;
        ArrayList<Gene> genes = new ArrayList<Gene>();
        try {
            con = DBConnectionPool.getConnection();
            stmt = con.createStatement();
            String query = QUERY_GENE.replace(PARAM_1, species);
            rst = stmt.executeQuery(query);
            while (rst.next()) {
                String longId = rst.getString(COLUMN_GENE_EXT_ACC);
                if (null == longId) {
                    continue;
                }
                String formattedId = convertLongId(longId);
                if (null == formattedId) {
                    continue;
                }
                String mf = rst.getString(COLUMN_PANTHER_MF);
                String bp = rst.getString(COLUMN_PANTHER_BP);
                String cc = rst.getString(COLUMN_PANTHER_CC);
                String pc = rst.getString(COLUMN_PANTHER_PC);
                String pathway = rst.getString(COLUMN_PANTHER_PATHWAY);
                String goMf = rst.getString(COLUMN_FULL_GO_MF);
                String goBp = rst.getString(COLUMN_FULL_GO_BP);
                String goCc = rst.getString(COLUMN_FULL_GO_CC);
                String reactome = rst.getString(COLUMN_REACTOME);
                Gene g = new Gene();
                genes.add(g);
                g.setId(formattedId);
                StringBuffer idBuf = new StringBuffer();
                StringBuffer nameBuf = new StringBuffer();
                formatPanther(mf, idBuf, nameBuf);
                g.setPantherMfId(idBuf.toString());
                g.setPantherMf(nameBuf.toString());
                formatPanther(bp, idBuf, nameBuf);
                g.setPantherBpId(idBuf.toString());
                g.setPantherBp(nameBuf.toString());
                formatPanther(cc, idBuf, nameBuf);
                g.setPantherCcId(idBuf.toString());
                g.setPantherCc(nameBuf.toString());
                formatPanther(pc, idBuf, nameBuf);
                g.setPantherPcId(idBuf.toString());
                g.setPantherPc(nameBuf.toString());

                formatPantherPathway(pathway, idBuf, nameBuf);
                g.setPantherPathwayId(idBuf.toString());
                g.setPantherPathway(nameBuf.toString());

                formatGO(goMf, idBuf, nameBuf);
                g.setGoMfId(idBuf.toString());
                g.setGoMf(nameBuf.toString());
                formatGO(goBp, idBuf, nameBuf);
                g.setGoBpId(idBuf.toString());
                g.setGoBp(nameBuf.toString());
                formatGO(goCc, idBuf, nameBuf);
                g.setGoCcId(idBuf.toString());
                g.setGoCc(nameBuf.toString());

                formatReactome(reactome, idBuf, nameBuf);
                g.setReactomeId(idBuf.toString());
                g.setReactome(nameBuf.toString());
            }
            if (false == saveGenes(genes)) {
                System.out.println("Unable to retrieve gene information, refer to error log\n");
            }
        } catch (SQLException se) {
            se.printStackTrace();
        } finally {
            DBConnectionPool.releaseDBResources(rst, stmt, con);
        }
    }

    public static String convertLongId(String longId) {
        if (null == longId) {
            return null;
        }
        String parts[] = longId.split(DELIM_LONG_ID);
        if (parts.length < INDEX_GENE_PART) {
            return null;
        }
        String genePart = parts[INDEX_GENE_PART - 1];
        String gParts[] = genePart.split(DELIM_GENE_PART);
        if (2 != gParts.length) {
            return null;
        }
        return gParts[0] + FORMATTED_GENE_DELIM + gParts[1];
    }

    public void formatPanther(String catStr, StringBuffer formatCatStr, StringBuffer formatCatName) {
        if (null != catStr && 0 != catStr.length()) {
            catStr = catStr.trim();
            String allParts[] = catStr.split(DELIM_PANTHER_CAT);
            HashSet<String> uniqueParts = new HashSet<String>();        // Need to handle duplicates
            for (int i = 0; i < allParts.length; i++) {
                String catParts[] = allParts[i].split(DELIM_PANTHER_CAT_PARTS);
//                if (catParts.length > 1) {
//                    System.out.println("Here");
//                }
                uniqueParts.add(catParts[catParts.length - 1]);
            }
            String parts[] = new String[uniqueParts.size()];
            String names[] = new String[parts.length];
            int count = 0;
            for (String part : uniqueParts) {
                parts[count] = part;
                names[count] = CM.getPantherClsName(parts[count]);
                if (null == names[count]) {
                    names[count] = STR_EMPTY;
                }
                count++;
            }
            formatCatStr.setLength(0);
            if (0 != parts.length) {
                formatCatStr.append(String.join(DELIM_FIELDS, parts));
            }

            formatCatName.setLength(0);
            if (0 != names.length) {
                formatCatName.append(String.join(DELIM_FIELDS, names));
            }
        } else {
            formatCatStr.setLength(0);
            formatCatName.setLength(0);
        }
//        formatCatStr.insert(0, WRAPPER_FIELDS);
//        formatCatStr.append(WRAPPER_FIELDS);
//        formatCatName.insert(0, WRAPPER_FIELDS);
//        formatCatName.append(WRAPPER_FIELDS);
    }

    public void formatGO(String catStr, StringBuffer formatCatStr, StringBuffer formatCatName) {
        if (null != catStr && 0 != catStr.length()) {
            catStr = catStr.trim();
            String parts[] = catStr.split(DELIM_CATS);
            String names[] = new String[parts.length];
            for (int i = 0; i < parts.length; i++) {
                names[i] = CM.getGOClsName(parts[i]);
                if (null == names[i]) {
                    names[i] = STR_EMPTY;
                }
            }
            formatCatStr.setLength(0);
            if (0 != parts.length) {
                formatCatStr.append(String.join(DELIM_FIELDS, parts));
            }

            formatCatName.setLength(0);
            if (0 != names.length) {
                formatCatName.append(String.join(DELIM_FIELDS, names));
            }
        } else {
            formatCatStr.setLength(0);
            formatCatName.setLength(0);
        }
//        formatCatStr.insert(0, WRAPPER_FIELDS);
//        formatCatStr.append(WRAPPER_FIELDS);
//        formatCatName.insert(0, WRAPPER_FIELDS);
//        formatCatName.append(WRAPPER_FIELDS);
    }

    public void formatReactome(String catStr, StringBuffer formatCatStr, StringBuffer formatCatName) {
        if (null != catStr && 0 != catStr.length()) {
            catStr = catStr.trim();
            String parts[] = catStr.split(DELIM_CATS);
            String names[] = new String[parts.length];
            for (int i = 0; i < parts.length; i++) {
                names[i] = CM.getReactomeClsName(parts[i]);
                if (null == names[i]) {
                    names[i] = STR_EMPTY;
                }
            }
            formatCatStr.setLength(0);
            if (0 != parts.length) {
                formatCatStr.append(String.join(DELIM_FIELDS, parts));
            }

            formatCatName.setLength(0);
            if (0 != names.length) {
                formatCatName.append(String.join(DELIM_FIELDS, names));
            }
        } else {
            formatCatStr.setLength(0);
            formatCatName.setLength(0);
        }
//        formatCatStr.insert(0, WRAPPER_FIELDS);
//        formatCatStr.append(WRAPPER_FIELDS);
//        formatCatName.insert(0, WRAPPER_FIELDS);
//        formatCatName.append(WRAPPER_FIELDS);
    }

    public void formatPantherPathway(String catStr, StringBuffer formatCatStr, StringBuffer formatCatName) {
        if (null != catStr && 0 != catStr.length()) {
            catStr = catStr.trim();
            HashMap<String, String> pathwayLookup = new HashMap<String, String>();  // Need to handle duplicates
            String allParts[] = catStr.split(DELIM_PATHWAY);
            for (int i = 0; i < allParts.length; i++) {
//                int index = parts[i].indexOf(SEPARATOR_PATHWAY_COMP);
                String info = allParts[i].substring(0, allParts[i].indexOf(SEPARATOR_PATHWAY_COMP));
                String infoParts[] = info.split(DELIM_PATHWAY_PARTS);
                if (NUM_PATHWAY_PARTS != infoParts.length) {
                    continue;
                }
                pathwayLookup.put(infoParts[NUM_PATHWAY_PARTS - 1], infoParts[0]);
            }
            String parts[] = new String[pathwayLookup.size()];
            String names[] = new String[parts.length];
            int counter = 0;
            for (Entry<String, String> pathEntry : pathwayLookup.entrySet()) {
                parts[counter] = pathEntry.getKey();
                names[counter] = pathEntry.getValue();
                counter++;
            }
            formatCatStr.setLength(0);
            if (0 != parts.length) {
                formatCatStr.append(String.join(DELIM_FIELDS, parts));
            }

            formatCatName.setLength(0);
            if (0 != names.length) {
                formatCatName.append(String.join(DELIM_FIELDS, names));
            }
        } else {
            formatCatStr.setLength(0);
            formatCatName.setLength(0);
        }
//        formatCatStr.insert(0, WRAPPER_FIELDS);
//        formatCatStr.append(WRAPPER_FIELDS);
//        formatCatName.insert(0, WRAPPER_FIELDS);
//        formatCatName.append(WRAPPER_FIELDS);
    }

    public JSONObject convertGenesToJson(ArrayList<Gene> genes) {
        if (null == genes) {
            return null;
        }
        // Convert the genes into a JSON object
        // First add the columns
        JSONObject jo = OrderedJSONObjectFactory.create();
        ArrayList<String> cols = new ArrayList<String>(Arrays.asList(JSON_PANTHER_ID,
                JSON_GO_MF_LIST,
                JSON_GO_MF_LIST_ID,
                JSON_GO_BP_LIST,
                JSON_GO_BP_LIST_ID,
                JSON_GO_CC_LIST,
                JSON_GO_CC_LIST_ID,
                JSON_PANTHER_MF_LIST,
                JSON_PANTHER_MF_LIST_ID,
                JSON_PANTHER_BP_LIST,
                JSON_PANTHER_BP_LIST_ID,
                JSON_PANTHER_CC_LIST,
                JSON_PANTHER_CC_LIST_ID,
                JSON_PANTHER_PC_LIST,
                JSON_PANTHER_PC_LIST_ID,
                JSON_REACTOME_LIST,
                JSON_REACTOME_LIST_ID,
                JSON_PATHWAY_LIST,
                JSON_PATHWAY_LIST_ID));
//        colArray.put(cols);
        jo.put(JSON_COLS, cols);
        JSONObject data = OrderedJSONObjectFactory.create();
        
        // Now add the data
        jo.put(JSON_DATA, data);
        for (Gene g : genes) {
            ArrayList<String> values = new ArrayList<String>(Arrays.asList(g.getGoMf(),
                    g.getGoMfId(),
                    g.getGoBp(),
                    g.getGoBpId(),
                    g.getGoCc(),
                    g.getGoCcId(),
                    g.getPantherMf(),
                    g.getPantherMfId(),
                    g.getPantherBp(),
                    g.getPantherBpId(),
                    g.getPantherCc(),
                    g.getPantherCcId(),
                    g.getPantherPc(),
                    g.getPantherPcId(),
                    g.getReactome(),
                    g.getReactomeId(),
                    g.getPantherPathway(),
                    g.getPantherPathwayId()));
            data.put(g.getId(), values);
        }
//        JSONArray colArray = new JSONArray();

        return jo;
    }

    public boolean saveGenes(ArrayList<Gene> genes) {
        JSONObject jsonObj = convertGenesToJson(genes);
        if (null == jsonObj) {
            return false;
        }

        try {
            Path geneFile = Paths.get(directory + FILE_SEPARATOR + FILE_NAME_GENES);
            Path curFile = geneFile;
            if (false == Files.exists(geneFile)) {
                if (false == Files.exists(geneFile.getParent())) {
                    Files.createDirectories(geneFile.getParent());
                }
                curFile = Files.createFile(geneFile);
            } else {
                ArrayList<String> fileInfo = new ArrayList<String>();
                Files.write(curFile, fileInfo, StandardCharsets.UTF_8);
            }
            ArrayList<String> geneInfoList = new ArrayList<String>();
            geneInfoList.add(jsonObj.toString(4));
            Files.write(curFile, geneInfoList, StandardCharsets.UTF_8);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static void main(String args[]) {
        System.out.println("This module requires 2 parameters: first is the directory name (in unix format) to store the output and second is the species.\nFor example GeneExtractor(\"C:/temp\", \"Homo sapiens\")");
//        if (null == args || 2 != args.length) {
//            System.out.println("Please specify the correct number of parameters");
//            return;
//        }
         //new GeneExtractor("C:/Temp/test/", "Homo sapiens");
        new GeneExtractor(args[0], args[1]);
    }

    // From https://stackoverflow.com/questions/3948206/json-order-mixed-up and user (https://stackoverflow.com/users/387623/unixshadow) to preserve order of json fields
    private static class OrderedJSONObjectFactory {
        private static Logger log = Logger.getLogger(OrderedJSONObjectFactory.class.getName());
        private static boolean setupDone = false;
        private static Field JSONObjectMapField = null;

        private static void setupFieldAccessor() {
            if (!setupDone) {
                setupDone = true;
                try {
                    JSONObjectMapField = JSONObject.class.getDeclaredField("map");
                    JSONObjectMapField.setAccessible(true);
                } catch (NoSuchFieldException ignored) {
                    log.warn("JSONObject implementation has changed, returning unmodified instance");
                }
            }
        }

        private static JSONObject create() {
            setupFieldAccessor();
            JSONObject result = new JSONObject();
            try {
                if (JSONObjectMapField != null) {
                    JSONObjectMapField.set(result, new LinkedHashMap<>());
                }
            } catch (IllegalAccessException ignored) {
            }
            return result;
        }
    }
}
