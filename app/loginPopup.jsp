<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>

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
    PowerPubManager pm = (PowerPubManager) PowerPubManager.get(request);
    boolean erros = false;
    if (pm.getErros()!=null && !pm.getErros().isEmpty())
        erros = true;

    final ResourceBundle _frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle _currentLangBundle = pm.getCurrentLangBundle();

    String loginClass = "login".equalsIgnoreCase(request.getParameter("activeTab")) ? "" : "hidden";
    String registerClass = "register".equalsIgnoreCase(request.getParameter("activeTab")) ? "" : "hidden";
    String loginSelectedTab = "login".equalsIgnoreCase(request.getParameter("activeTab")) ? "active" : "";
    String registerSelectedTab = "register".equalsIgnoreCase(request.getParameter("activeTab")) ? "active" : "";

    String email = request.getParameter("email") != null ? request.getParameter("email") : "";
    String pwd = request.getParameter("pwd") != null ? request.getParameter("pwd") : "";

    String url = request.getParameter("redirectTo") != null ? request.getParameter("redirectTo") : "?location=" + pm.getCurrentLocationName();
%>
<div class="overlay"></div>
<div class="popup popupLogin">
    <a class="closePopup" href="#"></a>

    <ul class="tabs">
        <li class="tab <%= loginSelectedTab %>" data-tab="login"><%=PowerUtils.localizeKey("login",_currentLangBundle,_frontendDefaultBundle)%></li>
        <li class="tab separator" data-tab="">/</li>
        <li class="tab <%= registerSelectedTab %>" data-tab="register"><%=PowerUtils.localizeKey("register",_currentLangBundle,_frontendDefaultBundle)%></li>
    </ul>

    <p class="error"><%=StringEscapeUtils.escapeJavaScript(pm.getErros())%></p>
    <form accept-charset="utf-8" method="post" action="./<%= url %>&login_pub" data-tab="login" class="tabContent <%= loginClass %>" autocomplete="off">
        <label for="loginUsername"><%=PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="text" id="loginUsername" name="<%= Participante.EMAIL_PROPERTY %>" placeholder="<%= PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle) %>">
        <label for="loginPassword"><%=PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="password" id="loginPassword" name="<%= RequestParameters.PWD %>" placeholder="<%=  PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle) %>">
        <a href="#" class="here forgotPassword"><%=PowerUtils.localizeKey("msg.forgot.password",_currentLangBundle,_frontendDefaultBundle)%></a>
        <a class="submit" href="#" ><%=PowerUtils.localizeKey("login",_currentLangBundle,_frontendDefaultBundle)%></a>
        <p class="socialLogin">Or use your social account</p>
        <a href="#" class="fbLogin">Facebook</a><!----><a href="#" class="googleLogin" id="googleLogin">Google</a>
    </form>

    <form accept-charset="utf-8" method="post" action="./<%= url %>&<%=RequestParameters.REGISTO%>" data-tab="register" class="tabContent <%= registerClass %>" autocomplete="off">
        <label for="registerName"><%=PowerUtils.localizeKey("username",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="text" id="registerName"  autocomplete="off" name="<%= Participante.NOME_PROPERTY %>" placeholder="<%= PowerUtils.localizeKey("username",_currentLangBundle,_frontendDefaultBundle) %>">

        <label for="registerUsername"><%=PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="text" id="registerUsername"  autocomplete="off" value="<%= email %>" name="<%= Participante.EMAIL_PROPERTY %>" placeholder="<%= PowerUtils.localizeKey("email",_currentLangBundle,_frontendDefaultBundle) %>">

        <label for="registerPassword"><%=PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="password" id="registerPassword"  autocomplete="off" value="<%= pwd %>" name="<%= RequestParameters.PWD %>" placeholder="<%=  PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle) %>">

        <label for="registerPassword2"><%=PowerUtils.localizeKey("password.confirmation",_currentLangBundle,_frontendDefaultBundle)%></label>
        <input type="password" id="registerPassword2" autocomplete="off"  name="<%= RequestParameters.PWD2 %>" placeholder="<%=  PowerUtils.localizeKey("password",_currentLangBundle,_frontendDefaultBundle) %>">

        <div class="legal-checkbox pop">
            <label>
                <input type="checkbox" name="<%= RequestParameters.LEGAL %>">
                <%=PowerUtils.localizeKey("agree.with.terms",_currentLangBundle,_frontendDefaultBundle, new String[]{"<a target='blank' href='terms_of_service.jsp'>" +PowerUtils.localizeKey("terms.of.use",_currentLangBundle,_frontendDefaultBundle)  + "</a>","<a target='blank'  href='privacy_policy.jsp'>" +PowerUtils.localizeKey("privacy.policy",_currentLangBundle,_frontendDefaultBundle)  + "</a>"})%>
            </label>
        </div>

        <a title="<%=PowerUtils.localizeKey("register.button.context.info",_currentLangBundle,_frontendDefaultBundle)%>" class="submit" href="#" ><%=PowerUtils.localizeKey("register",_currentLangBundle,_frontendDefaultBundle)%></a>
    </form>
</div>

<script>
    POWERController.popupTabs(".popup .tabs .tab");
    POWERController.sendPopupForms(".tabContent a.submit");
    POWERController.popupForgotPassword(".here.forgotPassword");
    POWERController.initLegalCheckbox(".legal-checkbox.pop");

    $("#googleLogin").on("click", function(e) {
        $("#googleLoginHidden").children().trigger("click")
    });
</script>