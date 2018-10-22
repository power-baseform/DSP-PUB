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
<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.json.JSONArray" %>
<%@ page import="com.baseform.apps.power.json.JSONObject" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.participante.RParticipanteSistema" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.google.api.services.analytics.model.GaData" %>
<%@ page import="org.apache.cayenne.ObjectContext" %>
<%@ page import="org.apache.cayenne.exp.ExpressionFactory" %>
<%@ page import="org.apache.cayenne.query.Ordering" %>
<%@ page import="org.apache.cayenne.query.SelectQuery" %>
<%@ page import="org.apache.cayenne.query.SortOrder" %>
<%@ page import="org.apache.commons.lang3.tuple.ImmutablePair" %>
<%@ page import="org.apache.commons.lang3.tuple.Pair" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.cayenne.query.SQLTemplate" %>
<%@ page import="com.baseform.apps.power.processo.GamificationLog" %>
<%@ page import="org.apache.cayenne.DataRow" %>
<%@ page import="com.baseform.apps.power.frontend.*" %>
<script type="text/javascript" src="js/flot/jquery.flot.js"></script>
<script type="text/javascript" src="js/flot/jquery.flot.pie.js"></script>
<script type="text/javascript" src="js/flot/jquery.flot.symbol.js"></script>
<script type="text/javascript" src="js/flot/jquery.flot.time.js"></script>
<script type="text/javascript" src="js/flot/jquery.flot.categories.js"></script>
<script type="text/javascript" src="js/flot/excanvas.js"></script>
<script type="text/javascript" src="js/jquery.flot.axislabels.js"></script>
<link href="redesign_css/stats.css" rel="stylesheet" type="text/css">
<link href="redesign_css/issue.css" rel="stylesheet" type="text/css">
<%
    final PowerPubManager pm = (PowerPubManager) PublicManager.get(request);
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();

    final ObjectContext dc = pm.getDc(request);
    final String curr_syst = pm.getSystemId(request);


    final List<Participante> listParticipante = dc.performQuery(new SelectQuery(Participante.class, ExpressionFactory.matchExp(Participante.ACTIVO_PROPERTY, true).andExp(
            ExpressionFactory.matchExp(Participante.PARTICIPACAO_SISTEMA_PROPERTY + "." + RParticipanteSistema.FKSISTEMA_PROPERTY, curr_syst)
    )));

    final List<Processo> listProcessos = dc.performQuery(new SelectQuery(Processo.class, ExpressionFactory.matchExp(Processo.PUBLICADO_PROPERTY, true).andExp(
            ExpressionFactory.matchExp(Processo.SISTEMA_PROPERTY, curr_syst)
    )));

    final HashMap<String, List<Processo>> issuesBycode = new HashMap<>();
    final HashMap<String, List<Processo>> openIssuesBycode = new HashMap<>();
    for (Processo p : listProcessos) {
        final String codigo = p.getCodigo();
        issuesBycode.putIfAbsent(codigo, new ArrayList<>());
        issuesBycode.get(codigo).add(p);


        openIssuesBycode.putIfAbsent(codigo, new ArrayList<>());
        openIssuesBycode.get(codigo).add(p);

    }


    int countEventos = 0;
    final HashMap<String, Integer> mapaEventoProcesso = new HashMap<>();
    for (String code : issuesBycode.keySet()) {
        final String titulo = Processo.getTituloForCodeAndLocale(code, pm.getCurrentLocale().getLanguage(), curr_syst, dc);
        final int procEventCount = issuesBycode.get(code).get(0).getEventos().size();
        countEventos += procEventCount;

        mapaEventoProcesso.putIfAbsent(titulo, 0);
        mapaEventoProcesso.put(titulo, mapaEventoProcesso.get(titulo) + procEventCount);
    }

    final JSONArray issueAssociatedEventsStat = new JSONArray();
    for (String s : mapaEventoProcesso.keySet()) {
        final JSONObject oProcesso15 = new JSONObject();
        oProcesso15.put("label", s);
        oProcesso15.put("data", mapaEventoProcesso.get(s));
        issueAssociatedEventsStat.put(oProcesso15);
    }


    final List<GaData> gaDatas = HelloAnalytics.init1(request, 12, HelloAnalytics.UNIQUE_VISITORS);
    final JSONArray visitsStat = new JSONArray();
    if (gaDatas != null && !gaDatas.isEmpty()) {
        for (int i = gaDatas.size() - 1; i > -1; i--) {
            GaData gaData = gaDatas.get(i);
            Object[] val = new Object[2];
            String[] selfLinks = gaData.get("selfLink") != null ? gaData.get("selfLink").toString().split("&") : null;
            String[] split = selfLinks != null ? selfLinks[3].split("=") : null;
            val[0] = split != null ? PowerUtils.DATE_FORMAT_GFX.format(PowerUtils.DATE_FORMAT_GA.parse(split[1])) : null;
            val[1] = gaData.getRows() != null ? gaData.getRows().get(0).get(0) : "0";
            visitsStat.put(val);
        }
    }

    JSONArray registeredUsersStat = new JSONArray();
    JSONArray loggedinUsersStat = new JSONArray();
    final TreeMap<Date, Integer> dateCountLoggedinUsers = new TreeMap<>(), dateCountRegisteredUsers = new TreeMap<>();
    int countRegisteredUsers = 0, countLoggedinUsers = 0;
    if (listParticipante != null && !listParticipante.isEmpty()) {
        new Ordering(Participante.DATA_REGISTO_PROPERTY, SortOrder.ASCENDING).orderList(listParticipante);
        for (Participante participante : listParticipante) {
            countRegisteredUsers++;
            if (participante.getDataRegisto() == null) continue;
            Date truncatedDate = PowerUtils.safeTruncateDay(participante.getDataRegisto());
            dateCountRegisteredUsers.put(truncatedDate, countRegisteredUsers);
        }
    }

    final SQLTemplate loginsByDayQuery = new SQLTemplate(GamificationLog.class, "SELECT (date_part('year',timestamp)||'-'||date_part('month',timestamp)||'-'||date_part('day',timestamp)||' 23:59:59')::timestamp as date, count(*) as count FROM PROCESSOS.GAMIFICATION_LOG where system_id='"+curr_syst+"' and action='action.login' group by date_part('day',timestamp), date_part('month',timestamp), date_part('year',timestamp) order by date_part('year',timestamp) asc, date_part('month',timestamp) asc, date_part('day',timestamp) asc");
    loginsByDayQuery.setFetchingDataRows(true);
    final List<DataRow> loginsByDay = dc.performQuery(loginsByDayQuery);
    for (DataRow row : loginsByDay) {
        final int count = ((Number) row.get("count")).intValue();
        dateCountLoggedinUsers.put((Date) row.get("date"), count);
        countLoggedinUsers+=count;
    }

    if(!dateCountRegisteredUsers.isEmpty()){
        Date fDate = dateCountRegisteredUsers.firstKey();
        Date lDate = dateCountRegisteredUsers.lastKey();
        double v = PowerUtils.daysDifference(fDate, lDate);

        if (v < 10) {
            registeredUsersStat = createDateLineChart(dateCountRegisteredUsers, fDate, lDate, Calendar.DATE, 1, PowerUtils.DATE_FORMAT, true);
            // dias
        } else if (v < 90) {
            registeredUsersStat = createDateLineChart(dateCountRegisteredUsers, fDate, lDate, Calendar.DATE, 7, PowerUtils.DATE_FORMAT, true);
            // semanas
        } else{
            // meses
            registeredUsersStat = createDateLineChart(dateCountRegisteredUsers, fDate, lDate, Calendar.MONTH, 1, PowerUtils.DATE_MONTH_FORMAT, true);
        }
    }

    if(!dateCountLoggedinUsers.isEmpty()){
        Date fDate = dateCountLoggedinUsers.firstKey();
        Date lDate = dateCountLoggedinUsers.lastKey();
        double v = PowerUtils.daysDifference(fDate, lDate);

        if (v < 10) {
            loggedinUsersStat = createDateLineChart(dateCountLoggedinUsers, fDate, lDate, Calendar.DATE, 1, PowerUtils.DATE_FORMAT, false);
            // dias
        } else if (v < 90) {
            loggedinUsersStat = createDateLineChart(dateCountLoggedinUsers, fDate, lDate, Calendar.DATE, 7, PowerUtils.DATE_FORMAT, false);
            // semanas
        } else{
            // meses
            loggedinUsersStat = createDateLineChart(dateCountLoggedinUsers, fDate, lDate, Calendar.MONTH, 1, PowerUtils.DATE_MONTH_FORMAT, false);
        }
    }

    final JSONArray issuesSharedStat = new JSONArray();
    int countShares= pm.getSharesStat(request,dc,issuesSharedStat);



%>
<div class="section stats full afterHeader issueArea">
    <div class="grid">
        <div class="title intro">
            <h3 class="title"><%=PowerUtils.localizeKey("statistics", currentLangBundle, frontendDefaultBundle, true)%>
            </h3>
        </div>
        <h3 class="subTitle"><%=PowerUtils.localizeKey("statistics.info", currentLangBundle, frontendDefaultBundle, true)%>
        </h3>

        <%
            Integer init = HelloAnalytics.init(request, HelloAnalytics.UNIQUE_VISITORS);

            final List<ImmutablePair<JSONArray, String>> pies = new ArrayList<>();
            if(countEventos>0)
                pies.add(new ImmutablePair<>(issueAssociatedEventsStat, "14"));
            if(countRegisteredUsers >0)
                pies.add(new ImmutablePair<>(issuesSharedStat, "10"));

            final List<Pair<JSONArray, String>> lines = new ArrayList<>();

            if (init != null)
                lines.add(new ImmutablePair<>(visitsStat, "18"));

            lines.add(new ImmutablePair<>(registeredUsersStat, "1"));
            lines.add(new ImmutablePair<>(loggedinUsersStat, "2"));
        %>
        <%  if (init != null) {%>
        <div class="statsGrid">
            <div class="stat" data-id="8">
                <div class="statTitle">
                    <svg enable-background="new 0 0 144 144" height="144" viewBox="0 0 144 144" width="144"
                         xmlns="http://www.w3.org/2000/svg">
                        <path d="m72 2c22.056 0 40 17.944 40 40 0 12.892-6.302 25.074-16.858 32.586l-3.119 2.221 3.604 1.292c27.109 9.72 45.524 35.235 46.344 63.901h-139.942c.82-28.666 19.235-54.182 46.344-63.901l3.604-1.292-3.119-2.221c-10.556-7.512-16.858-19.694-16.858-32.586 0-22.056 17.944-40 40-40m0-2c-23.197 0-42 18.803-42 42 0 14.13 6.999 26.602 17.698 34.216-27.805 9.97-47.698 36.548-47.698 67.784h144c0-31.236-19.893-57.814-47.698-67.784 10.699-7.614 17.698-20.086 17.698-34.216 0-23.197-18.803-42-42-42z"
                              fill="#36c"/>
                    </svg>
                    <div class="statsInfo">
                        <h3 class="statCount"><%=init%>
                        </h3>
                        <p class="statDescription"><%=PowerUtils.localizeKey("visitors", currentLangBundle, frontendDefaultBundle, true)%>
                        </p>
                    </div>
                </div>
                <div class="graphDiv" data-stat="8" id="grapDiv_8">
                    <div class="graphContainer" style="width: 100%">
                        <div class="graphTitle museo900 texto16">
                            <span><%=PowerUtils.localizeKey("access.evolution", currentLangBundle, frontendDefaultBundle, true)%></span><br/><span
                                style="font-size:11px"><%=PowerUtils.localizeKey("last.3.months", currentLangBundle, frontendDefaultBundle)%></span>
                        </div>
                        <div class="graphs" style="width: 100% !important;" id="graph_18">
                        </div>
                        <div class="graphLabel" id="label_18"></div>
                    </div>
                </div>
            </div><!----><% }%>
            <div class="stat" data-id="1">
                <div class="statTitle">
                    <svg enable-background="new 0 0 72 72" height="72" viewBox="0 0 72 72" width="72"
                         xmlns="http://www.w3.org/2000/svg">
                        <path d="m36 1c19.299 0 35 14.087 35 31.402 0 9.164-4.457 17.85-12.229 23.831l-.605.466.29.706 5.215 12.718-17.491-7.464-.311-.132-.328.083c-3.117.791-6.327 1.192-9.542 1.192-19.299 0-35-14.086-35-31.4.001-17.315 15.702-31.402 35.001-31.402m18.947 39.6c4.521 0 8.2-3.677 8.2-8.198s-3.679-8.2-8.2-8.2-8.2 3.679-8.2 8.2 3.678 8.198 8.2 8.198m-18.947 0c4.521 0 8.2-3.677 8.2-8.198s-3.679-8.2-8.2-8.2c-4.52 0-8.198 3.679-8.198 8.2s3.678 8.198 8.198 8.198m-18.685 0c4.521 0 8.198-3.677 8.198-8.198s-3.677-8.2-8.198-8.2c-4.522 0-8.202 3.679-8.202 8.2s3.68 8.198 8.202 8.198m18.685-40.6c-19.88 0-36 14.508-36 32.402s16.12 32.4 36 32.4c3.396 0 6.677-.434 9.788-1.223l19.734 8.421-6.141-14.974c7.721-5.942 12.619-14.766 12.619-24.624 0-17.894-16.116-32.402-36-32.402zm18.947 39.6c-3.975 0-7.2-3.223-7.2-7.198 0-3.979 3.225-7.2 7.2-7.2 3.978 0 7.2 3.221 7.2 7.2 0 3.975-3.223 7.198-7.2 7.198zm-18.947 0c-3.975 0-7.198-3.223-7.198-7.198 0-3.979 3.223-7.2 7.198-7.2 3.979 0 7.2 3.221 7.2 7.2 0 3.975-3.221 7.198-7.2 7.198zm-18.685 0c-3.979 0-7.202-3.223-7.202-7.198 0-3.979 3.223-7.2 7.202-7.2 3.975 0 7.198 3.221 7.198 7.2 0 3.975-3.222 7.198-7.198 7.198z"
                              fill="#36c"/>
                    </svg>
                    <div class="statsInfo">
                        <h3 class="statCount"><%=countRegisteredUsers%>
                        </h3>
                        <p class="statDescription"><%=PowerUtils.localizeKey("registered.users", currentLangBundle, frontendDefaultBundle, true)%>
                        </p>
                    </div>
                </div>
                <div class="graphDiv" data-stat="1" id="grapDiv_1">
                    <div class="graphContainer" style="width: 100%">
                        <div class="graphTitle museo900 texto16">
                            <span><%=PowerUtils.localizeKey("registered.users", currentLangBundle, frontendDefaultBundle, true)%></span><br/>
                        </div>
                        <div class="graphs" style="width: 100% !important;" id="graph_1">
                        </div>
                        <div class="graphLabel" id="label_1"></div>
                    </div>
                </div>
            </div><!---->
            <div class="stat" data-id="2">
                <div class="statTitle">
                    <svg enable-background="new 0 0 144 144" height="144" viewBox="0 0 144 144" width="144"
                         xmlns="http://www.w3.org/2000/svg">
                        <path d="m72 2c22.056 0 40 17.944 40 40 0 12.892-6.302 25.074-16.858 32.586l-3.119 2.221 3.604 1.292c27.109 9.72 45.524 35.235 46.344 63.901h-139.942c.82-28.666 19.235-54.182 46.344-63.901l3.604-1.292-3.119-2.221c-10.556-7.512-16.858-19.694-16.858-32.586 0-22.056 17.944-40 40-40m0-2c-23.197 0-42 18.803-42 42 0 14.13 6.999 26.602 17.698 34.216-27.805 9.97-47.698 36.548-47.698 67.784h144c0-31.236-19.893-57.814-47.698-67.784 10.699-7.614 17.698-20.086 17.698-34.216 0-23.197-18.803-42-42-42z"
                              fill="#36c"/>
                    </svg>
                    <div class="statsInfo">
                        <h3 class="statCount"><%=countLoggedinUsers%>
                        </h3>
                        <p class="statDescription"><%=PowerUtils.localizeKey("logins", currentLangBundle, frontendDefaultBundle, true)%>
                        </p>
                    </div>
                </div>
                <div class="graphDiv" data-stat="1" id="grapDiv_2">
                    <div class="graphContainer" style="width: 100%">
                        <div class="graphTitle museo900 texto16">
                            <span><%=PowerUtils.localizeKey("logins", currentLangBundle, frontendDefaultBundle, true)%></span><br/>
                        </div>
                        <div class="graphs" style="width: 100% !important;" id="graph_2">
                        </div>
                        <div class="graphLabel" id="label_2"></div>
                    </div>
                </div>
            </div><!---->
            <div class="stat" data-id="10">
                <div class="statTitle">
                    <svg enable-background="new 0 0 72 72" height="72" viewBox="0 0 72 72" width="72"
                         xmlns="http://www.w3.org/2000/svg">
                        <path d="m59.402 1c6.395 0 11.598 5.204 11.598 11.6 0 6.397-5.203 11.602-11.598 11.602-3.153 0-6.106-1.251-8.316-3.522l-.51-.524-.654.327-25.336 12.668-.654.327.114.723c.104.659.154 1.248.154 1.802s-.05 1.143-.154 1.799l-.114.723.655.327 25.335 12.668.654.327.51-.524c2.207-2.27 5.16-3.52 8.316-3.52 6.395 0 11.598 5.204 11.598 11.6 0 6.394-5.203 11.597-11.598 11.597-6.396 0-11.6-5.203-11.6-11.598 0-.543.049-1.117.155-1.805l.111-.72-.652-.326-25.336-12.668-.655-.327-.51.525c-2.204 2.27-5.157 3.52-8.315 3.52-6.396-.001-11.6-5.204-11.6-11.599 0-6.396 5.204-11.6 11.6-11.6 3.158 0 6.111 1.25 8.315 3.52l.51.525.655-.327 25.336-12.668.652-.326-.111-.72c-.105-.687-.155-1.26-.155-1.805 0-6.397 5.204-11.601 11.6-11.601m0-1c-6.961 0-12.6 5.641-12.6 12.6 0 .668.068 1.319.167 1.957l-25.336 12.668c-2.288-2.355-5.487-3.823-9.033-3.823-6.956 0-12.6 5.639-12.6 12.6 0 6.959 5.644 12.598 12.6 12.598 3.546 0 6.745-1.467 9.033-3.823l25.336 12.668c-.098.64-.167 1.289-.167 1.957 0 6.958 5.639 12.598 12.6 12.598 6.959 0 12.598-5.639 12.598-12.598 0-6.961-5.639-12.6-12.598-12.6-3.546 0-6.743 1.467-9.033 3.823l-25.335-12.668c.101-.638.166-1.289.166-1.955 0-.668-.065-1.317-.166-1.957l25.336-12.668c2.292 2.355 5.486 3.825 9.033 3.825 6.958 0 12.597-5.643 12.597-12.602s-5.639-12.6-12.598-12.6z"
                              fill="#36c"/>
                    </svg>
                    <div class="statsInfo">
                        <h3 class="statCount"><%=countShares%>
                        </h3>
                        <p class="statDescription"><%=PowerUtils.localizeKey("issue.shares", currentLangBundle, frontendDefaultBundle, true)%>
                        </p>
                    </div>
                </div>
                <%
                    if(countShares>0){
                %>
                <div class="graphDiv" data-stat="10" id="grapDiv_10">
                    <div class="graphContainer" style="width: 294px">
                        <div class="graphTitle museo900 texto16"><%=PowerUtils.localizeKey("social.network", currentLangBundle, frontendDefaultBundle, true)%>
                        </div>
                        <div class="graphs" id="graph_10">
                        </div>
                        <div class="graphLabel" id="label_10"></div>
                    </div>
                </div>
                <%
                    }
                %>
            </div><!---->
            <div class="stat" data-id="5">
                <div class="statTitle">
                    <svg enable-background="new 0 0 72 72" height="72" viewBox="0 0 72 72" width="72"
                         xmlns="http://www.w3.org/2000/svg">
                        <path d="m59.402 1c6.395 0 11.598 5.204 11.598 11.6 0 6.397-5.203 11.602-11.598 11.602-3.153 0-6.106-1.251-8.316-3.522l-.51-.524-.654.327-25.336 12.668-.654.327.114.723c.104.659.154 1.248.154 1.802s-.05 1.143-.154 1.799l-.114.723.655.327 25.335 12.668.654.327.51-.524c2.207-2.27 5.16-3.52 8.316-3.52 6.395 0 11.598 5.204 11.598 11.6 0 6.394-5.203 11.597-11.598 11.597-6.396 0-11.6-5.203-11.6-11.598 0-.543.049-1.117.155-1.805l.111-.72-.652-.326-25.336-12.668-.655-.327-.51.525c-2.204 2.27-5.157 3.52-8.315 3.52-6.396-.001-11.6-5.204-11.6-11.599 0-6.396 5.204-11.6 11.6-11.6 3.158 0 6.111 1.25 8.315 3.52l.51.525.655-.327 25.336-12.668.652-.326-.111-.72c-.105-.687-.155-1.26-.155-1.805 0-6.397 5.204-11.601 11.6-11.601m0-1c-6.961 0-12.6 5.641-12.6 12.6 0 .668.068 1.319.167 1.957l-25.336 12.668c-2.288-2.355-5.487-3.823-9.033-3.823-6.956 0-12.6 5.639-12.6 12.6 0 6.959 5.644 12.598 12.6 12.598 3.546 0 6.745-1.467 9.033-3.823l25.336 12.668c-.098.64-.167 1.289-.167 1.957 0 6.958 5.639 12.598 12.6 12.598 6.959 0 12.598-5.639 12.598-12.598 0-6.961-5.639-12.6-12.598-12.6-3.546 0-6.743 1.467-9.033 3.823l-25.335-12.668c.101-.638.166-1.289.166-1.955 0-.668-.065-1.317-.166-1.957l25.336-12.668c2.292 2.355 5.486 3.825 9.033 3.825 6.958 0 12.597-5.643 12.597-12.602s-5.639-12.6-12.598-12.6z"
                              fill="#36c"/>
                    </svg>
                    <div class="statsInfo">
                        <h3 class="statCount"><%=countEventos%>
                        </h3>
                        <p class="statDescription"><%=PowerUtils.localizeKey("associated.events", currentLangBundle, frontendDefaultBundle, true)%>
                        </p>
                    </div>
                </div>
                <%
                    if(countEventos>0){
                %>
                <div class="graphDiv" data-stat="5" id="grapDiv_5">
                    <div class="graphContainer" style="width: 294px">
                        <div class="graphTitle museo900 texto16"><%=PowerUtils.localizeKey("issue", currentLangBundle, frontendDefaultBundle, true)%>
                        </div>
                        <div class="graphs" id="graph_14">
                        </div>
                        <div class="graphLabel" id="label_14"></div>
                    </div>
                </div>
                <%
                    }
                %>
            </div><!---->
        </div>
    </div>
</div>


<script type="text/javascript">
    $(function () {


        $(window).load(function () {
            var charts = [
                <%
                for (Pair<JSONArray,String> chart : pies) {
                %>
                {
                    type: 'pie',
                    data: <%=chart.getLeft()%>,
                    placeholder: 'graph_<%=chart.getRight()%>',
                    label: 'label_<%=chart.getRight()%>'
                },
                <%
                }
                for (Pair<JSONArray,String> chart : lines) {
                %>
                {
                    type: 'line',
                    data: <%=chart.getLeft()%>,
                    placeholder: 'graph_<%=chart.getRight()%>',
                    label: 'label_<%=chart.getRight()%>'
                },
                <%
                }
                %>
            ];

            var launchDrawChart = function(idx,charts){
                var chart = charts[idx];
                if(chart.type=='pie')
                    drawPie(chart.data,chart.placeholder,chart.label);
                if(chart.type=='line')
                    drawLines(chart.data,chart.placeholder,chart.label);
                if(charts.length>idx+1)
                    launchDrawChart(idx+1,charts);
            };
            launchDrawChart(0,charts);
        });

    });


//    function getElementForWidth(el) {
//        var pos = ($(".grid").width() - (75)) / 210;
//        var idx = Array.prototype.indexOf.call($(".stat").toArray(), el.get(0)) + 1;
//        var statToAppendIdx = Math.ceil(idx / Math.floor(pos)) * Math.floor(pos);
//        return $($(".stat")[statToAppendIdx > $(".stat").length ? $(".stat").length - 1 : statToAppendIdx - 1]);
//    }

    var font =  {
        size: 11,
        lineHeight: 28,
        weight: "normal",
        family: "Montserrat Regular",
        color: "black"
    };

    function drawLines(data, placeholderID, labelID) {
        var placeholder18 = $("#" + placeholderID);
        if (placeholder18.length == 0) return;
        placeholder18.unbind();
        $.plot(placeholder18, [data], {
            series: {
                lines: {show: true},
                points: {show: true}
            },
            xaxis: {
                mode: "categories",
                tickLength: 0,
                axisLabelUseCanvas: true,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: "Montserrat Regular",
                font: font
            },
            yaxis: {
                font: font
            },
            grid: {
                hoverable: true,
                clickable: false,
                borderWidth: 0,
                margin: 0
            },
            highlightColor: '#333366',
            colors: ["#3366cc", "#3366cc"]
        });

        $(window).on("resize", function(e) {
            $.plot(placeholder18, [data],{
                series: {
                    lines: {show: true},
                    points: {show: true}
                },
                xaxis: {
                    mode: "categories",
                    tickLength: 0,
                    axisLabelUseCanvas: true,
                    axisLabelFontSizePixels: 12,
                    axisLabelFontFamily: "Montserrat Regular",
                    font: font
                },
                yaxis: {
                    font: font
                },
                grid: {
                    hoverable: true,
                    clickable: false,
                    borderWidth: 0,
                    margin: 0
                },
                highlightColor: '#333366',
                colors: ["#3366cc", "#3366cc"]
            });
        });

        placeholder18.bind("plothover", function (event, pos, obj) {
            if (obj) {
                var y = obj.datapoint[1];

                var html = '<div style="float:left;height:25px;text-align:center;"><span style="color:#3366cc;font-size: 10pt; font-family: \'Montserrat Regular\';">'+y+'</span></div>';
                $("#" + labelID).html(html);
            } else $("#" + labelID).html("");
        });
    }

    function drawPie(data, placeholderID, labelID) {
        var placeholder = $("#" + placeholderID);
        if (placeholder.length == 0) return;
        placeholder.unbind();
        $.plot(placeholder, data, {
            series: {
                pie: {
                    show: true,
                    radius: 1,
                    label: {
                        show: false,
                        radius: 3 / 4,
                        background: {
                            opacity: 0.5,
                            color: '#000'
                        }
                    },
                    fillColor: {colors: [{opacity: 1}, {opacity: 1}, {opacity: 1}]}
                }
            },
            legend: {show: false},
            grid: {hoverable: true},
            colors: ["#3366cc", "#99ccff"]
        });

        $(window).on("resize", function(e) {
            $.plot(placeholder, data, {
                series: {
                    pie: {
                        show: true,
                        radius: 1,
                        label: {
                            show: false,
                            radius: 3 / 4,
                            background: {
                                opacity: 0.5,
                                color: '#000'
                            }
                        },
                        fillColor: {colors: [{opacity: 1}, {opacity: 1}, {opacity: 1}]}
                    }
                },
                legend: {show: false},
                grid: {hoverable: true},
                colors: ["#3366cc", "#99ccff"]
            });
        });

        placeholder.bind("plothover", function (event, pos, obj) {
            if (obj) {
                var percent = parseFloat(obj.series.percent).toFixed(2);
                var html = ["<div style=\"float:left;height:25px;padding:0 5px;text-align:center;\">" +
                "<span style=\"color:#3366cc;font-size: 10pt;font-family: 'Montserrat Regular'\">", obj.series.label, " (", percent, "%)</span></div>"];
                $("#" + labelID).html(html.join(''));
            } else $("#" + labelID).html("");
        });
    }


</script>
<%!
    private JSONArray createDateLineChart(TreeMap<Date, Integer> dateCount, Date fDate, Date lDate, int dateField, int dateIncrement, SimpleDateFormat dateFormat, boolean accumulate) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(fDate);
        JSONArray p = new JSONArray();

        Integer count = 0;

        while (calendar.getTime().before(lDate)) {
            JSONArray val = new JSONArray();

            val.put(dateFormat.format(calendar.getTime()));

            Calendar nextMonth = Calendar.getInstance();
            nextMonth.setTime(calendar.getTime());
            nextMonth.add(dateField, dateIncrement);
            if(!accumulate)
                count=0;

            for (Date date : dateCount.keySet()) {
                if (date.equals(calendar.getTime()) || (date.after(calendar.getTime()) && date.before(nextMonth.getTime())))
                    count++;
            }

            val.put(count);

            p.put(val);
            calendar.add(dateField, dateIncrement);
        }

        return p;
    }
%>