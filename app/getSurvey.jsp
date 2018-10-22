<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.processo.Evento" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.List" %>
<%@ page import="com.baseform.apps.power.basedados.Resposta" %>
<%@ page import="com.baseform.apps.power.basedados.Formulario" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.basedados.Item" %>
<%@ page import="com.baseform.apps.power.utils.inputs.Input" %>
<%@ page import="com.baseform.apps.power.basedados.TTipoItem" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="org.apache.cayenne.ObjectContext" %>
<%@ page import="org.apache.cayenne.query.RefreshQuery" %>
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
    pm.renewDc(request);
    final ObjectContext dc = pm.getDc(request);
    dc.performQuery(new RefreshQuery());
    final Participante participant = pm.getParticipant(dc);
    if(participant!=null) {
        dc.performQuery(new RefreshQuery(participant));
        if (!participant.getRespostaParticipante().isEmpty()) {
            dc.performQuery(new RefreshQuery(participant.getRespostaParticipante()));
        }
    }
    Processo processo = pm.getProcess(request);

    List<Formulario> formularios = processo.getFormularios();
    Formulario formulario = null;
    for (Formulario formulario1 : formularios) {
        if (formulario1.getId().toString().equals(request.getParameter("id"))) {
            formulario = formulario1;
            break;
        }
    }
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();

    Resposta respostaParticipante = participant!=null ? participant.getRespostaParticipante(formulario) : null;
    boolean submited = respostaParticipante != null && respostaParticipante.getDataSubmissao() != null;
    String formAction = "./?" + RequestParameters.SAVE_ANSWERS + "&" + RequestParameters.SUBMIT + "_" + formulario.getId() + "=" + formulario.getId() + "&fid=" + formulario.getId();
    if (respostaParticipante != null && respostaParticipante.getDataSubmissao() == null)
        formAction += "&hIdR=" + respostaParticipante.getId();
%>
<link href="redesign_css/account.css" rel="stylesheet" type="text/css">
<link href="redesign_css/customCheckbox.css" rel="stylesheet" type="text/css">
<link href="redesign_css/customSelect.css" rel="stylesheet" type="text/css">

<div id="<%=formulario.getId()%>" class="survey">
    <h3 class="title"><%=formulario.getNome()%></h3>
    <div class="content">
        <div class="title"><%=formulario.getHTMLInfoIntrodutoria()%></div>
        <% if (participant == null) { %>
        <div class="logoutAnswer">
            <%=PowerUtils.localizeKey("to.answer.must",currentLangBundle,frontendDefaultBundle,true)%>
            <a href="#" onclick="POWERController.getModal('loginPopup.jsp', { activeTab: 'login'});"><%=PowerUtils.localizeKey("login",currentLangBundle,frontendDefaultBundle,true)%></a>
        </div>
        <% }%>
        <% if (submited) {%>
        <div class="submittedAt">
            <%=PowerUtils.localizeKey("survey.submitted.in",currentLangBundle,frontendDefaultBundle,true)%>
            <%=PowerUtils.TIME_FORMAT.format(respostaParticipante.getDataSubmissao())%>.
            <%=PowerUtils.localizeKey("msg.alter.submission",currentLangBundle,frontendDefaultBundle)%>
            <a href="?pp&<%=RequestParameters.REABRIR_INQUERITO%>&hIdR=<%=respostaParticipante.getId()%>"><%=PowerUtils.localizeKey("here",currentLangBundle,frontendDefaultBundle)%></a>
        </div>
        <% }else{%>
        <form action="<%= formAction %>" method="post" accept-charset="UTF-8" id="frm_<%=formulario.getId()%>">

            <%  boolean previous_inline = false;
                for (int idx = 0; idx < formulario.getItems().size(); idx++) {
                    Item i = formulario.getItems().get(idx);
                    final Input input = i.getInput();
                    boolean hide = false;

                    if (!i.getInline() || !previous_inline) {}
                    if (i.getTipo().getId() != TTipoItem.AGRUPADOR) {%>
            <div class="question"><%=participant != null ? input.getHTMLLabel() : input.getHTMLLabelFechado()%></div>
            <div class="answer"><%=participant != null ? ( respostaParticipante != null && respostaParticipante.getRespostaItem(i) != null ? input.getHTMLInput(respostaParticipante.getRespostaItem(i)) : input.getHTMLInput()) : input.getHTMLInputDisabled(null)%></div>
            <% }else{ %>
            <div class="question"><%=participant != null ? input.getHTMLLabel() : input.getHTMLLabelFechado()%></div>
            <% }
                if (!i.getInline() || i.getEndInline() || idx == formulario.getItems().size()) {
                    //close item div or if last item close div of inline items
                }
                previous_inline = i.getInline() && !i.getEndInline();
            }%>
        </form>
        <% } %>
    </div>
    <% if (!submited && participant != null) { %>
    <a href="#" class="gotIt submitSurvey" onclick="$('#frm_<%=formulario.getId()%>').submit();"><%= PowerUtils.localizeKey("submit",currentLangBundle,frontendDefaultBundle) %></a>
    <% } %>
</div>
<script type="text/javascript">
    <%=formulario.getScript()%>
</script>
<script>
    POWERController.initCustomCheckbox();
    POWERController.initCustomSelects();
    POWERController.initEventCheckbox($(".survey"));
</script>