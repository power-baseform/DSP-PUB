<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.List" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.processo.SiteProps" %>
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
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
    DateFormat df = new SimpleDateFormat("dd MMM. yyyy", Locale.US);
    Participante participante = pm.getParticipante();
    List<Processo> list = pm.getIssueList(request);
    final String currentSystem = pm.getSystemId(request);
    String  registerClass = participante != null ? "hidden" : "" ;
    Boolean showFormBackEnd = PowerUtils.showRegistrationForm(currentSystem, pm.getDc(request)) ? true : false;
    String  gamificationClass = participante == null ? "hidden" : "" ;
    String lineWithChart = participante == null ? "" : "withChart"; %>

<script type="text/javascript" src="js/charts_js/Chart.js"></script>
<link href="redesign_css/main.css" rel="stylesheet" type="text/css">
<link href="redesign_css/challenges.css" rel="stylesheet" type="text/css">
<link href="redesign_css/stats.css" rel="stylesheet" type="text/css">
<link href="redesign_css/community.css" rel="stylesheet" type="text/css">
<link href="redesign_css/htmlEditor.css" rel="stylesheet" type="text/css">

<div class="section home afterHeader  <%= lineWithChart %>" style="background-image: url('/thumb?size=med&slider_img=<%=currentSystem%>&id=<%= PowerUtils.getFrontendImage(null,currentSystem, pm.getDc(request)) %>');">
    <div class="grid">
        <div class="blueOverlay"></div>
        <div class="line <%= lineWithChart %>">
            <div class="column">
                <img data-alternative="img/<%=request.getSession().getServletContext().getInitParameter("deployment_name").replace(" ","%20")%>.png" src="img/<%=request.getSession().getServletContext().getInitParameter("deployment_name")%>.svg" alt="<%=request.getSession().getServletContext().getInitParameter("deployment_name")%>" class="logoImage"/>
                <h3 class="hashtag <%= pm.isRtl() %>"><%= PowerUtils.getTitle(pm.getCurrentLocale(),currentSystem, pm.getDc(request)) %></h3>
                <div class="mainText HTMLContent noClean <%= pm.isRtl() %>">
                    <%= PowerUtils.getIssueListDescription(pm.getCurrentLocale(),pm.getSystemId(request), pm.getDc(request)) %>
                    <a class="learnMore" href="./?location=about"><%=PowerUtils.localizeKey("learn.more",currentLangBundle,frontendDefaultBundle)%></a>
                </div>
                <div class="appPromotion hidden">
                    <p class="appPromotionText"><%=PowerUtils.localizeKey("access.or.download",currentLangBundle,frontendDefaultBundle)%></p>
                    <a target="_blank" href="<%=application.getInitParameter("androidAppLink")%>" class="appStore android"></a>
                    <a href="#" class="appStore ios" title="Available Soon"></a>
                </div>
            </div><!--
        --><div class="column rigthColumn">
            <%--<%if(participante == null) {%><a href="#" class="registerMobile"><%=PowerUtils.localizeKey("register",currentLangBundle,frontendDefaultBundle)%></a><%}%>--%>
            <div class="registerForm register <%= registerClass%>">
                <% if (showFormBackEnd) {%>
                <form method="post" class="<%= registerClass %> jsRegisterForm" action="?<%= RequestParameters.REGISTO%>">
                    <h3 class="getInvolved <%= pm.isRtl() %>"><%=PowerUtils.getGetInvolvedText(pm.getCurrentLocale(),pm.getSystemId(request), pm.getDc(request))%></h3>
                    <p class="getInvolvedDescription <%= pm.isRtl() %>"><%=PowerUtils.getGetInvolvedDescription(pm.getCurrentLocale(),pm.getSystemId(request), pm.getDc(request))%></p>
                    <div class="registerFormField">
                        <label for="registerName"><%=PowerUtils.localizeKey("username",currentLangBundle,frontendDefaultBundle)%></label>
                        <input value="<%= pm.getRegisterValueFor(Participante.NOME_PROPERTY, request)%>" type="text" name="<%= Participante.NOME_PROPERTY %>" id="registerName" placeholder="<%= PowerUtils.localizeKey("username",currentLangBundle,frontendDefaultBundle) %>">
                    </div><!--
                    --><div class="registerFormField">
                        <label for="registerUsername"><%=PowerUtils.localizeKey("email",currentLangBundle,frontendDefaultBundle)%></label>
                        <input value="<%= pm.getRegisterValueFor(Participante.EMAIL_PROPERTY, request)%>" type="text" name="<%= Participante.EMAIL_PROPERTY %>" id="registerUsername" placeholder="<%= PowerUtils.localizeKey("email",currentLangBundle,frontendDefaultBundle) %>">
                    </div><!--
                    --><div class="registerFormField">
                        <label for="registerPassword"><%=PowerUtils.localizeKey("password",currentLangBundle,frontendDefaultBundle)%></label>
                        <input type="password" name="<%= RequestParameters.PWD %>" id="registerPassword" placeholder="<%= PowerUtils.localizeKey("password",currentLangBundle,frontendDefaultBundle)%>">
                    </div><!--
                    --><div class="registerFormField">
                        <label for="registerPassword2"><%=PowerUtils.localizeKey("password.confirmation",currentLangBundle,frontendDefaultBundle)%></label>
                        <input type="password" name="<%= RequestParameters.PWD2 %>" id="registerPassword2" placeholder="<%= PowerUtils.localizeKey("password.confirmation",currentLangBundle,frontendDefaultBundle)%>">
                    </div><!--
                    --><div class="registerFormField">
                        <div class="legal-checkbox mod">
                            <label>
                                <input type="checkbox" name="<%= RequestParameters.LEGAL %>">
                                <%=PowerUtils.localizeKey("agree.with.terms",currentLangBundle,frontendDefaultBundle,new String[]{"<a target='blank' href='terms_of_service.jsp'>" +PowerUtils.localizeKey("terms.of.use",currentLangBundle,frontendDefaultBundle)  + "</a>","<a target='blank'  href='privacy_policy.jsp'>" +PowerUtils.localizeKey("privacy.policy",currentLangBundle,frontendDefaultBundle)  + "</a>"})%>
                            </label>
                        </div>
                    </div><!--
                    --><div class="registerFormField">
                        <input title="<%=PowerUtils.localizeKey("register.button.context.info",currentLangBundle,frontendDefaultBundle)%>" type="submit" value="<%=PowerUtils.localizeKey("register",currentLangBundle,frontendDefaultBundle)%>">
                    </div>
                    <a href="#" class="orLogin openLogin"><%=PowerUtils.localizeKey("multi.platform.login",currentLangBundle,frontendDefaultBundle)%></a>
                    <%--<a href="#" class="fbLogin">Facebook</a>--%>
                    <%--<a href="#" class="g-signin2" data-onsuccess="<% if (participante == null) {%>googleLogin<%}%>">G+</a>--%>
                </form>
                <% }else {%>
                    <%= PowerUtils.getProperty(pm.getCurrentLocale(), pm.getSystemId(request), pm.getDc(request), SiteProps.REGISTRATION_FORM_OVERWRITE) %>
                <% }%>
            </div>
            <div class="registerForm <%= gamificationClass %>">
                <div class="<%= gamificationClass %>" style="width: 100%; text-align: center;">
                    <% String property = PowerUtils.getProperty(pm.getCurrentLocale(), pm.getSystemId(request), pm.getDc(request), SiteProps.HOME_CHART_OVERWRITE);
                    if (property == null || property.length() == 0) { %>
                            <div style="height: 100%; width:100%;display: inline-block;margin-bottom: 0px">
                                <% if (participante != null ) {%>
                                <tags:part_gamification_chart
                                        id="spiderChartPart"
                                        systemId="<%=pm.getSystemId(request)%>"
                                        showOverall="false"
                                        labelAxis="false"
                                        lineColor="white"
                                        locale="<%=pm.getCurrentLocale()%>"
                                        participant="<%=participante%>"/>
                                <% }%>
                            </div>
                            <ul class="communityDimensionsHome">
                                <li class="blue"><%=PowerUtils.localizeKey("cat.personal.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                                <li class="green"><%=PowerUtils.localizeKey("cat.social.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                                <li class="red"><%=PowerUtils.localizeKey("cat.political.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                            </ul>
                    <% } else { %>
                        <%= property %>
                    <% } %>
                </div>
            </div>
            <% if (!pm.isMobileRequest()) {%>
                <div class="appPromotion">
                    <p class="appPromotionText"><%=PowerUtils.localizeKey("access.or.download",currentLangBundle,frontendDefaultBundle)%></p>
                    <a target="_blank" href="<%=application.getInitParameter("androidAppLink")%>" class="appStore android"></a>
                    <a href="#" class="appStore ios" title="Available Soon"></a>
                </div>
            <% }%>
        </div>
        </div>
    </div>
</div>
<div class="section challenges">
    <div class="grid freeGrow">
        <h3 class="challengesTitle"><%=PowerUtils.localizeKey("challenges",currentLangBundle,frontendDefaultBundle)%></h3>
        <div class="challengesGrid"><!--
            <% for (Processo challenge : list) { %>
            --><a href="./?location=challenge&loadP=<%=challenge.getId()%>" class="challenge">
            <div class="challengeImage" style="background-image: url('<%=challenge.getThumbnail() != null ? "thumb?size=small&id="+challenge.getThumbnail().getId():"/redesign_images/imgMap.png"%>');"></div><!--
                    --><div class="challengeDescription <%= pm.isRtl() %>">
            <%= challenge.getTitulo() %>
            <%--<p class="challengeDate">Discuss until <span class="date"><%= df.format(challenge.getDataFim()) %></span></p>--%>
        </div>
        </a><!--
            <% } %>
        --></div>
    </div>
</div>
<div class="section community">
    <div class="grid freeGrow">
        <% String community_property = PowerUtils.getProperty(pm.getCurrentLocale(), pm.getSystemId(request), pm.getDc(request), SiteProps.COMMUNITY_SCORE_OVERWRITE);
            if (community_property == null || community_property.length() == 0) { %>
                <div class="line">
                    <div class="column">
                        <h3 class="communityTitle <%= pm.isRtl() %>"><%= PowerUtils.getTitleForOverallGamificationChart(pm.getCurrentLocale(),pm.getSystemId(request),pm.getDc(request))%></h3>
                        <p class="communityDescription <%= pm.isRtl() %>"><%= PowerUtils.getGamificationTableDescription(pm.getCurrentLocale(),pm.getSystemId(request),pm.getDc(request)) %></p>
                        <ul class="communityDimensions <%= pm.isRtl() %>">
                            <li class="blue"><%=PowerUtils.localizeKey("cat.personal.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                            <li class="green"><%=PowerUtils.localizeKey("cat.social.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                            <li class="red"><%=PowerUtils.localizeKey("cat.political.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                        </ul>
                    </div><!----><div class="column rigthColumn">
                    <tags:part_gamification_chart
                            id="spiderChartAll"
                            systemId="<%=pm.getSystemId(request)%>"
                            showOverall="true"
                            labelAxis="false"
                            locale="<%=pm.getCurrentLocale()%>"/>
                </div>
                    <ul class="communityDimensions legend">
                        <li class="blue"><%=PowerUtils.localizeKey("cat.personal.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                        <li class="green"><%=PowerUtils.localizeKey("cat.social.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                        <li class="red"><%=PowerUtils.localizeKey("cat.political.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                    </ul>
                </div>
            <% } else { %>
                <%= community_property %>
            <% } %>
    </div>
</div>

<script>
//    POWERController.initRegisterForm(".jsRegisterForm");
POWERController.initChangeHeader(".header:not(.issue)", ".header.issue", ".home.afterHeader");
POWERController.initRegisterMobile(".registerMobile");
POWERController.initResponsiveBackground(".section.home");
POWERController.initLegalCheckbox(".legal-checkbox.mod");
</script>
