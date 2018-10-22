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
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<html class="no-js" lang="">
<body>
<%
    PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
%>



    <div style="width:904px;margin:0 auto;">
        <table class="subTitulo">
            <tr>
                <td class="museo500 subTitleTxt">
                    <%=PowerUtils.localizeKey("recover.password", currentLangBundle,frontendDefaultBundle)%>
                </td>
            </tr>
            <tr>
                <td style="padding: 30px 10px 0 10px;width: 904px" class="museo300" colspan="2">
                    <%=PowerUtils.localizeKey("recover.password.confirm", currentLangBundle,frontendDefaultBundle)%>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
