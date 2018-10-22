<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.baseform.apps.power.participante.GamificationValues" %>
<%@ page import="com.baseform.apps.power.participante.GamificationValues.GAMIFICATION_CATEGORIES" %>
<%@ page import="static com.baseform.apps.power.participante.GamificationValues.GAMIFICATION_CATEGORIES.*" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.cayenne.exp.ExpressionFactory" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteSistema" %>
<%@ page import="org.apache.cayenne.query.SelectQuery" %><%--
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
    PublicManager publicManager = PowerPubManager.get(request);
    Processo challenge = publicManager.getChallenge(publicManager.getDc(request));
    Participante participant = publicManager.getParticipant(publicManager.getDc(request));

    JSONObject jsonObject = new JSONObject();
    jsonObject.put("user", new JSONObject());
    jsonObject.put("challenge", new JSONObject());
    jsonObject.put("global", new JSONObject());

    if (participant != null) {
        JSONObject user = jsonObject.getJSONObject("user");
        user.put("id", participant.getId());
        user.put("name", participant.getNome());
        user.put("gamification", new JSONObject());
        JSONObject gamification = user.getJSONObject("gamification");
        GamificationValues gamificationValues = participant.getGamificationValues(publicManager.getSystemId(request));

        gamification.put(PERSONAL, new JSONObject());
        gamification.getJSONObject(PERSONAL).put(PRACTICAL_KNOWLEDGE, gamificationValues.getPersonalPracticalKnowledge());
        gamification.getJSONObject(PERSONAL).put(PROBLEM_AWARENESS, gamificationValues.getPersonalProblemAwareness());
        gamification.getJSONObject(PERSONAL).put(READY_FOR_ACTION, gamificationValues.getPersonalReadyForAction());

        gamification.put(SOCIAL, new JSONObject());
        gamification.getJSONObject(SOCIAL).put(PRACTICAL_KNOWLEDGE, gamificationValues.getSocialPracticalKnowledge());
        gamification.getJSONObject(SOCIAL).put(PROBLEM_AWARENESS, gamificationValues.getSocialProblemAwareness());
        gamification.getJSONObject(SOCIAL).put(READY_FOR_ACTION, gamificationValues.getSocialReadyForAction());

        gamification.put(POLITICAL, new JSONObject());
        gamification.getJSONObject(POLITICAL).put(PRACTICAL_KNOWLEDGE, gamificationValues.getPoliticalPracticalKnowledge());
        gamification.getJSONObject(POLITICAL).put(PROBLEM_AWARENESS, gamificationValues.getPoliticalProblemAwareness());
        gamification.getJSONObject(POLITICAL).put(READY_FOR_ACTION, gamificationValues.getPoliticalReadyForAction());
    }

    if (challenge != null) {
        JSONObject challenge1 = jsonObject.getJSONObject("challenge");
        challenge1.put("id", challenge.getId());
        challenge1.put("code", challenge.getCodigo());
        challenge1.put("title", challenge.getTitulo());
        challenge1.put("gamification", new JSONObject());
        JSONObject gamification1 = challenge1.getJSONObject("gamification");

        GamificationValues gamificationValues1 = challenge.getGamificationValues();

        gamification1.put(PERSONAL, new JSONObject());
        gamification1.getJSONObject(PERSONAL).put(PRACTICAL_KNOWLEDGE, gamificationValues1.getPersonalPracticalKnowledge());
        gamification1.getJSONObject(PERSONAL).put(PROBLEM_AWARENESS, gamificationValues1.getPersonalProblemAwareness());
        gamification1.getJSONObject(PERSONAL).put(READY_FOR_ACTION, gamificationValues1.getPersonalReadyForAction());

        gamification1.put(SOCIAL, new JSONObject());
        gamification1.getJSONObject(SOCIAL).put(PRACTICAL_KNOWLEDGE, gamificationValues1.getSocialPracticalKnowledge());
        gamification1.getJSONObject(SOCIAL).put(PROBLEM_AWARENESS, gamificationValues1.getSocialProblemAwareness());
        gamification1.getJSONObject(SOCIAL).put(READY_FOR_ACTION, gamificationValues1.getSocialReadyForAction());

        gamification1.put(POLITICAL, new JSONObject());
        gamification1.getJSONObject(POLITICAL).put(PRACTICAL_KNOWLEDGE, gamificationValues1.getPoliticalPracticalKnowledge());
        gamification1.getJSONObject(POLITICAL).put(PROBLEM_AWARENESS, gamificationValues1.getPoliticalProblemAwareness());
        gamification1.getJSONObject(POLITICAL).put(READY_FOR_ACTION, gamificationValues1.getPoliticalReadyForAction());
    }

    JSONObject global = jsonObject.getJSONObject("global");
    final List<Participante> listParticipante = publicManager.getDc(request).performQuery(new SelectQuery(Participante.class, ExpressionFactory.matchExp(Participante.ACTIVO_PROPERTY, true)
            .andExp(ExpressionFactory.matchExp(Participante.PARTICIPACAO_SISTEMA_PROPERTY + "." + RParticipanteSistema.FKSISTEMA_PROPERTY, publicManager.getSystemId(request)))
            .andExp(ExpressionFactory.matchExp(Participante.ACTIVO_PROPERTY, true))));
    global.put("participants", listParticipante.size());

    int activeUsers = 0;
    for (Participante participante : listParticipante) {
        try {
            if (!participante.getGamificationValues(publicManager.getSystemId(request)).isEmpty()) activeUsers++;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    global.put("active_users", activeUsers);
    global.put("gamification", new JSONObject());


    final GamificationValues overallValues = GamificationValues.getGamificationValuesForSystem(publicManager.getSystemId(request), publicManager.getDc(request));
    JSONObject gamification2 = global.getJSONObject("gamification");
    gamification2.put(PERSONAL, new JSONObject());
    gamification2.getJSONObject(PERSONAL).put(PRACTICAL_KNOWLEDGE, overallValues.getPersonalPracticalKnowledge());
    gamification2.getJSONObject(PERSONAL).put(PROBLEM_AWARENESS, overallValues.getPersonalProblemAwareness());
    gamification2.getJSONObject(PERSONAL).put(READY_FOR_ACTION, overallValues.getPersonalReadyForAction());

    gamification2.put(SOCIAL, new JSONObject());
    gamification2.getJSONObject(SOCIAL).put(PRACTICAL_KNOWLEDGE, overallValues.getSocialPracticalKnowledge());
    gamification2.getJSONObject(SOCIAL).put(PROBLEM_AWARENESS, overallValues.getSocialProblemAwareness());
    gamification2.getJSONObject(SOCIAL).put(READY_FOR_ACTION, overallValues.getSocialReadyForAction());

    gamification2.put(POLITICAL, new JSONObject());
    gamification2.getJSONObject(POLITICAL).put(PRACTICAL_KNOWLEDGE, overallValues.getPoliticalPracticalKnowledge());
    gamification2.getJSONObject(POLITICAL).put(PROBLEM_AWARENESS, overallValues.getPoliticalProblemAwareness());
    gamification2.getJSONObject(POLITICAL).put(READY_FOR_ACTION, overallValues.getPoliticalReadyForAction());
%><%= jsonObject %>