<%@ tag import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ tag import="com.baseform.apps.power.participante.Participante" %>
<%@ tag import="java.util.Locale" %>
<%@ tag import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ attribute name="participant" type="com.baseform.apps.power.participante.Participante" required="true" %>
<%@ attribute name="height" type="java.lang.Integer" required="false" %>
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
    final PowerPubManager m = (PowerPubManager) PublicManager.get(request);
    request.setAttribute("systemId",m.getSystemId(request));
    request.setAttribute(Locale.class.getSimpleName(),m.getCurrentLocale());
    request.setAttribute(Participante.class.getSimpleName(),participant);
    request.setAttribute("heightForUserBadgeImg",height);
%><jsp:include page="/userBadgeImg.jsp" />