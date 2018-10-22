<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%--
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
    final PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>
<link href="redesign_css/main.css" rel="stylesheet" type="text/css">
<link href="redesign_css/issue.css" rel="stylesheet" type="text/css">

<div class="section issueArea afterHeader">
    <div class="grid">
        <div class="intro title">
            <h3 class="title"><%=PowerUtils.localizeKey("account.activation", currentLangBundle, frontendDefaultBundle)%></h3>
        </div>
        <div class="section maintenance">
            <%=PowerUtils.localizeKey("activate.msg", currentLangBundle, frontendDefaultBundle)%>
        </div>
    </div>
</div>