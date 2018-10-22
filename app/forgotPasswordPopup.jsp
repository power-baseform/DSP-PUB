<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="java.util.ResourceBundle" %>

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
%>
<div class="overlay"></div>
<div class="popup popupLogin">
    <a class="closePopup" href="#"></a>

    <form accept-charset="utf-8" method="post" action="./?location=<%= pm.getCurrentLocationName()%>&<%=RequestParameters.REQUEST_PWD%>" class="" style="padding-top:20px;" autocomplete="off">
        <label for="registerUsername"><%=PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="text" id="registerUsername" name="emailRecuperar" placeholder="<%= PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle) %>">

        <img src='captcha?r=<%=new Double(Math.random()*100000000d).intValue()%>&captcha-width=200&captcha-height=34' alt="capcha" class="captcha halfInput"/>
        <label for="captcha"><%=PowerUtils.localizeKey("captcha",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="text" id="captcha" name="captcha" placeholder="<%=  PowerUtils.localizeKey("captcha",_currentLangBundle,_frontendDefaultBundle) %>">

        <a class="submit" href="#" onclick="$(this).closest('form').submit()"><%=PowerUtils.localizeKey("recover",_currentLangBundle,_frontendDefaultBundle)%></a>
    </form>
</div>
