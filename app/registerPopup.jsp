<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="java.util.ResourceBundle" %>
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
    boolean erros = false;
    if (pm.getErros()!=null && !pm.getErros().isEmpty())
        erros = true;

    final ResourceBundle _frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle _currentLangBundle = pm.getCurrentLangBundle();

    String email = request.getParameter("email") != null ? request.getParameter("email") : "";
    String pwd = request.getParameter("pwd") != null ? request.getParameter("pwd") : "";
%>
<div class="overlay"></div>
<form accept-charset="utf-8" method="post" action="./?location=<%= pm.getCurrentLocationName()%>&<%=RequestParameters.REGISTO%>" class="popup popupLogin" autocomplete="off">
    <a class="closePopup" href="#">x</a>

    <label for="registerName"><%=PowerUtils.localizeKey("name",_currentLangBundle,_frontendDefaultBundle)%></label>
    <input value="<%= pm.getRegisterValueFor(Participante.EMAIL_PROPERTY, request)%>" type="text" id="registerName" autocomplete="off"  name="<%= Participante.NOME_PROPERTY %>" placeholder="<%= PowerUtils.localizeKey("name",_currentLangBundle,_frontendDefaultBundle) %>">

    <label for="registerUsername"><%=PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle)%></label>
    <input type="text" id="registerUsername"  autocomplete="off" value="<%= email  %>" name="<%= Participante.EMAIL_PROPERTY %>" placeholder="<%= PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle) %>">

    <label for="registerPassword"><%=PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle)%></label>
    <input type="password" id="registerPassword"  autocomplete="off" value="<%= pwd %>" name="<%= RequestParameters.PWD %>" placeholder="<%=  PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle) %>">

    <label for="registerPassword2"><%=PowerUtils.localizeKey("password.confirmation",_currentLangBundle,_frontendDefaultBundle)%></label>
    <input type="password" id="registerPassword2"  autocomplete="off" name="<%= RequestParameters.PWD2 %>" placeholder="<%=  PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle) %>">
    <a title="<%=PowerUtils.localizeKey("register.button.context.info",_currentLangBundle,_frontendDefaultBundle)%>" class="submit" href="#" onclick="$(this).closest('form').submit()"><%=PowerUtils.localizeKey("register",_currentLangBundle,_frontendDefaultBundle)%></a>
</form>