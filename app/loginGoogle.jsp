<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier" %>
<%@ page import="com.google.api.client.googleapis.auth.oauth2.GoogleIdToken" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.google.api.client.http.HttpTransport" %>
<%@ page import="com.google.api.client.json.JsonFactory" %>
<%@ page import="com.google.api.client.json.gson.GsonFactory" %>
<%@ page import="com.google.api.client.http.javanet.NetHttpTransport" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %><%--
  ~ Baseform
  ~ Copyright (C) 2018  Baseform
  ~
  ~ This program is free software: you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation, either version 3 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program.  If not, see <https://www.gnu.org/licenses/>.
  --%>

<%
    String token = request.getParameter("token");
    JSONObject res = new JSONObject();

    GsonFactory jacksonFactory = new GsonFactory();
    NetHttpTransport transport = new NetHttpTransport();

    GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(transport, jacksonFactory)
            .setAudience(Collections.singletonList(request.getSession().getServletContext().getInitParameter("google_id")))
            .build();


    GoogleIdToken idToken = verifier.verify(token);

    if (idToken != null) {
        GoogleIdToken.Payload payload = idToken.getPayload();

        PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
        pm.loginOrCreateFromGoogle(token,payload, request);

        res = new JSONObject().put("success", true);
    }
%><%= res %>