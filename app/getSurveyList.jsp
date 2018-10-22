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
<%@ page import="com.baseform.apps.power.basedados.Formulario" %>
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
    Participante participante = pm.getParticipante();
    List<Formulario> forms = processo.getFormularios();
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>
<link href="redesign_css/account.css" rel="stylesheet" type="text/css">

<div class="section surveyList">
    <div class="grid">
        <h3 class="title"><%=PowerUtils.localizeKey("surveys",currentLangBundle,frontendDefaultBundle)%></h3>
        <ul class="issueList"><% for (Formulario form : forms) {%>
            <li class="issue survey jsSurvey" data-id="<%= form.getId() %>">
                <a title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.TAKE_SURVEY%>" target="<%=DataObjectUtils.pkForObject(form).toString()%>"/>" class="title survey"><%=form.getNome()%></a>
            </li>
        <%} %>
        </ul>
        <%if (forms.isEmpty()) {%>
            <h3 class="notFollowing"><%=PowerUtils.localizeKey("msg.no.surveys",currentLangBundle,frontendDefaultBundle)%></h3>
        <%}%>
    </div>
</div>
<script type="text/javascript">
    POWERController.initCustomCheckbox();
</script>