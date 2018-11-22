<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteComentario" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="org.apache.cayenne.query.Ordering" %>
<%@ page import="org.apache.cayenne.query.SortOrder" %>
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
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
    boolean open = true;
    DateFormat df = new SimpleDateFormat("dd MMMM yyyy - K:m a", Locale.US);

    List<RParticipanteComentario> comments =  new ArrayList<>(processo.getApprovedAll(participante));
    Collections.sort(comments, getrParticipanteComentarioComparator());
    int commentsSize = comments.size();

    DecimalFormat rounder = new DecimalFormat("#.##");

    int offset = PowerPubManager.pagination;
    int i = 0;

    String cId = request.getParameter(RequestParameters.COMENTAR);
    if ((cId == null || cId.equals("")) && request.getParameter("cId") != null) cId = request.getParameter("cId");

    if (cId != null && cId.length() > 0) {
        RParticipanteComentario pC = DataObjectUtils.objectForPK(pm.getDc(request), RParticipanteComentario.class, cId);

        for (RParticipanteComentario comment : comments) {
            if (comment.equals(pC)) break;
            i++;
        }
        comments = comments.subList(0,i);
    } else {
        if (commentsSize > offset)
            comments = comments.subList(0, offset);
    }

    final String currentSystem = pm.getSystemId(request);
    int currentPage = i == 0 ? 1 : Double.valueOf(Math.ceil(i/offset)).intValue();

    HashMap<String, List<RParticipanteComentario>> contents = new HashMap<>();
    contents.put("all", comments);

    HashMap<String, String> keys = new HashMap<>();
    keys.put("comment", "comments");

    HashMap<String, Integer> sizes = new HashMap<>();
    sizes.put("comment", commentsSize);

    long ts = new Date().getTime();
%>
<link href="redesign_css/commentBox.css" rel="stylesheet" type="text/css">
<link href="redesign_css/account.css" rel="stylesheet" type="text/css">
<% if (!open) { %>
<h3 class="notFollowing"><%=PowerUtils.localizeKey("msg.comment.closed",currentLangBundle,frontendDefaultBundle)%></h3>
<% }%>
<% for (String s : contents.keySet()) {
    List<RParticipanteComentario> commentList = processo.getCommentsAndTips(ts, participante, response);
    if (commentList.size() == 0 && !open) continue; %>

<% if(open) {%>
<form class="comments <%= s %>" action="./?<%=RequestParameters.COMENTAR%>" enctype="multipart/form-data" method="post" accept-charset="utf-8" autocomplete="off">
    <input type="hidden" name="tipo" class="tId" value="comment"/>

    <input type="hidden" name="loginEmail"/>
    <input type="hidden" name="loginPassword"/>
    <input type="hidden" name="isReply" value="false"/>
    <input type="hidden" name="process" class="pId" value="<%=processo.getId()%>"/>
    <input type="text" name="title" class="boxCommentTitle" placeholder="<%=PowerUtils.localizeKey("write.comment.title",currentLangBundle,frontendDefaultBundle)%>">
    <textarea class="boxComment" name="<%=RequestParameters.COMENTARIO%>" placeholder="<%=PowerUtils.localizeKey("write.comment",currentLangBundle,frontendDefaultBundle)%>"></textarea><!--
                --><div class="actions">
    <label for="commentPhotoCall">
        <input id="commentPhotoCall" type="file" name="photo" accept='image/*;capture=camera' onchange="$('#photoNameall').html($(this).val().replace('C:\\fakepath\\',''));"/>
    </label>
    <span id="photoNameall" class="photoName"> </span>
    <a href="#"
       class="sendComment"
       data-participante="<%= participante != null %>"
       title="<tags:gamificationPointsForActionTag issue="<%=processo%>" action="<%=s.equals("tip")?Processo.GAMIFICATION_ACTIONS.TIP:Processo.GAMIFICATION_ACTIONS.COMMENT%>"/>"
    ><%=PowerUtils.localizeKey("submit",currentLangBundle,frontendDefaultBundle)%></a>
</div>
</form>
<%}%>

<div class="commentListPage" data-page="<%= currentPage %>" data-type="<%= s %>">
    <div class="newComments newCommentsAlert hidden" >
        <h3 class="newCommentsCopy">You have <span class="count"></span> new comments.</h3>
        <a class="reloadComments page" data-page="1" data-type="<%= s %>" href="#">click here to load them.</a>
    </div>
    <ul class="commentList appendComments">
        <%
            Integer j = 0;
            for (RParticipanteComentario comment : commentList) {  %>
        <li class="comment  status<%= comment.getStatus() %> <% if (participante != null && j == 0) { %>firstComment<% }j++;%>" data-id="<%= comment.getId() %>">
            <img src="<%= comment.getParticipante() != null && comment.getParticipante().getImagem() != null ? "./user_avatar?id="+comment.getParticipante().getImagem().getId() : "redesign_images/user.png" %>" alt="user" class="userImage">
            <div class="commentInfo">
                <% if (comment.getTitle().length() > 0) {%> <p class="commentTitle"><%= comment.getTitle() %></p><!--
                --><% }%><p class="commentName"><%= comment.getParticipante().getSafeNome()%></p><!--
                --><tags:userImgTag participant="<%=comment.getParticipante()%>"/><span class="date"><%= df.format(comment.getData()) %></span><!--
                -->
                <a download href="#" target="blank" class="description noAttachment"><%= comment.getComentario()%></a>
                <% if (comment.getFicheiro() != null && comment.getFicheiro().getSize() != null) {%>
                <% if (comment.getFicheiro().getMime().contains("image")) { %>
                <img src="/comment?id=<%= comment.getFicheiro().getId() %>" class="commentPhoto">
                <% }%>
                <a href="/comment?id=<%= comment.getFicheiro().getId()%>" target="blank" class="fileInfo"><%= comment.getFicheiro().getNomeFicheiro()%> - <%= "[" + ((comment.getFicheiro().getSize() / 1048576f) >= 1.0 ? rounder.format(comment.getFicheiro().getSize() / 1048576f) + "Mb]" : rounder.format(comment.getFicheiro().getSize() / 1024f) + "Kb]")%></a>
                <% }%>
                <% if (comment.getStatus() != RParticipanteComentario.APPROVED) { %>
                <span class="status">
                    <% if (comment.getStatus() == RParticipanteComentario.PENDING_APPROVAL) {%>
                        <%=PowerUtils.localizeKey("pending.approval",currentLangBundle,frontendDefaultBundle)%>
                    <% } else {%>
                        <%=PowerUtils.localizeKey("removed",currentLangBundle,frontendDefaultBundle)%>
                    <% }%>
                    </span>
                <% }%>
            </div><% if (comment.getStatus() == RParticipanteComentario.APPROVED) { %><!--
            --><div class="actionButtons">
            <% if (open) {%><a id="reply_<%= comment.getId() %>" data-id="<%= comment.getId() %>" data-count="<%= comment.getApprovedResponse().size() %>" class="actionLink reply"><%=PowerUtils.localizeKey("action.comment",currentLangBundle,frontendDefaultBundle)%> (<%= comment.getApprovedResponse().size()%>)</a><%}%><!--
            --><a id="like_<%= comment.getId() %>" class="actionLink like  enabled_<%= open %>" <% if (open && participante != null) {%>onclick="like(<%= comment.getId() %>)"<% }%>><%= comment.getLikes() %></a><!--
            --><div class="action share" data-extra="&cId=<%= comment.getId() %>">
            <svg class="actionSvg" enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m19.801 15.601c-1.182 0-2.248.489-3.011 1.274l-8.445-4.223c.033-.213.056-.43.056-.651 0-.223-.022-.439-.056-.652l8.445-4.223c.764.785 1.829 1.274 3.011 1.274 2.319 0 4.199-1.88 4.199-4.2s-1.88-4.2-4.199-4.2c-2.32 0-4.2 1.881-4.2 4.2 0 .223.022.439.056.652l-8.446 4.223c-.763-.785-1.829-1.274-3.011-1.274-2.319 0-4.2 1.88-4.2 4.2 0 2.319 1.881 4.199 4.2 4.199 1.182 0 2.248-.489 3.011-1.274l8.445 4.223c-.033.213-.056.43-.056.652 0 2.319 1.88 4.199 4.2 4.199s4.2-1.88 4.2-4.199c0-2.321-1.88-4.2-4.199-4.2z" fill="#36c"/></svg>
            <a href="#" class="actionName <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("share",currentLangBundle,frontendDefaultBundle,true) %></a>
            <jsp:include page="sharePopup.jsp" />
            </div>
        </div>
            <% }%>
            <div class="comments replyBox hidden">
                <% if (true) {%>
                <form action="./?<%=RequestParameters.COMENTAR%>=<%= comment.getId() %>" enctype="multipart/form-data" method="post" accept-charset="utf-8" autocomplete="off">
                    <input type="hidden" name="process" class="pId" value="<%=processo.getId()%>"/>
                    <input type="hidden" name="responseTo" class="cId" value="<%=comment.getId()%>"/>
                    <input type="hidden" name="loginEmail"/>
                    <input type="hidden" name="loginPassword"/>
                    <input type="hidden" name="isReply" value="true"/>
                    <input type="text" name="title" class="boxCommentTitle" placeholder="<%=PowerUtils.localizeKey("write.comment.title",currentLangBundle,frontendDefaultBundle)%>">
                    <textarea class="boxComment" name="<%=RequestParameters.COMENTARIO%>" placeholder="<%=PowerUtils.localizeKey("write.comment",currentLangBundle,frontendDefaultBundle)%>"></textarea><!--
                    --><div class="actions">
                    <label><input  type="file" name="photo" accept="image/*"  onchange="$(this).closest('form').find('.photoName').html($(this).val().replace('C:\\fakepath\\',''));"/></label>
                    <span class="photoName"> </span>
                    <a href="#" class="sendComment" data-participante="<%= participante != null %>"><%=PowerUtils.localizeKey("submit",currentLangBundle,frontendDefaultBundle)%></a>
                </div>
                </form>
                <% }%>
                <ul class="commentList appendResponses">
                    <% Integer responsePage = 0;
                        List<RParticipanteComentario> replies = comment.getResponsePaginated(responsePage, pm.pagination, participante, response, ts);
                        new Ordering(RParticipanteComentario.DATA_PROPERTY, SortOrder.DESCENDING_INSENSITIVE).orderList(replies);
                        Integer k = 0;
                        for (RParticipanteComentario reply : replies) {  %>
                    <li class="comment status<%= reply.getStatus() %> <% if (participante != null && k == 0) { %>firstComment<% }k++;%>"  data-id="<%= reply.getId()%>">
                        <img src="<%= reply.getParticipante() != null && reply.getParticipante().getImagem() != null ? "./user_avatar?id="+reply.getParticipante().getImagem().getId() : "redesign_images/user.png" %>" alt="user" class="userImage">
                        <div class="commentInfo">
                            <% if (reply.getTitle().length() > 0) {%> <p class="commentTitle"><%= reply.getTitle() %></p><!--
                            --><% }%><p class="commentName"><%= reply.getParticipante().getSafeNome()%></p><!--
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
                        <a id="like_<%= reply.getId() %>" class="actionLink like enabled_<%= open %>" <% if (open && participante != null) {%>onclick="like(<%= reply.getId() %>)"<% }%>><%= reply.getLikes() %></a><!--
                        --><div class="action share" data-extra="&cId=<%= comment.getId() %>&rId=<%= reply.getId() %>">
                        <svg class="actionSvg" enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="m19.801 15.601c-1.182 0-2.248.489-3.011 1.274l-8.445-4.223c.033-.213.056-.43.056-.651 0-.223-.022-.439-.056-.652l8.445-4.223c.764.785 1.829 1.274 3.011 1.274 2.319 0 4.199-1.88 4.199-4.2s-1.88-4.2-4.199-4.2c-2.32 0-4.2 1.881-4.2 4.2 0 .223.022.439.056.652l-8.446 4.223c-.763-.785-1.829-1.274-3.011-1.274-2.319 0-4.2 1.88-4.2 4.2 0 2.319 1.881 4.199 4.2 4.199 1.182 0 2.248-.489 3.011-1.274l8.445 4.223c-.033.213-.056.43-.056.652 0 2.319 1.88 4.199 4.2 4.199s4.2-1.88 4.2-4.199c0-2.321-1.88-4.2-4.199-4.2z" fill="#36c"/></svg>
                        <a href="#" class="actionName <%= pm.isRtl() %>"><%= PowerUtils.localizeKey("share",currentLangBundle,frontendDefaultBundle,true) %></a>
                        <jsp:include page="sharePopup.jsp" />
                    </div>
                    </div>
                        <% }%>
                    </li>
                    <% } %>
                    <% if (replies.size() == pm.pagination) { %>
                    <a href="#" class="loadMoreC loadMoreResponses" data-id="<%= comment.getId() %>" data-page="<%= responsePage + 1 %>">Load More...</a>
                    <% } %>
                </ul>
            </div>
        </li>
        <% }%>
    </ul>
</div>
<%}%>
<%!
    private Comparator<RParticipanteComentario> getrParticipanteComentarioComparator() {
        return (o1, o2) -> {
            int likes = new Integer(o1.getLikes() - o1.getDislikes()).compareTo(o2.getLikes() - o2.getDislikes());
            if(likes==0)
                return o1.getData().compareTo(o2.getData());
            return likes;
        };
    }
%>
<%
    final PowerPubManager m = (PowerPubManager) PublicManager.get(request);

%>
<script>
    window.ts = <%= ts %>;
</script>