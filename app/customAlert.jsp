<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
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
    String str = request.getParameter("str");

    Integer rand = Double.valueOf(Math.random() * 99 + 1).intValue();
%>

<div class="popup popupLogin onTop grid" data-id="p_<%= rand %>">
    <a class="closePopup" href="#"></a>
    <p><%= str %></p>
</div>

<script>
    setTimeout(function(e) {
        $(".popup[data-id='p_<%= rand %>']").removeClass("positioned");
        setTimeout(function(e) {
            $(".popup[data-id='p_<%= rand %>']").remove();
        }, 1500);
    }, 6000);
</script>