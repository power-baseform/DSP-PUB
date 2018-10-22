<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.processo.Evento" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="org.apache.cayenne.ObjectContext" %>
<%@ page import="org.apache.cayenne.query.RefreshQuery" %>
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
    Processo processo = pm.getProcess(request);
    final ObjectContext dc = processo.getObjectContext();
    Participante participante = pm.getParticipant(dc);
    if(participante!=null) {
        dc.performQuery(new RefreshQuery(participante));
        //dc.performQuery(new RefreshQuery(participante.getParticipanteEvento()));
    }
    dc.performQuery(new RefreshQuery(processo));
    dc.performQuery(new RefreshQuery(processo.getEventos()));
    dc.performQuery(new RefreshQuery());
    final List<Evento> eventos = processo.getEventos();
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>
<link href="redesign_css/account.css" rel="stylesheet" type="text/css">
<link href="redesign_css/customCheckbox.css" rel="stylesheet" type="text/css">

<div class="section events">
    <div class="grid">
        <h3 class="title"><%=PowerUtils.localizeKey("events",currentLangBundle,frontendDefaultBundle)%></h3>
        <ul class="issueList">
            <% for (Evento evento : eventos) {
                    String link = "";
                    String s = participante != null && participante.participaEvento(evento) != null ? RequestParameters.NIR_EVENTO : RequestParameters.IR_EVENTO;
                    if (evento.getLink() != null && !evento.getLink().isEmpty()) {
                        link = evento.getLink(); 
                    } else if (evento.getFicheiro() != null && !evento.getFicheiro().isEmpty()) {
                        link = config.getServletContext().getInitParameter("server_href") + "/event?id=" + DataObjectUtils.pkForObject(evento.getFicheiro().get(0));
                    }
            %>
            <li class="issue">
                <a class="title" style="pointer-events: none;" href="<%= link %>" class="eventLink"><%=evento.getDesignacao()%></a>
                <h3 class="details"><%=evento.getData() != null ? PowerUtils.DATE_FORMAT.format(evento.getData()) : ""%> |  <%=evento.getLocal()%></h3>
                <% if (participante != null) { %>
                <div class="participate">
                    <label for="<%= s + evento.getId()%>" title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.ATTEND_MEETING%>" target="<%=DataObjectUtils.pkForObject(evento).toString()%>"/>" class="customCheckbox blue  <%=participante.participaEvento(evento)!=null?"checked":""%>">
                        <input class="hidden" id="<%=s + evento.getId()%>" type="checkbox" name="eventoCheck" data-param="<%= s %>" value="option"
                               checked="<%=participante.participaEvento(evento)!=null?"checked":""%>"
                               data-id="<%= evento.getId()%>"/>
                        <%=PowerUtils.localizeKey("going",currentLangBundle,frontendDefaultBundle)%>
                    </label>
                </div>
                <% } %>
            </li>
            <%} %>
        </ul>
        <%if (eventos.isEmpty()) {%>
        <h3 class="notFollowing"><%=PowerUtils.localizeKey("msg.no.followed.events",currentLangBundle,frontendDefaultBundle)%></h3>
        <%}%>
    </div>
</div>
<script type="text/javascript">
    POWERController.initCustomCheckbox();
    POWERController.initEventCheckbox($(".issueList"));
</script>