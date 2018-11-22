<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>
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
    PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    DateFormat df = new SimpleDateFormat("dd MMM. yyyy", Locale.US);
    List<Processo> list = pm.getIssueList(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>

<script type="text/javascript" src="js/charts_js/Chart.js"></script>
<link href="redesign_css/challenges.css" rel="stylesheet" type="text/css">

<div class="section challenges afterHeader">
    <div class="grid freeGrow">
        <h3 class="challengesTitle"><%=PowerUtils.localizeKey("challenges",currentLangBundle,frontendDefaultBundle)%></h3>

        <div class="challengesGrid"><!--
            <% for (Processo challenge : list) { %>
            --><a href="./?location=challenge&loadP=<%=challenge.getId()%>" class="challenge">
            <div class="challengeImage" style="background-image: url('<%=challenge.getThumbnail() != null ? "thumb?size=small&id="+challenge.getThumbnail().getId():"/redesign_images/imgMap.jpg"%>');"></div><!--
                    --><div class="challengeDescription">
            <%= challenge.getTitulo() %>
            <%--<p class="challengeDate">Discuss until <span class="date"><%= df.format(challenge.getDataFim()) %></span></p>--%>
        </div>
        </a><!--
            <% } %>
        --></div>
    </div>
</div>