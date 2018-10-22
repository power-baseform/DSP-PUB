<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.baseform.apps.power.frontend.FrontendUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.processo.Processo" %>
<%@ page import="com.baseform.apps.power.processo.Evento" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.cayenne.DataObjectUtils" %>
<%@ page import="com.baseform.apps.power.participante.Participante" %>
<%@ page import="com.baseform.apps.power.utils.RequestParameters" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="twitter4j.Status" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.util.Locale" %>
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
    Processo processo = pm.getProcess();
    Participante participante = pm.getParticipante();
    List<Evento> eventos = processo.getEventos();
    final ResourceBundle frontendDefaultBundle = pm.getDefaultLangBundle();
    final ResourceBundle currentLangBundle = pm.getCurrentLangBundle();
    DateFormat df = new SimpleDateFormat("dd MMMM yyyy", Locale.US);

%>
<link href="redesign_css/account.css" rel="stylesheet" type="text/css">
<link href="redesign_css/customCheckbox.css" rel="stylesheet" type="text/css">

<div class="section tweets events">
    <div class="grid">
        <h3 class="title"><%=PowerUtils.localizeKey("latest.tweets",currentLangBundle,frontendDefaultBundle)%></h3>
        <ul class="issueList">
            <% if(processo.getHashtags() != null && !processo.getHashtags().trim().isEmpty()){
                String consumerKey = request.getServletContext().getInitParameter("consumer_key");
                String consumerSecret = request.getServletContext().getInitParameter("consumer_secret");
                String accessToken = request.getServletContext().getInitParameter("access_token");
                String accessTokenSecret = request.getServletContext().getInitParameter("access_token_secret");
                final List<Status> tweets = PowerPubManager.SearchTweetsAsList(processo.getHashtags(), 5, consumerKey, consumerSecret, accessToken, accessTokenSecret, 5 * 60 * 1000, pm.getCurrentLocale());
                if(tweets!=null && !tweets.isEmpty()){
                    for (Status tweet : tweets) { %>
                        <li class="issue">
                            <a class="title" target="blank" href="https://twitter.com/<%=tweet.getUser().getName()%>/status/<%=tweet.getId()%>" class="eventLink">@<%=tweet.getUser().getName()%></a> <p class="date"><%= df.format(tweet.getCreatedAt())%></p>
                            <h3 class="details"><%= tweet.getText()%></h3>
                        </li>
                    <%}
                } %>
        </ul>
        <%if (tweets.size() == 0) {%>
            <h3 class="notFollowing"><%=PowerUtils.localizeKey("msg.no.tweets",currentLangBundle,frontendDefaultBundle)%></h3>
        <%}}%>
    </div>
</div>
<script>
</script>