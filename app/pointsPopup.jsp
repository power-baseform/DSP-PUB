<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.baseform.apps.power.participante.GamificationValues" %>
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
    final ResourceBundle _frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle _currentLangBundle = pm.getCurrentLangBundle();
    JSONObject params = new JSONObject(request.getParameter("params"));

    Integer total = 0;
    Integer personal = 0;
    Integer political = 0;
    Integer social = 0;

    for (Iterator it = params.keys(); it.hasNext(); ) {
        String d = (String) it.next();

        total += Integer.valueOf(params.getString(d));

        if(d.indexOf("cat.personal")==0)
            personal += Integer.valueOf(params.getString(d));
        if(d.indexOf("cat.political")==0)
            political += Integer.valueOf(params.getString(d));
        if(d.indexOf("cat.social")==0)
            social += Integer.valueOf(params.getString(d));
    }
%>

<div class="overlay"></div>
<div class="popup popupLogin">
    <a class="closePopup" href="#"></a>
    <div class="points">
        <%=PowerUtils.localizeKey("points.awarded",_currentLangBundle,_frontendDefaultBundle, new String[]{total.toString()})%>
        <ul class="communityDimensionsHome">
            <li class="blue"><%=PowerUtils.localizeKey("cat.personal.impact",_currentLangBundle,_frontendDefaultBundle,true)%> : <%=personal%></li>
            <li class="green"><%=PowerUtils.localizeKey("cat.social.impact",_currentLangBundle,_frontendDefaultBundle,true)%> : <%=social%></li>
            <li class="red"><%=PowerUtils.localizeKey("cat.political.impact",_currentLangBundle,_frontendDefaultBundle,true)%> : <%=political%></li>
        </ul>
    </div>
</div>