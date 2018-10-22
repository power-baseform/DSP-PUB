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

import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;

import com.google.api.services.analytics.Analytics;
import com.google.api.services.analytics.AnalyticsScopes;
import com.google.api.services.analytics.model.Accounts;
import com.google.api.services.analytics.model.GaData;
import com.google.api.services.analytics.model.Profiles;
import com.google.api.services.analytics.model.Webproperties;
import javafx.util.Pair;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;


/**
 * A simple example of how to access the Google Analytics API using a service
 * account.
 */
public class HelloAnalytics {

    private static Pair<Date, Integer> cache = null;
    private static final String APPLICATION_NAME = "Hello Analytics";
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static String KEY_FILE_LOCATION = "";
    private static String SERVICE_ACCOUNT_EMAIL = "";
    public static final SimpleDateFormat DATE_FORMAT_GA = new SimpleDateFormat("yyyy-MM-dd");
    private static Pair<Date, List<GaData>> listCache = null;

    public static final String PAGE_VIEWS = "uniquePageviews";
    public static final String UNIQUE_VISITORS = "Users";

    public static Integer init(HttpServletRequest request, String variable) {
        try {
            if (cache == null || cache.getKey().getTime() < (new Date().getTime() - (15l * 60 * 1000))) {
                KEY_FILE_LOCATION = request.getSession().getServletContext().getInitParameter("analytics_key");
                SERVICE_ACCOUNT_EMAIL = request.getSession().getServletContext().getInitParameter("analytics_email");
                String pageviews = (String) request.getSession().getServletContext().getAttribute(variable);
                Date now = new Date();

                if (pageviews != null) {
                    String[] split = pageviews.split(";");
                    Date date = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").parse(split[0]);

                    Calendar c = Calendar.getInstance();
                    c.setTime(date);
                    c.add(Calendar.MINUTE, 15);

                    if (now.after(c.getTime())) {
                        parseAnalytics(request, now, variable);
                    } else {
                        cache = new Pair<>(new Date(), Integer.valueOf(split[1]));
                    }
                } else {
                    parseAnalytics(request, now, variable);
                }
            }
            return cache.getValue();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static void parseAnalytics(HttpServletRequest request, Date now, String variable) throws Exception {
        Analytics analytics = initializeAnalytics(request);
        String profile = getFirstProfileId(analytics);
        String s = printResults(getResults(analytics, profile, variable));
        request.getSession().getServletContext().setAttribute(variable, new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(now) + ";" + s);

        cache = new Pair<>(new Date(), Integer.valueOf(s));
    }

    public static List<GaData> init1(HttpServletRequest request, int months, String variable) {
        try {
            if (listCache == null || listCache.getKey().getTime() < (new Date().getTime() - (15l * 60 * 1000))) {
                KEY_FILE_LOCATION = request.getSession().getServletContext().getInitParameter("analytics_key");
                SERVICE_ACCOUNT_EMAIL = request.getSession().getServletContext().getInitParameter("analytics_email");
                Analytics analytics = initializeAnalytics(request);
                String profile = getFirstProfileId(analytics);
                final List<GaData> results1 = getResults1(analytics, profile, months, variable);
                listCache =  new Pair<>(new Date(), results1);
                return results1;
            }
            return listCache.getValue();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static Analytics initializeAnalytics(HttpServletRequest request) throws Exception {
        // Initializes an authorized analytics service object.

        File fp12 = new File(request.getSession().getServletContext().getRealPath(KEY_FILE_LOCATION));
        // Construct a GoogleCredential object with the service account email
        // and p12 file downloaded from the developer console.
        HttpTransport httpTransport = GoogleNetHttpTransport.newTrustedTransport();
        GoogleCredential credential = new GoogleCredential.Builder()
                .setTransport(httpTransport)
                .setJsonFactory(JSON_FACTORY)
                .setServiceAccountId(SERVICE_ACCOUNT_EMAIL)
                .setServiceAccountPrivateKeyFromP12File(fp12)
                .setServiceAccountScopes(AnalyticsScopes.all())
                .build();

        // Construct the Analytics service object.
        return new Analytics.Builder(httpTransport, JSON_FACTORY, credential)
                .setApplicationName(APPLICATION_NAME).build();
    }


    private static String getFirstProfileId(Analytics analytics) throws IOException {
        // Get the first view (profile) ID for the authorized user.
        String profileId = null;

        // Query for the list of all accounts associated with the service account.
        Accounts accounts = analytics.management().accounts().list().execute();

        if (accounts.getItems().isEmpty()) {
            System.err.println("No accounts found");
        } else {
            String firstAccountId = accounts.getItems().get(0).getId();

            // Query for the list of properties associated with the first account.
            Webproperties properties = analytics.management().webproperties()
                    .list(firstAccountId).execute();

            if (properties.getItems().isEmpty()) {
                System.err.println("No Webproperties found");
            } else {
                String firstWebpropertyId = properties.getItems().get(0).getId();

                // Query for the list views (profiles) associated with the property.
                Profiles profiles = analytics.management().profiles()
                        .list(firstAccountId, firstWebpropertyId).execute();

                if (profiles.getItems().isEmpty()) {
                    System.err.println("No views (profiles) found");
                } else {
                    // Return the first (view) profile associated with the property.
                    profileId = profiles.getItems().get(0).getId();
                }
            }
        }
        return profileId;
    }

    private static GaData getResults(Analytics analytics, String profileId, String variable) throws IOException {
        // Query the Core Reporting API for the number of sessions
        return analytics.data().ga()
                .get("ga:" + profileId, "2015-06-01", DATE_FORMAT_GA.format(new Date()), "ga:"+ variable)
                .execute();
    }

    private static List<GaData> getResults1(Analytics analytics, String profileId, int semanas, String variable) throws IOException {
        // Query the Core Reporting API for the number of sessions
        List<GaData> list = new ArrayList<GaData>();
        int k = 7;


        Date now = new Date();
        Calendar c = Calendar.getInstance();
        c.setTime(new Date());

        for (int i = 1; i < semanas + 1; i++) {

            int i1 = c.get(Calendar.DAY_OF_MONTH);
            int i2 = i1 - k;
            c.set(Calendar.DAY_OF_MONTH, i2);
            list.add(analytics.data().ga()
                    .get("ga:" + profileId, DATE_FORMAT_GA.format(c.getTime()), DATE_FORMAT_GA.format(now), "ga:"+ variable)
                    .execute());

            now = c.getTime();
        }

        return list;
    }

    private static String printResults(GaData results) {

        if (results != null && !results.getRows().isEmpty()) {
            return results.getRows().get(0).get(0);
        } else {
            return "N/A";
        }

    }
}
