<%@page trimDirectiveWhitespaces="true" %>
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.utils.HtmlInputs" %>
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
    Participante participante = pm.getParticipante();

    if (!pm.isMobileRequest()) return;
    boolean message = pm.getMsg() != null && !pm.getMsg().trim().isEmpty();
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();

%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link href="redesign_css/login_hub.css" rel="stylesheet" type="text/css">

<div class="section loginHead afterHeader">
    <div class="grid">
        <h4 class="title"><%=participante != null ? pm.getParticipante().getNome() : PowerUtils.localizeKey("my.area", currentLangBundle, frontendDefaultBundle)%></h4>
    </div>
</div>

<div class="section login">
    <div class="grid">
        <h4 class="title"><%=PowerUtils.localizeKey("login", currentLangBundle, frontendDefaultBundle)%>
        </h4>
        <form class="loginForm" id="f" method="post" action="./?login_pub">
            <input type="text" name="<%= Participante.EMAIL_PROPERTY %>" placeholder="<%= PowerUtils.localizeKey("email",currentLangBundle,frontendDefaultBundle) %>"><!--
            --><input type="password" name="<%= RequestParameters.PWD %>" placeholder="<%=  PowerUtils.localizeKey("password",currentLangBundle,frontendDefaultBundle) %>">
           <a class="submit" onclick="$('#f').submit();"><%=PowerUtils.localizeKey("login",currentLangBundle,frontendDefaultBundle)%> ></a>
        </form>
        <form accept-charset="utf-8" id="fr" method="post" action="?<%=RequestParameters.REQUEST_PWD%>">
            <a href="#" class="forgotPassword">
                <%=PowerUtils.localizeKey("msg.forgot.password", currentLangBundle, frontendDefaultBundle)%>
            </a>
            <div class="forgotPasswordHolder hidden">
                <% HtmlInputs.writeHtmlText("emailRecuperar", null, PowerUtils.localizeKey("email", currentLangBundle, frontendDefaultBundle), false, "cleanInput text", "onfocus=\"(this.value=='" + PowerUtils.localizeKey("email", currentLangBundle, frontendDefaultBundle) + "') && (this.value='')\" onblur=\"(this.value=='') && (this.value='" + PowerUtils.localizeKey("email", currentLangBundle, frontendDefaultBundle) + "')\" autocomplete=\"off\"", out);%><!--
                --><img src='captcha?r=<%=new Double(Math.random()*100000000d).intValue()%>&captcha-width=200&captcha-height=34' alt="capcha" class="captcha halfInput"/><!--
                --><% HtmlInputs.writeHtmlText("captcha", null, PowerUtils.localizeKey("captcha", currentLangBundle, frontendDefaultBundle), false, "cleanInput text halfInput", "onfocus=\"(this.value=='" + PowerUtils.localizeKey("captcha", currentLangBundle, frontendDefaultBundle) + "') && (this.value='')\" onblur=\"(this.value=='') && (this.value='" + PowerUtils.localizeKey("captcha", currentLangBundle, frontendDefaultBundle) + "')\" autocomplete=\"off\"", out);%>
                <a class="submit noBorder" onclick="$('#fr').submit();"><%=PowerUtils.localizeKey("reset.password", currentLangBundle, frontendDefaultBundle)%> ></a>
            </div>
        </form>
    </div>
</div>

<div class="section register">
    <div class="grid">
        <h4 class="title"><%=PowerUtils.localizeKey("register", currentLangBundle, frontendDefaultBundle)%></h4>

        <form accept-charset="utf-8" id="freg" style="position:relative;" method="post" action="?<%=RequestParameters.REGISTO%>">
            <h4 class="subTitle"><%=PowerUtils.localizeKey("register.info", currentLangBundle, frontendDefaultBundle)%></h4>
            <%HtmlInputs.writeHtmlText(Participante.NOME_PROPERTY, null, request.getParameter(Participante.NOME_PROPERTY) != null && !message ? request.getParameter(Participante.NOME_PROPERTY) : PowerUtils.localizeKey("username", currentLangBundle, frontendDefaultBundle), false, "cleanInput text", "onfocus=\"(this.value=='" + PowerUtils.localizeKey("username", currentLangBundle, frontendDefaultBundle) + "') && (this.value='')\" onblur=\"(this.value=='') && (this.value='" + PowerUtils.localizeKey("name", currentLangBundle, frontendDefaultBundle) + "')\" autocomplete=\"off\"", out);%><!--
            --><%HtmlInputs.writeHtmlText(Participante.EMAIL_PROPERTY, null, request.getParameter(Participante.EMAIL_PROPERTY) != null && !message ? request.getParameter(Participante.EMAIL_PROPERTY) : PowerUtils.localizeKey("email", currentLangBundle, frontendDefaultBundle), false, "cleanInput text", "onfocus=\"(this.value=='" + PowerUtils.localizeKey("email", currentLangBundle, frontendDefaultBundle) + "') && (this.value='')\" onblur=\"(this.value=='') && (this.value='" + PowerUtils.localizeKey("email", currentLangBundle, frontendDefaultBundle) + "')\" autocomplete=\"off\"", out);%><!--
            --><input type="password" name="<%= RequestParameters.PWD %>" value="<%=request.getParameter(RequestParameters.PWD)%>" placeholder="<%=  PowerUtils.localizeKey("password",currentLangBundle,frontendDefaultBundle) %>"><!--
            --><input type="password" name="<%= RequestParameters.PWD2 %>" placeholder="<%=  PowerUtils.localizeKey("confirm.password",currentLangBundle,frontendDefaultBundle) %>"><!--
            --><div class="legal-checkbox log">
                <label>
                    <input type="checkbox" name="<%= RequestParameters.LEGAL %>">
                    <%=PowerUtils.localizeKey("agree.with.terms",currentLangBundle,frontendDefaultBundle, new String[]{"<a target='blank' href='terms_of_service.jsp'>" +PowerUtils.localizeKey("terms.of.use",currentLangBundle,frontendDefaultBundle)  + "</a>","<a target='blank'  href='privacy_policy.jsp'>" +PowerUtils.localizeKey("privacy.policy",currentLangBundle,frontendDefaultBundle)  + "</a>"})%>
                </label>
            </div>
        </form>
        <a class="submitRegister submit" onclick="$('#freg').submit();"><%=PowerUtils.localizeKey("sign.up.lower", currentLangBundle, frontendDefaultBundle)%> ></a>
    </div>
</div>


<script type="text/javascript">
    POWERController.forgotPassword();
    POWERController.initCustomSelects();
    POWERController.initLegalCheckbox(".legal-checkbox.log");
</script>
