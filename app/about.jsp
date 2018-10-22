<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.processo.SiteTab" %>
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
    List<SiteTab> siteTabs = pm.getSiteTabsByLocale(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>
<link href="redesign_css/main.css" rel="stylesheet" type="text/css">
<link href="redesign_css/issue.css" rel="stylesheet" type="text/css">
<link href="redesign_css/htmlEditor.css" rel="stylesheet" type="text/css">
<div class="section issueArea about afterHeader">
    <div class="grid">
        <div class="intro title">
            <a href="#" class="hamburger showMenu"></a><!--
            --><h3 class="title <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("about", currentLangBundle, frontendDefaultBundle, true)%></h3>
            <div class="mobileMenu">
                <ul class="tabs"><!--
                    <%
                        if(siteTabs.size()>1){
                            for (SiteTab tab : siteTabs) {
                    %>
                    --><li class="tab"><a href="#<%= tab.getId()%>" class="<%= pm.isRtl() %>"><%= tab.getTitle() %></a></li><!--
                    <%
                            }
                        }
                    %>-->
                </ul>
            </div>
        </div>
        <div class="content">
            <%if(siteTabs.isEmpty()) {%>
            <div class="section maintenance <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("msg.section.under.maintenance",currentLangBundle, frontendDefaultBundle)%></div>
            <%}%>
            <div class="contentPartial side menu">
                <ul class="tabs">
                    <%
                        if(siteTabs.size()>1){
                            for(SiteTab tab : siteTabs){
                    %>
                    <li class="tab <%= pm.isRtl() %>"><a href="#<%= tab.getId()%>"><%= tab.getTitle() %></a></li>
                    <%
                            }
                        }
                    %>
                </ul>
            </div><!--
            --><div class="contentPartial mainContent">
            <% for(SiteTab tab : siteTabs){%>
            <div id="<%= tab.getId()%>" class="tabContent">
                <%
                    if(siteTabs.size()>1){
                %>
                <div class="title <%= pm.isRtl() %>"><%= tab.getTitle()%></div>
                <%
                    }
                %>
                <div class="HTMLContent <%= pm.isRtl() %>">
                    <%= tab.getBody()%>
                </div>
            </div>
            <% } %>
        </div>
        </div>
    </div>
</div>



<script type="text/javascript">
    POWERController.initTabs(".tab", "active");
    POWERController.initScrollTitle(".intro.title");
    POWERController.initStickyMenuSingle(".menu .tabs");
    POWERController.initScrollTab(".menu .tabs", ".tab", "active");
    POWERController.initMobileMenu(".showMenu", ".mobileMenu", "active");
</script>
