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

<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %><%--
  Created by IntelliJ IDEA.
  User: joaofeio
  Date: 13/02/17
  Time: 09:43
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<%
    final PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    if(pm != null)
        pm.processClickOnLink(request);
%>
<script>
    $(document).ready(function() {
        <%
        if(pm!=null && pm.getParticipante()!=null){
        %>
        var points_awarded = '<%=pm.getParticipante().getPointsGained(DataObjectUtils.objectForPK(pm.getDc(request),Processo.class, request.getParameter("p")), request.getParameter(RequestParameters.CLICK_LINK), Processo.GAMIFICATION_ACTIONS.CLICK_LINK)%>';

        if(points_awarded > 0) {
            alert("You have been awarded " + points_awarded + " points for your participation!");
        }
        <%
        }
        %>

        go('<%=request.getParameter(RequestParameters.CLICK_LINK)%>');
    });
</script>
</html>
