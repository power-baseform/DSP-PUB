<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.basedados.Formulario" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteComentario" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="org.apache.cayenne.query.Ordering" %>
<%@ page import="org.apache.cayenne.query.SortOrder" %>
<%@ page import="twitter4j.Status" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.cayenne.ObjectContext" %>
<%@ page import="org.apache.cayenne.query.RefreshQuery" %>
<%@ page import="com.baseform.apps.power.processo.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page trimDirectiveWhitespaces="true" %>
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
<%
    final PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final Processo processo = pm.getProcess(request);
    final ObjectContext oc = processo.getObjectContext();
    final Participante participante = pm.getParticipant(oc);
    oc.performQuery(new RefreshQuery(processo));
    if(participante!=null) {
        oc.performQuery(new RefreshQuery(participante));
        if(!participante.getGotitSections().isEmpty())
        oc.performQuery(new RefreshQuery(participante.getGotitSections()));
    }

    final DateFormat df = new SimpleDateFormat("dd/MM/yyyy", Locale.US);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
    final Date hoje = new Date();
    final DecimalFormat rounder = new DecimalFormat("#.##");
    rounder.setRoundingMode(RoundingMode.CEILING);


    boolean open = true;
    final boolean isRTL = PowerUtils.isTextRTL(PublicManager.get(request).getCurrentLocale());
    final boolean isIssueRTL = isRTL && PowerUtils.isTextRTL(new Locale(processo.getLocale()));


    List<Documento> documentosProcesso = processo.getDocumentosProcesso();
    new Ordering(Documento.DESIGNACAO_PROPERTY, SortOrder.ASCENDING_INSENSITIVE).orderList(documentosProcesso);

    String appendable = "";
    String cId = "";
    String rId = request.getParameter("rId");
    if (request.getParameter(RequestParameters.NIR_EVENTO) != null || request.getParameter(RequestParameters.IR_EVENTO) != null) {
        appendable = "events";
    } else if(request.getParameter(RequestParameters.SUBMIT) != null) {
        appendable = "surveys";
    } else if(request.getParameter(RequestParameters.COMENTAR) != null || request.getParameter(RequestParameters.REPLY) != null) {
        appendable = "comments";
        cId = request.getParameter(RequestParameters.COMENTAR);
    }

    if (cId.equals("") && request.getParameter("cId") != null) {
        cId = request.getParameter("cId");
        appendable = "comments";
    }
%>
<link href="redesign_css/main.css" rel="stylesheet" type="text/css">
<link href="redesign_css/issue.css" rel="stylesheet" type="text/css">
<link href="redesign_css/htmlEditor.css" rel="stylesheet" type="text/css">
<link href="redesign_css/stats.css" rel="stylesheet" type="text/css">
<link href="redesign_css/footer.css" rel="stylesheet" type="text/css">
<%

    boolean jaSegue = participante!=null && participante.segueCodigo(processo) != null;
    List<Seccao> seccoes = processo.getSeccoesOrdenadas();

    List<Status> tweets = new ArrayList<>();
    if(processo.getHashtags() != null && !processo.getHashtags().trim().isEmpty()) {
        String consumerKey = request.getServletContext().getInitParameter("consumer_key");
        String consumerSecret = request.getServletContext().getInitParameter("consumer_secret");
        String accessToken = request.getServletContext().getInitParameter("access_token");
        String accessTokenSecret = request.getServletContext().getInitParameter("access_token_secret");
        tweets = PowerPubManager.SearchTweetsAsList(processo.getHashtags(), 5, consumerKey, consumerSecret, accessToken, accessTokenSecret, 5 * 60 * 1000, pm.getCurrentLocale());
    }
%>
<div style="display: none">
    <img src="<%=config.getServletContext().getInitParameter("server_href")%><%=processo.getThumbnail() != null && !processo.getThumbnail().isNew()? "/thumb?size=med&id="+processo.getThumbnail().getId():"/img/default_img.png"%>" alt="<%= processo.getTitulo() %>"/>
</div>
<% if (!pm.isMobileRequest()) {%>
<div class="section home issue afterHeader" style="background-image: url(<%=processo.getThumbnail() != null ? "thumb?size=med&id="+processo.getThumbnail().getId() :"/redesign_images/imgMap.png"%>)"></div>
<% } %>
<div class="utils" data-status="<%= participante != null %>" data-id="<%= processo.getId() %>"
     data-loadP="<%= RequestParameters.LOAD_P %>" data-follow="<%=PowerUtils.localizeKey( "follow",currentLangBundle,frontendDefaultBundle,true)%>"
     data-unfollow="<%=PowerUtils.localizeKey( "unfollow",currentLangBundle,frontendDefaultBundle,true)%>" data-followStatus="<%= jaSegue %>"
     data-action="<%= RequestParameters.ACTION %>" data-actionUnfollow="<%= RequestParameters.REMOVER_SEGUIR %>"
     data-actionFollow="<%= RequestParameters.SEGUIR %>" data-iprocesso="<%= RequestParameters.IPROCESSO %>"
     data-title="<%= processo.getTitulo()%>" data-tags="<%= processo.getHashtags()%>"
     data-servlet-url="<%= config.getServletContext().getInitParameter("server_href") %>" data-click-link="<%= RequestParameters.CLICK_LINK %>"></div>
<div class="section issueArea">
    <div class="grid freeGrow">
        <div class="intro title">
            <a href="#" class="hamburger showMenu"></a><!--
            --><h3 class="title <%= pm.isRtl() %>"><%= processo.getTitulo() %></h3>
            <div class="mobileMenu"></div>
        </div>
        <div class="content">
            <div class="contentPartial mergedContent">
                <div class="intro">
                    <p class="description <%= pm.isRtl() %>"><%= processo.getDescricao() %></p>
                </div>
                <div class="contentPartial side menu">
                    <ul class="tabs"> <!--
                        <% if(processo.getMapontop() != null && processo.getMapontop() && processo.getShapeUrl()!=null && !processo.getShapeUrl().isEmpty()) {%>
                        --><li class="tab static"><a href="#map" class="<%= pm.isRtl() %>"><%= PowerUtils.localizeKey("map",currentLangBundle,frontendDefaultBundle,true) %></a></li><!--
                        <% }%>
                        <% for (Seccao section : seccoes) { %>
                         --><li class="tab"><a href="#<%= section.getId()%>" class="<%= pm.isRtl() %>"><%= section.getTitulo() %></a></li><!--
                        <% } %>
                        <% if((processo.getMapontop() == null || !processo.getMapontop()) && processo.getShapeUrl()!=null && !processo.getShapeUrl().isEmpty()) {%>
                        --><li class="tab static"><a href="#map" class="<%= pm.isRtl() %>"><%= PowerUtils.localizeKey("map",currentLangBundle,frontendDefaultBundle,true) %></a></li><!--
                        <% }%>
                        <% if (documentosProcesso.size()>0) {%>
                        --><li class="tab static"><a href="#documents" class="<%= pm.isRtl() %>"><%= PowerUtils.localizeKey("documents",currentLangBundle,frontendDefaultBundle,true) %></a></li><!--
                        <% }%>
                        --><li class="tab static"><a href="#stats" class="<%= pm.isRtl() %>"><%= PowerUtils.localizeKey("stats",currentLangBundle,frontendDefaultBundle,true) %></a></li><!--

                        <% if (!PowerPubManager.BEST_PRACTICES_ID.equals(processo.getSistema())) {%>
                            --><li class="tab static noBorder <% if (processo.getGamificationChartIframe() == null || processo.getGamificationChartIframe().length() == 0) {%>hasCustomTitle<%}%> chartClick <%= pm.isRtl() %>" title="<%= PowerUtils.localizeKey("learn.get.points.description",currentLangBundle,frontendDefaultBundle,false) %>">
                                <h3 class="title <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("learn.get.points",currentLangBundle,frontendDefaultBundle,true) %></h3><img  data-alternative="img/gold_badge.png" src="img/gold_badge.svg" class="titleBadge"/>
                                <% if (processo.getGamificationChartIframe() == null || processo.getGamificationChartIframe().length() == 0) { %>
                                <tags:issue_personal_gamification_chart
                                        id="spiderChartIssue"
                                        issue="<%=processo%>"
                                        systemId="<%=pm.getSystemId(request)%>"
                                        locale="<%=pm.getCurrentLocale()%>"
                                        participant="<%=participante%>"/>
                                <% } else {%>
                                    <%= processo.getGamificationChartIframe() %>
                                <% }%>
                            </li><!--
                        <% }%>
                        --><li class="tab appendInfo"></li>
                    </ul>
                </div><!--
            --><div class="contentPartial mainContent">
                    <div class="tabContent appendable hidden"></div>
                    <% if(processo.getMapontop() != null && processo.getMapontop() && processo.getShapeUrl()!=null && !processo.getShapeUrl().isEmpty()) {%>
                    <div class="tabContent static" id="map">
                        <div class="title <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("map",currentLangBundle,frontendDefaultBundle,true) %></div>
                        <iframe width="100%" height="auto" class="map" src="<%= pm.isMobileRequest() ? processo.getShapeMobileUrl() : processo.getShapeUrl()%>"></iframe>
                    </div>
                    <% }%>
                    <% for (Seccao section : seccoes) { %>
                    <div class="tabContent" id="<%= section.getId()%>">
                        <div class="title <%= pm.isRtl() %>"><%= section.getTitulo()%></div>
                        <div class="HTMLContent notVisible <%= pm.isRtl() %>">
                            <%= section.getCorpo() %>
                        </div>
                        <% if (!PowerPubManager.BEST_PRACTICES_ID.equals(processo.getSistema()) && processo.getGamificationValues(Processo.GAMIFICATION_ACTIONS.GOT_IT_SECTION,String.valueOf(section.getId())).getTotal().intValue() > 0) {%>
                            <a href="#" title="<%= PowerUtils.localizeKey("got.it.description",currentLangBundle,frontendDefaultBundle,true, new String[]{String.valueOf(processo.getGamificationValues(Processo.GAMIFICATION_ACTIONS.GOT_IT_SECTION,String.valueOf(section.getId())).getTotal().intValue())}) %>" class="gotIt jsGotIt <% if (participante != null && participante.hasGotSection(section)) { %> alreadyGot <% }%> <% if (participante == null) { %> disabled <% } %>" data-id="<%=section.getId()%>">
                                <%= PowerUtils.localizeKey("action.got.it.section", currentLangBundle, frontendDefaultBundle, true, new String[]{"<img data-alternative=\"img/gold_badge.png\" src=\"img/gold_badge.svg\" alt=\"gold\" class=\"badgeImg badge\"/>"})%>
                            </a>
                        <% }%>
                    </div>
                    <% } %>
                    <% if((processo.getMapontop() == null || !processo.getMapontop()) && processo.getShapeUrl()!=null && !processo.getShapeUrl().isEmpty()) {%>
                    <div class="tabContent static" id="map">
                        <div class="title" <%= pm.isRtl() %>><%= PowerUtils.localizeKey("map",currentLangBundle,frontendDefaultBundle,true) %></div>
                        <iframe width="100%" height="auto" class="map" src="<%= pm.isMobileRequest() ? processo.getShapeMobileUrl() : processo.getShapeUrl()%>"></iframe>
                    </div>
                    <% }%>
                    <%
                        if (!documentosProcesso.isEmpty()) {
                    %>
                    <div class="tabContent static" id="documents">
                        <div class="title <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("documents",currentLangBundle,frontendDefaultBundle,true) %></div>
                        <ul class="documentList">
                            <% for (Documento documento : documentosProcesso) {
                                String size = documento.getSize() != null ? "[" + documento.getFileType() + " | " + ((documento.getSize() / 1048576f) >= 1.0 ? rounder.format(documento.getSize() / 1048576f) + "Mb]" : rounder.format(documento.getSize() / 1024f) + "Kb]") : "";%>
                            <li class="document">
                                <a class="<%= pm.isRtl() %>" title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.DOWNLOAD_DOCUMENT%>" target="<%=DataObjectUtils.pkForObject(documento).toString()%>"/>" onclick="POWERController.downloadFile('<%=documento.getId()%>', '<%=participante!=null?participante.getPointsGained(processo, String.valueOf(documento.getId()), Processo.GAMIFICATION_ACTIONS.DOWNLOAD_DOCUMENT):0%>', '<%=config.getServletContext().getInitParameter("server_href")%>')"><%= documento.getDesignacao()%></a> <span class="fileInfo <%= pm.isRtl() %>"><%= size %></span>
                            </li>
                            <%} %>
                        </ul>
                    </div>
                    <% }%>
                    <div class="tabContent static cmHolder" id="comments">
                        <div class="title <%= pm.isRtl() %>"><%= PowerUtils.getCommentsTitle(processo, currentLangBundle, frontendDefaultBundle) %></div>
                        <div class="description <%= pm.isRtl() %>"><%= PowerUtils.getCommentsDescription(processo, currentLangBundle, frontendDefaultBundle) %></div>
                        <jsp:include page="commentBox.jsp"/>
                    </div>
                    <div class="tabContent static" id="stats">
                        <div class="title <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("stats",currentLangBundle,frontendDefaultBundle,true) %></div>
                        <jsp:include page="statsPartialIndividual.jsp"/>
                    </div>
                </div>
            </div><!--
        --><div class="contentPartial side info">
                <h3 class="getInvolved <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("get.involved",currentLangBundle,frontendDefaultBundle,true) %></h3>
                <div class="actions">
                    <div class="action follow">
                        <svg enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m12 0c-6.627 0-12 5.373-12 12 0 6.628 5.373 12 12 12 6.628 0 12-5.372 12-12 0-6.627-5.372-12-12-12zm0 19.2c-5.964 0-10.8-3.224-10.8-7.2s4.836-7.199 10.8-7.199c5.965 0 10.801 3.224 10.801 7.199 0 3.977-4.836 7.2-10.801 7.2z" fill="#36c"/><circle cx="12.001" cy="12" fill="#36c" r="6"/><circle cx="12" cy="12" r="2.4"/></svg>
                        <a title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=Processo.GAMIFICATION_ACTIONS.FOLLOW_ISSUE%>"/>" class="actionName <%= pm.isRtl() %>"><%=jaSegue ? PowerUtils.localizeKey( "unfollow",currentLangBundle,frontendDefaultBundle,true) : PowerUtils.localizeKey("follow",currentLangBundle,frontendDefaultBundle,true)%></a>
                    </div>
                </div>
                <div class="actions">
                    <div class="action share">
                        <svg class="actionSvg" enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m19.801 15.601c-1.182 0-2.248.489-3.011 1.274l-8.445-4.223c.033-.213.056-.43.056-.651 0-.223-.022-.439-.056-.652l8.445-4.223c.764.785 1.829 1.274 3.011 1.274 2.319 0 4.199-1.88 4.199-4.2s-1.88-4.2-4.199-4.2c-2.32 0-4.2 1.881-4.2 4.2 0 .223.022.439.056.652l-8.446 4.223c-.763-.785-1.829-1.274-3.011-1.274-2.319 0-4.2 1.88-4.2 4.2 0 2.319 1.881 4.199 4.2 4.199 1.182 0 2.248-.489 3.011-1.274l8.445 4.223c-.033.213-.056.43-.056.652 0 2.319 1.88 4.199 4.2 4.199s4.2-1.88 4.2-4.199c0-2.321-1.88-4.2-4.199-4.2z" fill="#36c"/></svg>
                        <a href="#" class="actionName <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("share",currentLangBundle,frontendDefaultBundle,true) %></a>
                        <jsp:include page="sharePopup.jsp" />
                    </div>
                </div>
                <div class="section comments smallSection">
                    <h3 class="sectionTitle showComments <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("comments.and.tips",currentLangBundle,frontendDefaultBundle,true) %></h3>
                    <ul class="commentList">
                        <% List<RParticipanteComentario> comentarios = processo.getApprovedComments();
                            int size = comentarios.size();
                            new Ordering(RParticipanteComentario.DATA_PROPERTY, SortOrder.DESCENDING_INSENSITIVE).orderList(comentarios);
                            if (!comentarios.isEmpty()) {
                                if (comentarios.size() > 3) { comentarios = comentarios.subList(0,3);}
                                for (RParticipanteComentario comentario : comentarios) {%>
                        <li class="comment">
                            <p class="commentName"><%= comentario.getParticipante().getNome()%></p>
                            <tags:userImgTag participant="<%=comentario.getParticipante()%>"/>
                            <p class="date"><%= df.format(comentario.getData())%></p>
                            <p class="description <%= pm.isRtl() %>"><%= comentario.getComentario()%></p>
                        </li>
                        <% }}%>
                    </ul>
                    <a href="#" class="<%= pm.isRtl() %> showMore showComments <%if (size < 3) {%> hidden <% }else{%> hasMore <% }%>"><%= PowerUtils.localizeKey("post.see.all",currentLangBundle,frontendDefaultBundle,true) %></a>
                </div>
                <% if (processo.getFormularios().size() > 0 && open) {%>
                <div class="section surveys smallSection">
                    <h3 class="sectionTitle showSurveys"><%= PowerUtils.localizeKey("take.surveys",currentLangBundle,frontendDefaultBundle,true) %></h3>
                    <ul class="surveyList">
                        <% List<Formulario> forms = processo.getFormularios();
                            int fsize = forms.size();

                            if (forms.size() > 3) { forms = forms.subList(0,3);}
                            for(Formulario form : forms){
                                if(form.getDataAbertura() != null && form.getDataAbertura().before(hoje)){ %>
                                    <li class="survey jsSurvey" data-id="<%= form.getId() %>">
                                        <a class="description <%= pm.isRtl() %>"><%= form.getNome()%></a>
                                    </li>
                        <%  }}%>
                    </ul>
                    <a href="#" class="<%= pm.isRtl() %> register showSurveys <%if (fsize < 3) {%> hidden <% }else{%> hasMore <% }%>"><%= PowerUtils.localizeKey("register.see.all",currentLangBundle,frontendDefaultBundle,true) %> (<%= fsize %>)</a>
                </div>
                <% }%>
                <% if (processo.getEventos().size() > 0) {%>
                <div class="section events smallSection">
                    <h3 class="sectionTitle showEvents <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("events.to.attend",currentLangBundle,frontendDefaultBundle,true) %></h3>
                    <ul class="eventList">
                        <% List<Evento> eventos = processo.getEventos();
                            int esize = eventos.size();
                            if (eventos.size() > 3) { eventos = eventos.subList(0,3);}
                            if (!eventos.isEmpty()) {
                                for (Evento evento : eventos) { %>
                        <li class="event showEvents">
                            <p class="date"><%= df.format(evento.getData()) %></p>
                            <p class="description <%= pm.isRtl() %>"><%= evento.getDesignacao() %></p>
                        </li>
                        <% }
                        }%>
                    </ul>
                    <a href="#" class="<%= pm.isRtl() %> register showEvents <%if (esize < 3) {%> hidden <% }else{%> hasMore <% }%>"><%= PowerUtils.localizeKey("register.see.all",currentLangBundle,frontendDefaultBundle,true) %> (<%= esize %>)</a>
                </div>
                <% }%>
                <%
                    if(tweets!=null && !tweets.isEmpty()){ %>
                <div class="section twitter smallSection">
                    <h3 class="sectionTitle showMoreTweets <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("on.twitter",currentLangBundle,frontendDefaultBundle,true) %></h3>
                    <ul class="tweetList">
                        <%
                            int tsize = tweets.size();
                            if (tweets.size() > 3) { tweets = tweets.subList(0,3);}
                            for (Status tweet : tweets) { %>
                        <li class="tweet">
                            <p class="commentName <%= pm.isRtl() %>">@<%= tweet.getUser().getName()%></p><p class="date"><%= df.format(tweet.getCreatedAt())%></p>
                            <p class="description <%= pm.isRtl() %>"><%= tweet.getText()%></p>
                        </li>
                        <% }%>
                    </ul>
                    <a href="#" class="showMore showMoreTweets <%= pm.isRtl() %> <%if (tsize < 3) {%> hidden <% }else{%> hasMore <% }%>"><%= PowerUtils.localizeKey("see.all",currentLangBundle,frontendDefaultBundle,true) %> (<%= tsize %>)</a>
                </div>
                <% }%>
                <% if (!pm.isMobileRequest()) {%>
                    <div class="appPromotion">
                        <p class="appPromotionText"><%= PowerUtils.localizeKey("download.app",currentLangBundle,frontendDefaultBundle,true) %></p>
                        <a target="_blank" href="<%=application.getInitParameter("androidAppLink")%>" class="appStore android"></a>
                        <a href="#" class="appStore ios" title="Available Soon"></a>
                    </div>
                <% }%>
            </div>
        </div>
    </div>
</div>
<script>
    $(window).load(function(e){
        try {
            POWERController.gotIt();
            POWERController.initTabs(".tab", "active");
            POWERController.initScrollTitle(".intro.title");
            POWERController.initStickyMenu(".menu .tabs");
            POWERController.initScrollTab(".menu .tabs", ".tab", "active");
            POWERController.initScrollActions(".contentPartial.side.info");
            POWERController.initActions(".share", ".follow", ".actionName");
            POWERController.initEvents(".showEvents");
            POWERController.initSurveys(".jsSurvey", ".showSurveys");
            POWERController.initTweets(".showMoreTweets");
            POWERController.initComments(".showComments");
            POWERController.initMobileMenu(".showMenu", ".mobileMenu", "active");
            POWERController.initStickyInfo();
            var points_awarded = <%=request.getAttribute(RequestParameters.POINTS_AWARDED) != null ? request.getAttribute(RequestParameters.POINTS_AWARDED).toString() : "\"\""%>;
            checkPointsAward(points_awarded);
            POWERController.initReply();
            POWERController.triggerAppendable("<%= appendable %>", "<%= cId %>", "<%= rId %>");
            POWERController.initPagination();
            POWERController.initFormSubmit();
            POWERController.initBoxGrow();
            POWERController.initShowMap(".showMap");
            POWERController.setLinkGrabber(".HTMLContent:not(.noClean) *");
            POWERController.clearParams();
            POWERController.initChartClick(".chartClick");
        } catch (err) {
            POWERController.cleanHTMLContent(".HTMLContent:not(.noClean) *");
        }
    });
</script>
