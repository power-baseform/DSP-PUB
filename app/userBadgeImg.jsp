<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="java.util.Locale" %>
<%@ page trimDirectiveWhitespaces="true" %><%
    final Participante participante = request.getAttribute(Participante.class.getSimpleName())!=null? (Participante) request.getAttribute(Participante.class.getSimpleName()) :null;
    final Locale l = request.getAttribute(Locale.class.getSimpleName())!=null? (Locale) request.getAttribute(Locale.class.getSimpleName()) :null;
    final String systemId = request.getAttribute("systemId")!=null?request.getAttribute("systemId").toString().trim():"";
    final int heightForUserBadgeImg = request.getAttribute("heightForUserBadgeImg")!=null? (int) request.getAttribute("heightForUserBadgeImg") :25;
    if(participante!=null){
        final String badgeMetal = participante.getBadgeMetal(systemId, request);
        final int gamificationTotal = participante.getGamificationValues(systemId, request).getTotal().intValue();
%><img height="<%=heightForUserBadgeImg%>" data-alternative="img/<%=participante.getBadgeMetal(systemId, request)%>_badge.png" src="img/<%=badgeMetal%>_badge.svg" alt="<%=badgeMetal%>" class="badgeImg badge" title="<%=gamificationTotal+" "+PowerUtils.localizeKey("points", PowerUtils.getBundle(l),PowerUtils.getDefaultBundle())%>"/><% } %>