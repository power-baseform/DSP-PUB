<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="java.util.Locale" %>
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
    PowerPubManager pm = (PowerPubManager) PublicManager.get(request,PowerPubManager.class);
    pm.process(request, response);
    pm = (PowerPubManager) PublicManager.get(request);

    if (request.getParameter("mobileReq") != null) pm.setMobileRequest();
    if (pm.getCurrentLocationName()==null || (pm.getCurrentLocationName().equals("login") && pm.getParticipante() != null && pm.isMobileRequest())) {
        response.sendRedirect(config.getServletContext().getInitParameter("server_href") + "?location=home");
        return;
    }

    if (request.getHeader("tok") != null && pm.getParticipante() == null && pm.isMobileRequest())
        pm.loginByToken(request.getHeader("tok"), request, pm.getCurrentLangBundle());

    if(pm.getParticipante()!=null) {
        response.setHeader("tok", pm.getParticipante().getAutologinToken());
    }

    final String curr_syst = PublicManager.get(request).getSystemId(request);
    final Processo processo = pm.getProcess(request);
    if (pm.getCurrentLocationName().equals("challenge") && (processo == null || !processo.getSistema().equals(curr_syst))) {
        response.sendRedirect("./?location=home");
        return;
    }

    final Locale currentLocale = pm.getCurrentLocale();
    final String currentLocation = pm.getCurrentLocation();
%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="<%=currentLocale.getLanguage()%>">
<%@include file="header.jspf" %>
<body>
<div id="mainDiv" style="height:100%">
    <jsp:include page="erros.jsp" flush="true" />
    <% if (!pm.isMobileRequest()) {%>
        <jsp:include page="<%=currentLocation.equalsIgnoreCase("home.jsp") ? "top.jspf" : "topMenu.jspf"%>" flush="true"/>
        <% if (currentLocation.equalsIgnoreCase("home.jsp")) {
            request.setAttribute("secondHeader", true);%>
            <jsp:include page="topMenu.jspf" flush="true" />
        <%}%>
    <% } %>
    <jsp:include page="<%=currentLocation%>" flush="true" />
    <% if (!pm.isMobileRequest()) {%>
        <jsp:include page="footer.jspf" flush="true"/>
    <% }%>
</div>
<script>
    $(window).load(function(e) {
        try {
            POWERController.cleanHTMLContent(".HTMLContent:not(.noClean) *");
            POWERController.resizeHTMLContent(".HTMLContent *", ".HTMLContent");
            setTimeout(function (e) {
                $(".HTMLContent").removeClass("notVisible");
            }, 200);
            POWERController.initStickyHeader(".section.header", ".section.afterHeader");
            POWERController.initFooterAutoHeight(".section.footer");
            POWERController.initScrollEvents();
            POWERController.initResizeEvents();
            POWERController.initAppButtons();
            POWERController.initInputs();
        } catch(err) {
            POWERController.cleanHTMLContent(".HTMLContent:not(.noClean) *");
        }
    });
</script>

</body>
</html>