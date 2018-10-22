<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.URLConnection" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %><%--
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
    String params = request.getParameter("params");
    JSONObject paramsObj = new JSONObject(params);
    JSONObject authResponse = paramsObj.getJSONObject("authResponse");

    URL url = new URL("https://graph.facebook.com/me?fields=id,name,email&access_token=" + authResponse.getString("accessToken"));
    URLConnection urlConnection = url.openConnection();
    InputStream res = urlConnection.getInputStream();
    BufferedReader bR = new BufferedReader(  new InputStreamReader(res));
    String line = "";

    StringBuilder responseStrBuilder = new StringBuilder();
    while((line =  bR.readLine()) != null){

        responseStrBuilder.append(line);
    }
    res.close();

    JSONObject result = new JSONObject(responseStrBuilder.toString());
    if (result.has("error")) return;

    PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    pm.loginOrCreateFromFacebook(authResponse.getString("accessToken"),result, request);
%><%!

%>