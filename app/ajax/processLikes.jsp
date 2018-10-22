<%@ page import="com.baseform.apps.power.participante.RParticipanteComentario" %>
<%@ page import="com.baseform.apps.power.participante.RLikeComentario" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.baseform.apps.power.json.JSONArray" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="org.apache.cayenne.ObjectContext" %><%--
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

<%--
  Created by IntelliJ IDEA.
  User: joaofeio
  Date: 29/05/17
  Time: 16:25
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    PublicManager pm = PublicManager.get(request);
    JSONArray output = new JSONArray();
    JSONObject ret = new JSONObject();
    ObjectContext oc = pm.getDc(request);

    if(request.getParameter(RequestParameters.LIKE)!=null){
        RParticipanteComentario comentario = DataObjectUtils.objectForPK(oc, RParticipanteComentario.class, request.getParameter(RequestParameters.LIKE));
        if(comentario != null) {
            like(request, comentario, pm,oc);
            ret.put("likes", comentario.getLikes());
            ret.put("dislikes", comentario.getDislikes());
        }
        out.println(output.put(ret).toString(2));
    }
    if(request.getParameter(RequestParameters.DISLIKE)!=null){
        RParticipanteComentario comentario = DataObjectUtils.objectForPK(oc, RParticipanteComentario.class, request.getParameter(RequestParameters.DISLIKE));
        if(comentario != null) {
            dislike(request, comentario, pm,oc);
            ret.put("likes", comentario.getLikes());
            ret.put("dislikes", comentario.getDislikes());
        }
        out.println(output.put(ret).toString(2));
    }
%>
<%!
    public int like (HttpServletRequest request, RParticipanteComentario comentario, PublicManager pm, ObjectContext oc){

        RLikeComentario like = RLikeComentario.getLikeForComentario(pm.getParticipant(oc), comentario);
        if(like != null && like.getScore() != 0)
        {
            if(like.getScore() == 1)
            {
                comentario.setLikes(comentario.getLikes() - 1);
                pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.LIKE), Processo.GAMIFICATION_ACTIONS.REMOVE_LIKE,request);
                like.setScore(0);
            }
            else if (like.getScore() == -1)
            {
                comentario.setDislikes(comentario.getDislikes() - 1);
                pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.DISLIKE),Processo.GAMIFICATION_ACTIONS.REMOVE_DISLIKE,request);
                comentario.setLikes(comentario.getLikes() + 1);
                pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.LIKE),Processo.GAMIFICATION_ACTIONS.LIKE,request);
                like.setScore(1);
            }
        }
        else {
            if(like == null) {
                like = oc.newObject(RLikeComentario.class);
                like.setParticipante(pm.getParticipant(oc));
                like.setComentario(comentario);
            }
            comentario.setLikes(comentario.getLikes() + 1);
            like.setScore(1);
            pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.LIKE),Processo.GAMIFICATION_ACTIONS.LIKE,request);
        }

        pm.getDc(request).commitChanges();
        return comentario.getLikes();
    }

    public int dislike (HttpServletRequest request, RParticipanteComentario comentario, PublicManager pm, ObjectContext oc){
        RLikeComentario dislike = RLikeComentario.getLikeForComentario(pm.getParticipant(oc), comentario);
        if(dislike != null && dislike.getScore() != 0)
        {
            if(dislike.getScore() == 1)
            {
                comentario.setLikes(comentario.getLikes() - 1);
                pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.DISLIKE),Processo.GAMIFICATION_ACTIONS.REMOVE_LIKE,request);
                comentario.setDislikes(comentario.getDislikes() + 1);
                pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.DISLIKE),Processo.GAMIFICATION_ACTIONS.DISLIKE,request);
                dislike.setScore(-1);
            }
            else if (dislike.getScore() == -1)
            {
                comentario.setDislikes(comentario.getDislikes() - 1);
                pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.DISLIKE),Processo.GAMIFICATION_ACTIONS.REMOVE_DISLIKE,request);
                dislike.setScore(0);
            }
        }
        else {
            if(dislike == null) {
                dislike = oc.newObject(RLikeComentario.class);
                dislike.setParticipante(pm.getParticipant(oc));
                dislike.setComentario(comentario);
            }
            comentario.setDislikes(comentario.getDislikes() + 1);
            dislike.setScore(-1);
            pm.getParticipant(oc).logAction(pm.getChallenge(oc), request.getParameter(RequestParameters.DISLIKE),Processo.GAMIFICATION_ACTIONS.DISLIKE,request);
        }

        oc.commitChanges();
        return comentario.getDislikes();
    }
%>
