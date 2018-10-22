<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="java.util.Locale" %>
<%
    final Participante participante = request.getAttribute(Participante.class.getSimpleName())!=null? (Participante) request.getAttribute(Participante.class.getSimpleName()) :null;
    final Locale l = request.getAttribute(Locale.class.getSimpleName())!=null? (Locale) request.getAttribute(Locale.class.getSimpleName()) :null;
    final String systemId = request.getAttribute("systemId")!=null?request.getAttribute("systemId").toString().trim():"";
    if(participante!=null){
        final String badgeMetal = participante.getBadgeMetal(systemId, request);
        final int gamificationTotal = participante.getGamificationValues(systemId, request).getTotal().intValue();
        request.setAttribute("heightForUserBadgeImg",60);
%>
<div class="gamificationBadge">
    <span class="badgePoints texto16"><%=gamificationTotal%> <%=PowerUtils.localizeKey("points", PowerUtils.getBundle(l),PowerUtils.getDefaultBundle())%></span>
    <jsp:include page="userBadgeImg.jsp" />
    <span class="badgePhrase texto14"><%=PowerUtils.getPhraseForMetal(badgeMetal,l,systemId,participante.getObjectContext())%></span>
</div>
<%
    }
%>
