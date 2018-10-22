<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
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
    final PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();

    final boolean showAlerta = ((pm.getErros() != null && !pm.getErros().isEmpty()) || (pm.getMsg() != null && !pm.getMsg().isEmpty()));
    final boolean showAlertaEvento = request.getParameter("goEvento")!=null;
    if(showAlerta){
%>
<script type="text/javascript">
    <% if (pm.getErros() != null && !pm.getErros().isEmpty() && !pm.getFailedLogin()) { %>
        POWERController.customAlert('<%=PowerUtils.localizeKey("alert",currentLangBundle,frontendDefaultBundle)%>: <%=StringEscapeUtils.escapeJavaScript(pm.getErros())%>');
    <% } else if (pm.getMsg() != null && !pm.getMsg().isEmpty()) { %>
        POWERController.customAlert('<%=PowerUtils.localizeKey("message",currentLangBundle,frontendDefaultBundle)%>: <%=StringEscapeUtils.escapeJavaScript(pm.getMsg())%>');
    <% } else if (pm.getFailedLogin()) {
       pm.setFailedLogin(false);
    }%>
</script>
<%
} else if(showAlertaEvento){
%>
<div id="popContainer" onclick="$(this).fadeOut()" style="display:block">
    <div id="popCenter">
        <div id="popAlerta">
            <%=PowerUtils.localizeKey("msg.login.to.join",currentLangBundle,frontendDefaultBundle)%>
            <a href="./?location=login" style="color:#fff"><%=PowerUtils.localizeKey("here",currentLangBundle,frontendDefaultBundle)%></a>
        </div>
    </div>
</div>
<script type="text/javascript">
    setTimeout(function(){
        $("#popContainer").fadeOut("slow");
    },2000)
</script>
<%
    }
%>




