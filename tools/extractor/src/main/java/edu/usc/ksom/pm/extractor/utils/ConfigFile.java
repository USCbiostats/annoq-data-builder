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

package edu.usc.ksom.pm.extractor.utils;
import java.util.Enumeration;
import java.util.Properties;

public class ConfigFile {
    public static final String KEY_DB_JDBC_URL = "db.jdbc.url";
    public static final String KEY_DB_JDBC_USERNAME = "db.jdbc.username";
    public static final String KEY_DB_JDBC_PASSWORD = "db.jdbc.password";
    public static final String KEY_DB_JDBC_DBSID = "db.jdbc.dbsid";
    public static final String KEY_DB_JDBC_POOL_MINSIZE = "db.connectionpool.minsize";
    public static final String KEY_DB_JDBC_POOL_MAXSIZE = "db.connectionpool.maxsize";


    protected static String[] propertyFiles = {"extractor"};

    public static final String PROPERTY_VERSION_SID_PANTHER = "cls.version.sid.panther";
    public static final String PROPERTY_VERSION_SID_GO = "cls.version.sid.go";
    public static final String PROPERTY_VERSION_SID_REACTOME = "cls.version.sid.reactome";

    protected static Properties m_Properties = System.getProperties();
    protected static ReadResources rr = null;

    static {
        try {
            rr = new ReadResources(propertyFiles);
        } catch (Exception ex) {
            ex.printStackTrace();
            rr = null;
        }
    }

    public static String getProperty(String key) {
        if (rr == null) {
            return OptionConverter.substVars(m_Properties.getProperty(key), m_Properties);
        } else {
            try {
                return OptionConverter.substVars(rr.getKey(key), rr.getBundle());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return null;
        }
    }

    public static Enumeration getProperties() {
        try {
            return rr.getKeys();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

}
