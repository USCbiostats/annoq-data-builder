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
package edu.usc.ksom.pm.extractor.logic;

import edu.usc.ksom.pm.extractor.utils.ConfigFile;
import edu.usc.ksom.pm.extractor.utils.DBConnectionPool;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;


public class CategoryManager {
    public static final String QUERY_PANTHER_CATS = "select c.accession, c.name from classification c\n" +
                                                    "where c.classification_version_sid = %1\n" +
                                                    "and c.obsolescence_date is null";
    
//    public static final String QUERY_PANTHER_PATHWAY = "select pathway_acc accession, pathway_name name from pathwaylist_agg";
    
    
    public static final String QUERY_GO_CATS = "select c.accession, c.name from go_classification c\n" +
                                                "where c.classification_version_sid = %1\n" +
                                                "and c.obsolescence_date is null\n";

    public static final String QUERY_REACTOME = "select c.accession, c.name from reactome_classification c\n" +
                                                "where c.classification_version_sid = %1\n" +
                                                "and c.obsolescence_date is null";
    
    public static final String PARAM_1 = "%1";

    public static final String COLUMN_ACCESSION = "accession";
    public static final String COLUMN_NAME = "name";
    
    public static CategoryManager instance;
    
    private static HashMap<String, String> PANTHER_LOOKUP = initPanther();
//    private static HashMap<String, String> PANTHER_PATHWAY_LOOKUP = initPantherPathway();    
    private static HashMap<String, String> GO_LOOKUP = initGO();
    private static HashMap<String, String> REACTOME_LOOKUP = initReactome();
    
    private CategoryManager() {
        
    }
    
    public static synchronized CategoryManager getInstance() {
        if (null == instance) {
            instance = new CategoryManager();
        }
        return instance;
    }
    
    private static HashMap<String, String> initPanther() {
        Connection con = null;
        Statement stmt = null;
        ResultSet rst = null;
        HashMap<String, String> pantherLookup = new HashMap<String, String>();
        try {
            con = DBConnectionPool.getConnection();
            stmt = con.createStatement();
            String query = QUERY_PANTHER_CATS.replace(PARAM_1, ConfigFile.getProperty(ConfigFile.PROPERTY_VERSION_SID_PANTHER));
            rst = stmt.executeQuery(query);
            while (rst.next()) {
                String acc = rst.getString(COLUMN_ACCESSION);
                String name = rst.getString(COLUMN_NAME);
                if (null != acc && null != name) {
                    pantherLookup.put(acc, name);
                }
            }
        }
        catch(SQLException se) {
            se.printStackTrace();
            pantherLookup.clear();
        }
        finally {
            DBConnectionPool.releaseDBResources(rst, stmt, con);
        }
        return pantherLookup;
    }
            
    
//    private static HashMap<String, String> initPantherPathway() {
//        Connection con = null;
//        Statement stmt = null;
//        ResultSet rst = null;
//        HashMap<String, String> pantherPathwayLookup = new HashMap<String, String>();
//        try {
//            con = DBConnectionPool.getConnection();
//            stmt = con.createStatement();
//            rst = stmt.executeQuery(QUERY_PANTHER_PATHWAY);
//            while (rst.next()) {
//                String acc = rst.getString(COLUMN_ACCESSION);
//                String name = rst.getString(COLUMN_NAME);
//                if (null != acc && null != name) {
//                    pantherPathwayLookup.put(acc, name);
//                }
//            }
//        }
//        catch(SQLException se) {
//            se.printStackTrace();
//            pantherPathwayLookup.clear();
//        }
//        finally {
//            DBConnectionPool.releaseDBResources(rst, stmt, con);
//        }
//        return pantherPathwayLookup;
//    }
    
    
    private static HashMap<String, String> initGO() {
        Connection con = null;
        Statement stmt = null;
        ResultSet rst = null;
        HashMap<String, String> goLookup = new HashMap<String, String>();
        try {
            con = DBConnectionPool.getConnection();
            stmt = con.createStatement();
            String query = QUERY_GO_CATS.replace(PARAM_1, ConfigFile.getProperty(ConfigFile.PROPERTY_VERSION_SID_GO));
            rst = stmt.executeQuery(query);
            while (rst.next()) {
                String acc = rst.getString(COLUMN_ACCESSION);
                String name = rst.getString(COLUMN_NAME);
                if (null != acc && null != name) {
                    goLookup.put(acc, name);
                }
            }
        }
        catch(SQLException se) {
            se.printStackTrace();
            goLookup.clear();
        }
        finally {
            DBConnectionPool.releaseDBResources(rst, stmt, con);
        }
        return goLookup;
    }    


    private static HashMap<String, String> initReactome() {
        Connection con = null;
        Statement stmt = null;
        ResultSet rst = null;
        HashMap<String, String> reactomeLookup = new HashMap<String, String>();
        try {
            con = DBConnectionPool.getConnection();
            stmt = con.createStatement();
            String query = QUERY_REACTOME.replace(PARAM_1, ConfigFile.getProperty(ConfigFile.PROPERTY_VERSION_SID_REACTOME));
            rst = stmt.executeQuery(query);
            while (rst.next()) {
                String acc = rst.getString(COLUMN_ACCESSION);
                String name = rst.getString(COLUMN_NAME);
                if (null != acc && null != name) {
                    reactomeLookup.put(acc, name);
                }
            }
        }
        catch(SQLException se) {
            se.printStackTrace();
            reactomeLookup.clear();
        }
        finally {
            DBConnectionPool.releaseDBResources(rst, stmt, con);
        }
        return reactomeLookup;
    }

    public String getPantherClsName(String acc) {
        if (null == acc) {
            return null;
        }
        return PANTHER_LOOKUP.get(acc);
    }


//    public String getPantherPathwayName(String acc) {
//        if (null == acc) {
//            return null;
//        }
//        return PANTHER_PATHWAY_LOOKUP.get(acc);
//    }

    public String getGOClsName(String acc) {
        if (null == acc) {
            return null;
        }
        return GO_LOOKUP.get(acc);
    }
    
    public String getReactomeClsName(String acc) {
        if (null == acc) {
            return null;
        }
        return REACTOME_LOOKUP.get(acc);
    }    
}
