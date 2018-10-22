<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.basedados.Item" %>
<%@ page import="com.baseform.apps.power.basedados.ItemResposta" %>
<%@ page import="com.baseform.apps.power.basedados.Resposta" %>
<%@ page import="com.baseform.apps.power.basedados.TTipoItem" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteComentario" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteEvento" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteProcesso" %>
<%@ page import="com.baseform.apps.power.processo.Evento" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.utils.inputs.Input" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>
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

<script type="text/javascript" src="js/charts_js/Chart.js"></script>
<link href="redesign_css/account.css" rel="stylesheet" type="text/css">
<link href="redesign_css/customCheckbox.css" rel="stylesheet" type="text/css">
<link href="redesign_css/customSelect.css" rel="stylesheet" type="text/css">
<link href="redesign_css/main.css" rel="stylesheet" type="text/css">
<link href="redesign_css/issue.css" rel="stylesheet" type="text/css">
<link href="redesign_css/login_hub.css" rel="stylesheet" type="text/css">
<link href="redesign_css/htmlEditor.css" rel="stylesheet" type="text/css">
<%
    PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();

    final String curr_syst = pm.getSystemId(request);

    Participante participante = pm.getParticipante();

    List<RParticipanteProcesso> processosParticipados = participante.getProcessosAcompanhados();
    List<RParticipanteEvento> participanteEventos = participante.getParticipanteEvento();
    List <RParticipanteProcesso> filteredProcParticipados = new ArrayList<>();
    List <RParticipanteEvento> filteredEventoParticipados = new ArrayList<>();

    for(RParticipanteProcesso participanteProcesso : processosParticipados)
    {
        if(participanteProcesso.getProcesso().getSistema().equals(curr_syst))
            filteredProcParticipados.add(participanteProcesso);
    }

    for(RParticipanteEvento participanteEvento : participanteEventos)
    {
        if(participanteEvento.getEvento().getProcesso().getSistema().equals(curr_syst))
            filteredEventoParticipados.add(participanteEvento);
    }

    processosParticipados = filteredProcParticipados;
    participanteEventos = filteredEventoParticipados;
    request.setAttribute("systemId",pm.getSystemId(request));
    request.setAttribute(Participante.class.getSimpleName(),participante);
    request.setAttribute(Locale.class.getSimpleName(),pm.getCurrentLocale());
    boolean isBP = pm.getSystemId(request).equals(PowerPubManager.BEST_PRACTICES_ID);
%>
<div class="section issueArea about afterHeader">
    <div class="grid">
        <div class="intro title sticky">
            <a href="#" class="hamburger showMenu"></a><!--
            --><h3 class="title"><img src="<%= participante != null && participante.getImagem() != null ? "./user_avatar?id="+participante.getImagem().getId() : "redesign_images/user.png" %>" class="userImage"/><%=pm.getParticipante().getNome()%><span><%=participante.getEmail()%></span></h3>
            <div class="mobileMenu">
                <ul class="tabs">
                    <% if (!isBP) {%><li class="tab"><a href="#areaTitle" class="<%= pm.isRtl() %>"><%=PowerUtils.getTitleForUserGamificationChart(pm.getCurrentLocale(),curr_syst,pm.getDc(request))%></a></li><%}%>
                    <li class="tab"><a href="#issues" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("followed.issues",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#participations" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("participations",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#events" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("events",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#changeinfo" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.info",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#changeLanguage" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.language",currentLangBundle,frontendDefaultBundle)%></a></li>
                </ul>
            </div>
            <a href="./?logout_pub" class="logoutLink logout"><%=PowerUtils.localizeKey("logout",currentLangBundle,frontendDefaultBundle)%></a>
        </div>
        <div class="content">
            <div class="contentPartial side menu">
                <%
                    String gamification = PowerUtils.getTitleForUserGamificationChart(pm.getCurrentLocale(),curr_syst,pm.getDc(request));
                    if (gamification == null || gamification.length() == 0) gamification = "Gamification";
                %>
                <ul class="tabs">
                    <% if (!isBP) {%><li class="tab"><a href="#areaTitle" class="<%= pm.isRtl() %>"><%=gamification%></a></li><% }%>
                    <li class="tab"><a href="#issues" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("followed.issues",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#participations" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("participations",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#events" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("events",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#changeinfo" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.info",currentLangBundle,frontendDefaultBundle)%></a></li>
                    <li class="tab"><a href="#changeLanguage" class="<%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.language",currentLangBundle,frontendDefaultBundle)%></a></li>
                </ul>
            </div><!--
            --><div class="contentPartial mainContent">
                <% String property = PowerUtils.getProperty(pm.getCurrentLocale(), pm.getSystemId(request), pm.getDc(request), SiteProps.MY_GAMIFICATION_PROGRESS_OVERWRITE); %>
                <% if (!isBP && (property == null || property.length() == 0)) {%>
                <div id="areaTitle" class="tabContent">
                    <div class="title <%= pm.isRtl() %>"><%=PowerUtils.getTitleForUserGamificationChart(pm.getCurrentLocale(),curr_syst,pm.getDc(request))%></div>
                    <div class="description HTMLContent <%= pm.isRtl() %>"><%=PowerUtils.getFreeTextForProfile(pm.getCurrentLocale(),curr_syst,pm.getDc(request))%></div>
                    <div class="badge"><jsp:include page="userOwnBadge.jsp" /></div>
                    <div class="halfChart">
                        <h3 class="gamificationDetails <%= pm.isRtl() %>"><%=participante.getGamificationToString(currentLangBundle,frontendDefaultBundle,curr_syst,request)%></h3>

                        <div style="width: 100%; text-align: center;">
                            <div class="chartHolder" style="width: 100%; height: 100%;display: inline-block">
                                <tags:part_gamification_chart
                                        id="spiderChartIndividual"
                                        systemId="<%=pm.getSystemId(request)%>"
                                        locale="<%=pm.getCurrentLocale()%>"
                                        participant="<%=participante%>"/>
                            </div>
                        </div>
                    </div><!--
                    --><div class="halfChart">
                        <h3 class="gamificationDetails"><%= PowerUtils.getGamificationTableDescription(pm.getCurrentLocale(),pm.getSystemId(request),pm.getDc(request)) %></h3>

                        <div style="width: 100%; text-align: center;">
                            <div class="chartHolder" style="width: 100%; height: 100%;display: inline-block">
                                <tags:part_gamification_chart
                                        id="spiderChartAll"
                                        systemId="<%=pm.getSystemId(request)%>"
                                        showOverall="true"
                                        labelAxis="false"
                                        locale="<%=pm.getCurrentLocale()%>"/>
                            </div>
                        </div>
                    </div>
                    <ul class="communityDimensionsHome black">
                        <li class="blue"><%=PowerUtils.localizeKey("cat.personal.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                        <li class="green"><%=PowerUtils.localizeKey("cat.social.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                        <li class="red"><%=PowerUtils.localizeKey("cat.political.impact",currentLangBundle,frontendDefaultBundle,true)%></li>
                    </ul>
                </div>
                <% } else {%>
                    <%= property %>
                <% } %>
                <div id="issues" class="tabContent section followedIssues">
                    <div class="title <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("followed.issues",currentLangBundle,frontendDefaultBundle)%></div>
                    <ul class="issueList">
                        <% boolean isFollowing = false;
                            for (RParticipanteProcesso processosSeguido : processosParticipados) {
                                if(processosSeguido.getIsFollowing() && processosSeguido.getProcesso().getPublicado())
                                {
                                    isFollowing = true;
                                    Processo p = processosSeguido.getProcesso();
                        %>
                        <li class="issue">
                            <a class="title <%= pm.isRtl() %>" href="./?location=challenge&<%=RequestParameters.LOAD_P%>=<%=p.getId()%>"><%= p.getTitulo() %></a>
                            <span class="date"><%=PowerUtils.DATE_FORMAT.format(processosSeguido.getData())%></span>

                            <a class="remove" href="#" onclick="go('?<%=RequestParameters.REMOVER_SEGUIR%>=<%=DataObjectUtils.pkForObject(processosSeguido)%>')"></a>
                        </li>
                        <% } }%>
                    </ul>
                    <%if (!isFollowing) {%>
                    <h3 class="notFollowing <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("not.following",currentLangBundle,frontendDefaultBundle)%></h3>
                    <%}%>
                </div>
                <div id="participations" class="tabContent section participations">
                    <div class="title <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("participations",currentLangBundle,frontendDefaultBundle)%></div>
                    <ul class="issueList">
                        <%  for (RParticipanteProcesso processosAcompanhado : processosParticipados) {
                            Processo p = processosAcompanhado.getProcesso();
                            List<RParticipanteComentario> comentariosProcesso = participante.getComentariosProcesso(p);
                            List<RParticipanteComentario> tipsProcesso = participante.getTipsProcesso(p);
                            List<Resposta> respostasGravadasParticipante = participante.getFormsGravadosParticipante(p);
                            List<Resposta> respostasSubmetidasParticipante = participante.getFormsSubmetidosParticipante(p);
                            if(p.getPublicado() && (comentariosProcesso != null  && !comentariosProcesso.isEmpty()) ||
                                    (respostasGravadasParticipante != null && !respostasGravadasParticipante.isEmpty()) ||
                                    (respostasSubmetidasParticipante != null && !respostasSubmetidasParticipante.isEmpty())){        %>
                        <li class="issue">
                            <a class="title" href="./?location=challenge&<%=RequestParameters.LOAD_P%>=<%=p.getId()%>"><%= p.getTitulo() %></a>
                            <ul class="participationList">
                                <li class="participationType"><a href="#" data-type="comments"><%=comentariosProcesso.size()%>&nbsp;<%=PowerUtils.localizeKey("comments.submitted",currentLangBundle,frontendDefaultBundle)%></a></li>
                                <li class="participationType"><a href="#" data-type="tips"><%=tipsProcesso.size()%>&nbsp;<%=PowerUtils.localizeKey("tips.submitted",currentLangBundle,frontendDefaultBundle)%></a></li>
                                <li class="participationType"><a href="#" data-type="surveys"><%=respostasSubmetidasParticipante.size()%>&nbsp;<%=PowerUtils.localizeKey("surveys.submitted",currentLangBundle,frontendDefaultBundle)%></a></li>
                            </ul>
                            <ul class="participationContent">
                                <li class="participationType hidden" data-type="surveys">
                                    <% for (Resposta resposta : respostasSubmetidasParticipante) { %>
                                    <div id="<%=resposta.getId()%>" class="survey">
                                        <h3 class="title"><%=resposta.getFormulario() != null ? resposta.getFormulario().getNome() : ""%></h3>
                                        <h3 class="details"><%=resposta.getDataSubmissao() != null ? "- "+PowerUtils.localizeKey("submitted.in",currentLangBundle,frontendDefaultBundle)+" " + PowerUtils.DATE_FORMAT.format(resposta.getDataSubmissao()) : ""%></h3>
                                        <div class="content hidden">
                                            <%if (resposta != null && resposta.getDataSubmissao() != null) {%>
                                            <div class="title">
                                                <%=resposta.getFormulario().getHTMLInfoIntrodutoria()%>
                                            </div>
                                            <%  boolean previous_inline = false;
                                                for (int idx = 0; idx < resposta.getFormulario().getItems().size(); idx++) {
                                                    Item i = resposta.getFormulario().getItems().get(idx);
                                                    ItemResposta ir = resposta.getRespostaItem(i);
                                                    final Input input = i.getInput();

                                                    boolean hide = false;
                                                    if (!i.getInline() || !previous_inline) {}
                                                    if (i.getTipo().getId() != TTipoItem.AGRUPADOR) {%>
                                            <div class="question"><%=input.getHTMLLabelFechado()%></div>
                                            <div class="answer"><%=input.getHTMLInputFechado(ir)%></div>
                                            <% }else{ %>
                                            <div class="question"><%=input.getHTMLLabelFechado()%></div>
                                            <% }
                                                if (!i.getInline() || i.getEndInline() || idx == resposta.getFormulario().getItems().size()) {
                                                    //close item div or if last item close div of inline items
                                                }
                                                previous_inline = i.getInline() && !i.getEndInline();
                                            }%>
                                            <% } %>
                                        </div>
                                    </div>
                                    <% } %>
                                </li>
                                <li class="participationType hidden" data-type="comments">
                                    <% for (RParticipanteComentario rParticipanteComentario : participante.getComentariosProcesso(p)) { %>
                                    <div class="comment">
                                        <h3 class="date"><%=rParticipanteComentario.getData() != null ? PowerUtils.DATE_FORMAT.format(rParticipanteComentario.getData()) : ""%></h3>
                                        <h3 class="status"><%=PowerUtils.localizeKey(rParticipanteComentario.getStringForStatus(),currentLangBundle,frontendDefaultBundle)%></h3>
                                        <p class="content"><%=rParticipanteComentario.getComentario() != null ? rParticipanteComentario.getComentario() : ""%></p>
                                        <p class="content"><%=rParticipanteComentario.getLikes() + " " + PowerUtils.localizeKey("likes",currentLangBundle,frontendDefaultBundle)%> | <%=rParticipanteComentario.getDislikes() + " " + PowerUtils.localizeKey("dislikes",currentLangBundle,frontendDefaultBundle)%></p>
                                    </div>
                                    <% } %>
                                </li>
                                <li class="participationType hidden" data-type="tips">
                                    <% for (RParticipanteComentario rParticipanteComentario : participante.getTipsProcesso(p)) { %>
                                    <div class="comment">
                                        <h3 class="date"><%=rParticipanteComentario.getData() != null ? PowerUtils.DATE_FORMAT.format(rParticipanteComentario.getData()) : ""%></h3>
                                        <h3 class="status"><%=PowerUtils.localizeKey(rParticipanteComentario.getStringForStatus(),currentLangBundle,frontendDefaultBundle)%></h3>
                                        <p class="content"><%=rParticipanteComentario.getComentario() != null ? rParticipanteComentario.getComentario() : ""%></p>
                                        <p class="content"><%=rParticipanteComentario.getLikes() + " " + PowerUtils.localizeKey("likes",currentLangBundle,frontendDefaultBundle)%> | <%=rParticipanteComentario.getDislikes() + " " + PowerUtils.localizeKey("dislikes",currentLangBundle,frontendDefaultBundle)%></p>
                                    </div>
                                    <% } %>
                                </li>
                            </ul>
                        </li>
                        <% }
                        }%>
                    </ul>
                    <%if (processosParticipados.isEmpty()) {%>
                    <h3 class="notFollowing <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("msg.no.participation",currentLangBundle,frontendDefaultBundle)%></h3>
                    <%}%>
                </div>
                <div id="events" class="tabContent section events">
                    <div class="title <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("events",currentLangBundle,frontendDefaultBundle)%></div>
                    <ul class="issueList">
                        <% for (RParticipanteEvento participanteEvento : participanteEventos) {

                            if(participanteEvento.getEvento().getProcesso().getPublicado()) {
                                Evento evento = participanteEvento.getEvento();
                                String s = participante.participaEvento(evento) != null ? RequestParameters.NIR_EVENTO : RequestParameters.IR_EVENTO;
                                String link = "";
                                if (evento.getLink() != null && !evento.getLink().isEmpty()) {
                                    link = evento.getLink();
                                } else if (evento.getFicheiro() != null && !evento.getFicheiro().isEmpty()) {
                                    link = config.getServletContext().getInitParameter("server_href") + "/event?id=" + DataObjectUtils.pkForObject(evento.getFicheiro().get(0));
                                }
                        %>
                        <li class="issue">
                            <a class="title <%= pm.isRtl() %>" href="<%= link %>" class="eventLink"><%=evento.getDesignacao()%></a>
                            <h3 class="details"><%=evento.getData() != null ? PowerUtils.DATE_FORMAT.format(evento.getData()) : ""%> |  <%=evento.getLocal()%></h3>
                            <div class="participate">
                                <label for="<%= s + evento.getId()%>" class="customCheckbox blue  <%=participante.participaEvento(evento)!=null?"checked":""%>">
                                    <input class="hidden" id="<%=s + evento.getId()%>" type="checkbox" name="eventoCheck" data-param="<%= s %>" value="option"
                                           checked="<%=participante.participaEvento(evento)!=null?"checked":""%>"
                                           data-id="<%= evento.getId()%>"/>
                                    <%=PowerUtils.localizeKey("going",currentLangBundle,frontendDefaultBundle)%>
                                </label>
                            </div>
                        </li>
                        <% }
                        } %>
                    </ul>
                    <%if (participanteEventos.isEmpty()) {%>
                    <h3 class="notFollowing <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("msg.no.followed.events",currentLangBundle,frontendDefaultBundle)%></h3>
                    <%}%>
                </div>
                <div id="changeinfo" class="tabContent section register">
                    <div class="title <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.info",currentLangBundle,frontendDefaultBundle)%></div>
                    <div class="subTitle <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.personal.info",currentLangBundle,frontendDefaultBundle)%></div>

                    <form enctype="multipart/form-data" accept-charset="utf-8" method="post" action="?<%=RequestParameters.ALTERAR%>" id="fprof">
                        <input type="text" class="<%= pm.isRtl() %>" name="<%= Participante.NOME_PROPERTY %>" value="<%= participante.getNome()%>" placeholder="<%= PowerUtils.localizeKey("username",currentLangBundle,frontendDefaultBundle) %>"><!--
                        --><input type="hidden" name="filler"><!--
                        --><input type="password" class="<%= pm.isRtl() %>" name="<%= RequestParameters.PWD %>" placeholder="<%= PowerUtils.localizeKey("password",currentLangBundle,frontendDefaultBundle) %>"><!--
                        --><input type="password" class="<%= pm.isRtl() %>" name="<%= RequestParameters.PWD2 %>" placeholder="<%= PowerUtils.localizeKey("confirm.password",currentLangBundle,frontendDefaultBundle) %>">
                        <label class="photoPicker"><p class="<%= pm.isRtl() %>"><%= PowerUtils.localizeKey("change.photo",currentLangBundle,frontendDefaultBundle) %></p><input type="file" onChange="$('.photoPicker p').html($(this).val().replace('C:\\fakepath\\',''));" name="avatar" id="avatar" class="" /></label>
                    </form>
                    <a class="submitRegister submit <%= pm.isRtl() %>" onclick="$('#fprof').submit();"><%=PowerUtils.localizeKey("alter.data", currentLangBundle, frontendDefaultBundle)%> ></a>
                </div>
                <div id="changeLanguage" class="tabContent section language" style="height: 200px;">
                    <div class="title <%= pm.isRtl() %>"><%=PowerUtils.localizeKey("change.language",currentLangBundle,frontendDefaultBundle)%></div>
                    <div class="customSelect">
                        <div class="customSelectTitle"><%= pm.getCurrentLocale().getDisplayLanguage(pm.getCurrentLocale()) %></div>
                        <input type="hidden" name="currentLocale" class="tId" value=""/>
                        <div class="customSelectOptions">
                            <ul class="options">
                                <%
                                    List<Locale> locales = pm.getLocales(request);
                                    for(Locale locale :locales) { %>
                                    <li class="option changeLocale" ><a href="#" data-locale="./?changeLocale=<%= locale.toString()%>"><%= locale.getDisplayLanguage(locale) %></a></li>
                                <%}%>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    POWERController.initCustomCheckbox();
    POWERController.initParticpationTypes();
    POWERController.initCustomSelects();
    POWERController.initTabs(".tab", "active");
    POWERController.initScrollTitle(".intro.title");
    POWERController.initStickyMenu(".menu .tabs");
    POWERController.initScrollTab(".menu .tabs", ".tab", "active");
    POWERController.initMobileMenu(".showMenu", ".mobileMenu", "active");
    POWERController.initEventCheckbox($(".issueList"));

    $(".changeLocale").on("click", function(e) {
       location.href = $(this).find("a").data("locale");
    });
</script>