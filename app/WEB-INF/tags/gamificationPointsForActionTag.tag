<%@ tag trimDirectiveWhitespaces="true" %>
<%@ tag import="com.baseform.apps.power.PowerUtils" %>
<%@ tag import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ tag import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ tag import="com.baseform.apps.power.participante.GamificationValues" %>
<%@ tag import="java.util.ResourceBundle" %>
<%@ attribute name="issue" type="com.baseform.apps.power.processo.Processo" required="true" %>
<%@ attribute name="target" type="java.lang.String" required="false" %>
<%@ attribute name="extended" type="java.lang.Boolean" required="false" %>
<%@ attribute name="action" type="com.baseform.apps.power.processo.Processo.GAMIFICATION_ACTIONS" required="true" %><%--
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

    final PowerPubManager m = (PowerPubManager) PublicManager.get(request);
    final GamificationValues vals = target!=null && !target.trim().isEmpty()
            ? issue.getGamificationValues(action,target)
            : issue.getGamificationValues(action);
    final ResourceBundle defBundle = m.getDefaultLangBundle();
    final ResourceBundle currBundle = m.getCurrentLangBundle();
    if(extended!=null&&extended){
        out.print(
                PowerUtils.localizeKey(GamificationValues.GAMIFICATION_CATEGORIES.PERSONAL, currBundle, defBundle)+": "+vals.getPersonal().intValue()+" "
                +PowerUtils.localizeKey(GamificationValues.GAMIFICATION_CATEGORIES.SOCIAL, currBundle, defBundle)+": "+vals.getSocial().intValue()+" "
                +PowerUtils.localizeKey(GamificationValues.GAMIFICATION_CATEGORIES.POLITICAL, currBundle, defBundle)+": "+vals.getPolitical().intValue());
    } else out.print(vals.getTotal().intValue()+" "+PowerUtils.localizeKey("points", currBundle, defBundle));
%>