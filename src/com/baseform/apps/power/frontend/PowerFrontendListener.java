/*
 * Baseform
 * Copyright (C) 2018  Baseform
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.baseform.apps.power.frontend;

import com.baseform.apps.power.PowerUtils;
import org.postgresql.ds.PGSimpleDataSource;
import org.vibur.dbcp.ViburDBCPDataSource;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.sql.DataSource;

/**
 * Created by joaofeio on 06/02/17.
 */
public class PowerFrontendListener implements ServletContextListener {

    public static final String JNDI_DB_NAME = "jdbc_baseform";
    public static String SERVER_HREF = null;



    @Override
    public void contextInitialized(final ServletContextEvent sce) {
        final ServletContext context = sce.getServletContext();
        PowerUtils.SERVER_HREF = SERVER_HREF = context.getInitParameter("server_href");

        createDS(context);

        PowerUtils.setDebug(Boolean.TRUE.toString().equalsIgnoreCase(context.getInitParameter("main_debug")));
    }


    @Override
    public void contextDestroyed(ServletContextEvent sce) {
       
    }





    private ViburDBCPDataSource getViburPoolDataSource(String dbUrl, String dbUser, String dbPass, String appName, int maxTotalConnections, boolean readOnly, String dsName) {
        final PGSimpleDataSource ds = new PGSimpleDataSource();
        ds.setUrl(dbUrl);
        ds.setUser(dbUser);
        ds.setPassword(dbPass);
        if(appName!=null)
            ds.setApplicationName(appName.replace("http://","").replace("https://",""));
        ds.setReadOnly(readOnly);

        if(PowerUtils.isOnDebug())
            try {
                ds.setLogWriter(new PowerUtils.LogWriter(PowerUtils.LOG_MODE.DEBUG,org.postgresql.ds.PGSimpleDataSource.class));
            } catch (Exception e) { PowerUtils.logErr(e,getClass()); }


        final ViburDBCPDataSource vds = new ViburDBCPDataSource();
        vds.setExternalDataSource(ds);
        vds.setName(dsName);


        final int maxConns = Math.max(maxTotalConnections, 1);
        vds.setPoolMaxSize(maxConns); //max connections to the database
        vds.setPoolInitialSize(0); //min connections to keep open

        vds.setLoginTimeoutInSeconds(60); // Connection timeout of 1 minute
        vds.setTestConnectionQuery("select now();");

        vds.start();

        return vds;
    }

    public void createDS(ServletContext servletContext) {
        try {
            closeDangling(JNDI_DB_NAME);

            final String databaseServerURL = servletContext.getInitParameter("databaseServerURL");
            final String databaseName = servletContext.getInitParameter("databaseName");
            final String url = "jdbc:postgresql://" + databaseServerURL + "/" + databaseName;

            final int maxTotal = servletContext.getInitParameter("databaseMaxConns") != null ? Integer.parseInt(servletContext.getInitParameter("databaseMaxConns")) : 15;
            final ViburDBCPDataSource pool = getViburPoolDataSource(
                    url,
                    servletContext.getInitParameter("databaseUsername"),
                    servletContext.getInitParameter("databasePassword"),
                    servletContext.getInitParameter("server_href")!=null && !servletContext.getInitParameter("server_href").trim().isEmpty() ? servletContext.getInitParameter("server_href") : null,
                    maxTotal,
                    false,
                    databaseName
            );
            PowerUtils.logInfo("Will connect to database using url: "+url, getClass());

            createConnectionFromDS(pool);
            initializeEPSGDb(servletContext);
            PowerUtils.logDebug("Created Postgres data source.", getClass());
        } catch (NamingException e) { throw new IllegalStateException(e); }
    }

    protected final void createConnectionFromDS(DataSource ds) throws NamingException {
        final Context ctx = new InitialContext();
        try {
            ctx.bind(JNDI_DB_NAME, ds);
        } catch (NamingException e) {
            PowerUtils.logErr(e,getClass());
        }
        try {
            try {
                ctx.lookup("java:comp/env");
            } catch (NamingException e) {
                ctx.createSubcontext("java:comp/env");
            }
            ctx.bind("java:comp/env/" + JNDI_DB_NAME, ds);
        } catch (NamingException e) {
            PowerUtils.logErr(e,getClass());
        }
    }

    private void initializeEPSGDb(ServletContext servletContext) throws NamingException {
        closeDangling("EPSG");

        final String databaseServerURL_EPSG = servletContext.getInitParameter("databaseServerURL_EPSG");
        final String databaseName_EPSG = servletContext.getInitParameter("databaseName_EPSG");
        final String url_EPSG = "jdbc:postgresql://" + databaseServerURL_EPSG + "/" + databaseName_EPSG+"?stringtype=unspecified";

        final int maxTotal = servletContext.getInitParameter("databaseMaxConns_EPSG") != null ? Integer.parseInt(servletContext.getInitParameter("databaseMaxConns_EPSG")) : 3;
        final ViburDBCPDataSource pool = getViburPoolDataSource(
                url_EPSG,
                servletContext.getInitParameter("databaseUsername_EPSG"),
                servletContext.getInitParameter("databasePassword_EPSG"),
                servletContext.getInitParameter("server_href")!=null && !servletContext.getInitParameter("server_href").trim().isEmpty() ? servletContext.getInitParameter("server_href") : null,
                maxTotal,
                true,
                databaseName_EPSG
        );
        PowerUtils.logInfo("Will connect to EPSG database using url: "+url_EPSG, getClass());


        final Context ctx = new InitialContext();
        try {
            ctx.bind("EPSG", pool);
        } catch (NamingException e) { PowerUtils.logErr(e,getClass()); }
        try {
            try {
                ctx.lookup("java:comp/env/jdbc");
            } catch (NamingException e) {
                ctx.createSubcontext("java:comp/env/jdbc");
            }
            ctx.bind("java:comp/env/jdbc/" + "EPSG", pool);
            PowerUtils.logDebug("Created Postgres EPSG data source.", getClass());
        } catch (NamingException e) { PowerUtils.logErr(e,getClass()); }
    }


    private void closeDangling(String jndiName) throws NamingException {
        try {
            final Context ctx = new InitialContext();

            Object dsFromCtx = null ;
            try{dsFromCtx = ctx.lookup(jndiName);}catch (Exception ignored){}

            if (dsFromCtx != null && dsFromCtx instanceof ViburDBCPDataSource) {
                final String name = ((ViburDBCPDataSource) dsFromCtx).getName();
                ((ViburDBCPDataSource) dsFromCtx).close();
                PowerUtils.logInfo("Closed a dangling data source: "+ name, getClass());
            }

            try {
                ctx.unbind(jndiName);
                ctx.unbind("java:comp/env/" + jndiName);
                ctx.unbind("java:comp/env/jdbc/" + jndiName);
            }catch (Exception ignored){}
        }catch (Exception e){PowerUtils.logErr(e,getClass());}
    }
}
