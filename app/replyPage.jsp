<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteComentario" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="org.apache.cayenne.query.Ordering" %>
<%@ page import="org.apache.cayenne.query.SortOrder" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="tags" tagdir="/WEB-INF/tags" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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
    Long ts = request.getParameter("timestamp") != null ? Long.valueOf(request.getParameter("timestamp")) : null ;
    Participante participante = pm.getParticipante();

    RParticipanteComentario comment = DataObjectUtils.objectForPK(pm.getDc(request), RParticipanteComentario.class, request.getParameter("comment"));
    List<RParticipanteComentario> replies = request.getParameter("page") != null ? comment.getResponsePaginated(Integer.valueOf(request.getParameter("page")), pm.pagination, participante, response, ts) : comment.getNewApprovedResponsePaginated(ts);
    final String currentSystem = pm.getSystemId(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
    DecimalFormat rounder = new DecimalFormat("#.##");

    boolean open = true;
    DateFormat df = new SimpleDateFormat("dd MMMM yyyy - K:m a", Locale.US);

    new Ordering(RParticipanteComentario.DATA_PROPERTY, SortOrder.DESCENDING_INSENSITIVE).orderList(replies);
    for (RParticipanteComentario reply : replies) {  %>
<li class="comment status<%= reply.getStatus() %>" data-id="<%= reply.getId()%>">
    <img src="<%= reply.getParticipante() != null && reply.getParticipante().getImagem() != null ? "./user_avatar?id="+reply.getParticipante().getImagem().getId() : "redesign_images/user.png" %>" alt="user" class="userImage">
    <div class="commentInfo">
        <p class="commentName"><%= reply.getParticipante().getNome()%></p><!--
                        --><tags:userImgTag participant="<%=reply.getParticipante()%>"/><span class="date"><%= df.format(reply.getData()) %></span>
        <a download href="#" target="blank" class="description noAttachment"><%= reply.getComentario()%></a>
        <% if (reply.getFicheiro() != null && reply.getFicheiro().getSize() != null) {%>
        <% if (reply.getFicheiro().getMime().contains("image")) { %>
        <img src="/comment?id=<%= reply.getFicheiro().getId() %>" class="commentPhoto">
        <% }%>
        <a href="/comment?id=<%= reply.getFicheiro().getId()%>" target="blank" class="fileInfo"><%= reply.getFicheiro().getNomeFicheiro()%> - <%= "[" + ((reply.getFicheiro().getSize() / 1048576f) >= 1.0 ? rounder.format(reply.getFicheiro().getSize() / 1048576f) + "Mb]" : rounder.format(reply.getFicheiro().getSize() / 1024f) + "Kb]")%></a>
        <% }%>
        <% if (reply.getStatus() != RParticipanteComentario.APPROVED) { %>
            <span class="status">
            <% if (reply.getStatus() == RParticipanteComentario.PENDING_APPROVAL) {%>
                <%=PowerUtils.localizeKey("pending.approval",currentLangBundle,frontendDefaultBundle)%>
            <% } else {%>
                <%=PowerUtils.localizeKey("removed",currentLangBundle,frontendDefaultBundle)%>
            <% }%>
            </span>
        <% }%>
    </div><% if (reply.getStatus() == RParticipanteComentario.APPROVED) { %><!--
    --><div class="actionButtons">
    <a id="like_<%= reply.getId() %>" class="actionLink like enabled_<%= open %>" <% if (open && participante != null) {%>onclick="like(<%= reply.getId() %>)"<% }%>><%=PowerUtils.localizeKey("like",currentLangBundle,frontendDefaultBundle)%> (<%= reply.getLikes() %>)</a><!--
                        --><a id="dislike_<%= reply.getId() %>" class="actionLink enabled_<%= open %>" <% if (open && participante != null) {%>onclick="dislike(<%= reply.getId() %>)"<% }%>><%=PowerUtils.localizeKey("dislike",currentLangBundle,frontendDefaultBundle)%> (<%= reply.getDislikes() %>)</a>
</div>
    <% }%>
</li>
<% } %>