<%@ page import="com.baseform.apps.power.json.JSONArray" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.caucho.server.admin.RemoveUserQuery" %>
<%@ page import="org.apache.cayenne.ObjectContext" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="java.util.List" %>
<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="org.apache.cayenne.access.DataContext" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="org.apache.cayenne.query.SelectQuery" %>
<%@ page import="org.apache.cayenne.exp.ExpressionFactory" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.baseform.apps.power.utils.SmartRequest" %>
<%@ page import="com.sun.org.apache.regexp.internal.RE" %>
<%@ page import="java.util.concurrent.locks.ReadWriteLock" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %><%--
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
    String api = request.getParameter("api");
    JSONArray res = new JSONArray();

    DataContext dataContext = DataContext.createDataContext();
    String current_system = request.getServletContext().getInitParameter("current_system");

    response.setContentType("application/json");
    response.setStatus(200);

    if (api.equals("challenges")) {
        List<Processo> issueList = dataContext.performQuery(new SelectQuery(Processo.class, ExpressionFactory.matchExp(Processo.SISTEMA_PROPERTY, current_system).andExp(ExpressionFactory.matchExp(Processo.PUBLICADO_PROPERTY, true))));
        for (Processo processo : issueList) {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("id", processo.getId());
            jsonObject.put("title", processo.getTitulo());
            res.put(jsonObject);
        }
    }else if (api.equals("comment")) {
        SmartRequest smartRequest = new SmartRequest(request);
        PowerPubManager powerPubManager = (PowerPubManager)PublicManager.get(request);
        powerPubManager.createCommentFromApp(smartRequest);

        JSONObject respo = new JSONObject();
        respo.put("status", "success");
        %><%= respo %><% return;
    }
%><%=res%>