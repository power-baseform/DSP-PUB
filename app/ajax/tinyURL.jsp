<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %><%--
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
    final HttpURLConnection conn = (java.net.HttpURLConnection) new URL("http://tinyurl.com/api-create.php?url=" + request.getParameter("url")).openConnection();
    conn.setRequestMethod("GET");
    conn.setInstanceFollowRedirects(false);
    conn.setConnectTimeout(20 * 1000); //20secs timeout
    if (conn.getResponseCode() == java.net.HttpURLConnection.HTTP_OK) {
        final String tinyURL = IOUtils.toString(conn.getInputStream(), "UTF-8");
        out.print(tinyURL);
    }
%>

