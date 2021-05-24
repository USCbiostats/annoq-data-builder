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

import java.sql.*;
import org.apache.commons.dbcp.BasicDataSource;
import org.apache.log4j.Logger;

public class DBConnectionPool {
//  private static OracleConnectionCacheImpl      connCache = null;
//  private static OracleConnectionPoolDataSource dbSource = null;

    private static final String DRIVER_CLASS_NAME = "org.postgresql.Driver";
    private static BasicDataSource dataSource = null;
    private static final String QUERY_VALIDATION = "select 1 from dual";
    public static final Logger LOGGER = Logger.getLogger(DBConnectionPool.class);

    static {
        init();
    }

    private static boolean init() {
        String dbsid = ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_DBSID);
        dataSource = new BasicDataSource();
        dataSource.setDriverClassName(DRIVER_CLASS_NAME);
        dataSource.setUrl(ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_URL + '.' + dbsid));
        dataSource.setUsername(ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_USERNAME + '.' + dbsid));
        dataSource.setPassword(ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_PASSWORD + '.' + dbsid));

        // set pool size
        int poolMin = Integer.parseInt(ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_POOL_MINSIZE));
        int poolMax = Integer.parseInt(ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_POOL_MAXSIZE));
        dataSource.setMaxActive(poolMax);
        dataSource.setMinIdle(poolMin);
        dataSource.setTestOnBorrow(true);
        dataSource.setValidationQuery(QUERY_VALIDATION);
        System.out.println("Database URL: " + ConfigFile.getProperty(ConfigFile.KEY_DB_JDBC_URL + '.' + dbsid));
        return true;
    }

    public static Connection getConnection() throws SQLException {
        Connection con = null;
        try {
            // get the connection from the connection pool.
            // con = connCache.getConnection();
            con = dataSource.getConnection();
        } catch (SQLException e) {
            LOGGER.error("SQLException: " + e.getMessage());
        }
        return con;
    }

    /**
     * Reset the maximum number of connections allowed in the pool
     *
     * @param newPoolMax new value for the maximum number of connection allowed
     * @exception SQLException If a SQL exception occurs
     */
    public static void setMaxLimit(int newPoolMax) throws SQLException {
        //connCache.setMaxLimit(newPoolMax);
        dataSource.setMaxActive(newPoolMax);
    }

    /**
     * Get total no of connections that are being used
     *
     * @return no of active connections
     * @exception SQLException If a SQL exception occurs
     */
    public static int getActiveSize() throws SQLException {
        return dataSource.getNumActive();
//    return connCache.getActiveSize();
    }

//  /**
//   * Get total no of connections in the Cache
//   *
//   * @return no of cached connections
//   * @exception SQLException  If a SQL exception occurs
//   */
//  public static int getCacheSize() throws SQLException{
//  
//    return connCache.getCacheSize();
//  }
    /**
     * Get max limit on Connections.
     *
     * @return maximum no of connections allowed
     * @exception SQLException If a SQL exception occurs
     */
    public static int getMaxLimit() throws SQLException {
        return dataSource.getMaxActive();
//    return connCache.getMaxLimit();
    }

    /**
     * Get min limit on Connections.
     *
     * @return minimum limiton the no of connections.
     * @exception SQLException If a SQL exception occurs
     */
    public static int getMinLimit() throws SQLException {
        return dataSource.getMinIdle();
//    return connCache.getMinLimit();  
    }

    public static BasicDataSource getDbSource() {
        return dataSource;
    }

    public static void closeConnectionPool() {
        if (null == dataSource) {
            return;
        }
        try {
            dataSource.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void releaseDBResources(ResultSet rst, Statement stmt, Connection con) {

        // test and close the resultset
        try {
            if (rst != null) {
                rst.close();
            }
        } catch (SQLException e) {
            LOGGER.error("Error in closing the ResultSet " + e.getMessage());
        }

        // test and close the statement
        try {
            if (stmt != null) {
                stmt.close();
            }
        } catch (Exception e) {
            LOGGER.error("Error in closing the statement " + e.getMessage());
        }

        // test and close the database connection
        try {
            if (con != null) {
                // close the logical connection.
                con.close();
            }
        } catch (SQLException e) {
            LOGGER.error("Error in closing the pooled connection " + e.getMessage());
        }
        rst = null;
        stmt = null;
        con = null;
    }
}
