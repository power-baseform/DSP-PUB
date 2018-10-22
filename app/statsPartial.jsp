<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.HelloAnalytics" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %>
<%@ page import="com.baseform.apps.power.json.JSONArray" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteSistema" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="org.apache.cayenne.ObjectContext" %>
<%@ page import="org.apache.cayenne.exp.ExpressionFactory" %>
<%@ page import="org.apache.cayenne.query.SelectQuery" %>
<%@ page import="java.util.List" %>
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
    final PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final String currentSystem = pm.getSystemId(request);
    final ObjectContext dc = pm.getDc(request);
    final ResourceBundle fdb = pm.getDefaultLangBundle();
    final ResourceBundle clb = pm.getCurrentLangBundle();

    final List<Participante> listParticipante = dc.performQuery(new SelectQuery(Participante.class,ExpressionFactory.matchExp(Participante.ACTIVO_PROPERTY, true).andExp(
            ExpressionFactory.matchExp(Participante.PARTICIPACAO_SISTEMA_PROPERTY + "." + RParticipanteSistema.FKSISTEMA_PROPERTY, currentSystem)
    )));


    final JSONArray issuesSharedStat = new JSONArray();
    int countShares= pm.getSharesStat(request,dc,issuesSharedStat);

    final List<Participante> listParticipaSistema = Processo.getParticipantesFromProcs(pm.getIssueList(request));
    int participationCount = listParticipaSistema.size();

    Integer visits = HelloAnalytics.init(request, HelloAnalytics.UNIQUE_VISITORS);
%>

<div class="section stats">
    <div class="grid freeGrow">
        <a href="./?location=stats" class="statsTitle"><%=PowerUtils.localizeKey("stats",clb,fdb)%></a>

        <div class="statsGrid">
            <div class="stat">
                <svg enable-background="new 0 0 144 144" height="144" viewBox="0 0 144 144" width="144" xmlns="http://www.w3.org/2000/svg"><path d="m72 2c22.056 0 40 17.944 40 40 0 12.892-6.302 25.074-16.858 32.586l-3.119 2.221 3.604 1.292c27.109 9.72 45.524 35.235 46.344 63.901h-139.942c.82-28.666 19.235-54.182 46.344-63.901l3.604-1.292-3.119-2.221c-10.556-7.512-16.858-19.694-16.858-32.586 0-22.056 17.944-40 40-40m0-2c-23.197 0-42 18.803-42 42 0 14.13 6.999 26.602 17.698 34.216-27.805 9.97-47.698 36.548-47.698 67.784h144c0-31.236-19.893-57.814-47.698-67.784 10.699-7.614 17.698-20.086 17.698-34.216 0-23.197-18.803-42-42-42z" fill="#36c"/></svg>
                <div class="statsInfo">
                    <h3 class="statCount"><%= listParticipante.size() %></h3>
                    <p class="statDescription"><%=PowerUtils.localizeKey("registered.in.social.platform",clb,fdb,true)%></p>
                </div>
        </div><!----><div class="stat">
            <svg enable-background="new 0 0 72 72" height="72" viewBox="0 0 72 72" width="72" xmlns="http://www.w3.org/2000/svg"><path d="m36 1c19.299 0 35 14.087 35 31.402 0 9.164-4.457 17.85-12.229 23.831l-.605.466.29.706 5.215 12.718-17.491-7.464-.311-.132-.328.083c-3.117.791-6.327 1.192-9.542 1.192-19.299 0-35-14.086-35-31.4.001-17.315 15.702-31.402 35.001-31.402m18.947 39.6c4.521 0 8.2-3.677 8.2-8.198s-3.679-8.2-8.2-8.2-8.2 3.679-8.2 8.2 3.678 8.198 8.2 8.198m-18.947 0c4.521 0 8.2-3.677 8.2-8.198s-3.679-8.2-8.2-8.2c-4.52 0-8.198 3.679-8.198 8.2s3.678 8.198 8.198 8.198m-18.685 0c4.521 0 8.198-3.677 8.198-8.198s-3.677-8.2-8.198-8.2c-4.522 0-8.202 3.679-8.202 8.2s3.68 8.198 8.202 8.198m18.685-40.6c-19.88 0-36 14.508-36 32.402s16.12 32.4 36 32.4c3.396 0 6.677-.434 9.788-1.223l19.734 8.421-6.141-14.974c7.721-5.942 12.619-14.766 12.619-24.624 0-17.894-16.116-32.402-36-32.402zm18.947 39.6c-3.975 0-7.2-3.223-7.2-7.198 0-3.979 3.225-7.2 7.2-7.2 3.978 0 7.2 3.221 7.2 7.2 0 3.975-3.223 7.198-7.2 7.198zm-18.947 0c-3.975 0-7.198-3.223-7.198-7.198 0-3.979 3.223-7.2 7.198-7.2 3.979 0 7.2 3.221 7.2 7.2 0 3.975-3.221 7.198-7.2 7.198zm-18.685 0c-3.979 0-7.202-3.223-7.202-7.198 0-3.979 3.223-7.2 7.202-7.2 3.975 0 7.198 3.221 7.198 7.2 0 3.975-3.222 7.198-7.198 7.198z" fill="#36c"/></svg>
            <div class="statsInfo">
                <h3 class="statCount"><%= participationCount %></h3>
                <p class="statDescription"><%=PowerUtils.localizeKey("participated.in.challenges",clb,fdb,true)%></p>
            </div>
        </div><!----><div class="stat">
            <svg enable-background="new 0 0 72 72" height="72" viewBox="0 0 72 72" width="72" xmlns="http://www.w3.org/2000/svg"><g fill="#36c"><path d="m36 1c19.299 0 35 15.701 35 35s-15.701 35-35 35-35-15.701-35-35 15.701-35 35-35m0 57.601c18.418 0 33.402-10.139 33.402-22.601 0-12.46-14.984-22.598-33.402-22.598-18.417 0-33.4 10.138-33.4 22.598 0 12.462 14.983 22.601 33.4 22.601m0-58.601c-19.879 0-36 16.118-36 36 0 19.884 16.121 36 36 36 19.884 0 36-16.116 36-36 0-19.882-16.116-36-36-36zm0 57.601c-17.892 0-32.4-9.671-32.4-21.601 0-11.927 14.508-21.598 32.4-21.598 17.895 0 32.402 9.671 32.402 21.598 0 11.93-14.507 21.601-32.402 21.601z"/><path d="m36 19.003c9.375 0 17.002 7.625 17.002 16.997 0 9.374-7.627 17-17.002 17-9.373 0-16.998-7.626-16.998-17 0-9.372 7.625-16.997 16.998-16.997m0-1c-9.94 0-17.998 8.057-17.998 17.997 0 9.944 8.058 18 17.998 18 9.942 0 18.002-8.056 18.002-18 0-9.94-8.06-17.997-18.002-17.997z"/><path d="m36 29.802c3.418 0 6.2 2.78 6.2 6.198 0 3.42-2.781 6.202-6.2 6.202-3.417 0-6.198-2.782-6.198-6.202 0-3.418 2.781-6.198 6.198-6.198m0-1c-3.975 0-7.198 3.223-7.198 7.198 0 3.978 3.223 7.202 7.198 7.202 3.98 0 7.2-3.225 7.2-7.202 0-3.976-3.22-7.198-7.2-7.198z"/></g></svg>
            <div class="statsInfo">
                <h3 class="statCount"><%= visits %></h3>
                <p class="statDescription"><%=PowerUtils.localizeKey("viewed.platform.challenges",clb,fdb,true)%></p>
            </div>
        </div><!----><div class="stat last">
            <svg enable-background="new 0 0 72 72" height="72" viewBox="0 0 72 72" width="72" xmlns="http://www.w3.org/2000/svg"><path d="m59.402 1c6.395 0 11.598 5.204 11.598 11.6 0 6.397-5.203 11.602-11.598 11.602-3.153 0-6.106-1.251-8.316-3.522l-.51-.524-.654.327-25.336 12.668-.654.327.114.723c.104.659.154 1.248.154 1.802s-.05 1.143-.154 1.799l-.114.723.655.327 25.335 12.668.654.327.51-.524c2.207-2.27 5.16-3.52 8.316-3.52 6.395 0 11.598 5.204 11.598 11.6 0 6.394-5.203 11.597-11.598 11.597-6.396 0-11.6-5.203-11.6-11.598 0-.543.049-1.117.155-1.805l.111-.72-.652-.326-25.336-12.668-.655-.327-.51.525c-2.204 2.27-5.157 3.52-8.315 3.52-6.396-.001-11.6-5.204-11.6-11.599 0-6.396 5.204-11.6 11.6-11.6 3.158 0 6.111 1.25 8.315 3.52l.51.525.655-.327 25.336-12.668.652-.326-.111-.72c-.105-.687-.155-1.26-.155-1.805 0-6.397 5.204-11.601 11.6-11.601m0-1c-6.961 0-12.6 5.641-12.6 12.6 0 .668.068 1.319.167 1.957l-25.336 12.668c-2.288-2.355-5.487-3.823-9.033-3.823-6.956 0-12.6 5.639-12.6 12.6 0 6.959 5.644 12.598 12.6 12.598 3.546 0 6.745-1.467 9.033-3.823l25.336 12.668c-.098.64-.167 1.289-.167 1.957 0 6.958 5.639 12.598 12.6 12.598 6.959 0 12.598-5.639 12.598-12.598 0-6.961-5.639-12.6-12.598-12.6-3.546 0-6.743 1.467-9.033 3.823l-25.335-12.668c.101-.638.166-1.289.166-1.955 0-.668-.065-1.317-.166-1.957l25.336-12.668c2.292 2.355 5.486 3.825 9.033 3.825 6.958 0 12.597-5.643 12.597-12.602s-5.639-12.6-12.598-12.6z" fill="#36c"/></svg>
            <div class="statsInfo">
                <h3 class="statCount"><%= countShares %></h3>
                <p class="statDescription"><%=PowerUtils.localizeKey("shared.platform.challenges",clb,fdb,true)%></p>
            </div>
        </div><!---->
        </div>
    </div>
</div>

<script>
    if (<%= !pm.isMobileRequest() %>) {
        POWERController.initStatsLink(".section.stats *");
    }
</script>