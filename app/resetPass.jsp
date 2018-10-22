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

<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%
    PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>
<link href="redesign_css/login_hub.css" rel="stylesheet" type="text/css">

<div class="section register afterHeader">
    <div class="grid">
         <form accept-charset="utf-8" method="post" action="?<%=RequestParameters.NEW_PWD%>" id="f" autocomplete="off">
             <h3 class="title"><%=PowerUtils.localizeKey("recover.password", currentLangBundle,frontendDefaultBundle)%></h3>
             <h3 class="subTitle"><%=PowerUtils.localizeKey("recover.password.msg", currentLangBundle,frontendDefaultBundle)%></h3>
            <input type="password" name="<%= RequestParameters.PWD %>" placeholder="<%= PowerUtils.localizeKey("password", currentLangBundle,frontendDefaultBundle) %>">
            <input type="password" name="<%= RequestParameters.PWD2 %>" placeholder="<%= PowerUtils.localizeKey("confirm.password", currentLangBundle,frontendDefaultBundle) %>">
            <input type="hidden" name="ck" value="<%=request.getParameter("ck")%>"/>
            <input type="hidden" name="c" value="<%=request.getParameter("c")%>"/>
            <input type="hidden" name="reload" value="1"/>
             <a class="submit noBorder" onclick="$('#f').submit();"><%=PowerUtils.localizeKey("reset.password", currentLangBundle, frontendDefaultBundle)%> ></a>
        </form>
    </div>
</div>