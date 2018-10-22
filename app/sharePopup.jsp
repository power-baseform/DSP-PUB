<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ taglib prefix="tags" tagdir="/WEB-INF/tags" %>
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
    Processo processo = pm.getProcess();
    String hub_url = request.getServletContext().getInitParameter("server_href");

    final ResourceBundle _frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle _currentLangBundle = pm.getCurrentLangBundle();

    String s = Long.toHexString(Double.doubleToLongBits(Math.random()));
%>
<ul class="social" data-id="<%= s %>">
    <li class="facebook" title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_FACEBOOK%>"/>"><jsp:include page="redesign_images/share_fb.svg" /></li>
    <li class="google" title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_GOOGLE%>"/>"><jsp:include page="redesign_images/share_google.svg" /></li>
    <li class="twitter" title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_TWITTER%>"/>"><jsp:include page="redesign_images/share_twitter.svg" /></li>
    <li class="email" title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_EMAIL%>"/>"><jsp:include page="redesign_images/share_mail.svg" /></li>
</ul>
<script>
    var social = new PowerSocial("<%= s %>", "<%= hub_url %>", "<%=request.getSession().getServletContext().getInitParameter("deployment_name")%>",
    "<%=config.getServletContext().getInitParameter("server_href")%>" + '/thumb?size=med&id=' + "<%=processo.getThumbnail()!=null?DataObjectUtils.pkForObject(processo.getThumbnail()):""%>");
    POWERController.initShare(social);
</script>
