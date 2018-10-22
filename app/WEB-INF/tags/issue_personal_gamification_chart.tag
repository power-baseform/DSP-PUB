<%@ tag import="com.baseform.apps.power.PowerUtils" %>
<%@ tag import="com.baseform.apps.power.participante.GamificationValues" %>
<%@ tag import="java.text.DecimalFormat" %>
<%@ tag import="java.text.DecimalFormatSymbols" %>
<%@ tag import="java.util.Arrays" %>
<%@ tag import="java.util.Collections" %>
<%@ tag import="java.util.Locale" %>
<%@ tag import="java.util.ResourceBundle" %>
<%@ tag import="org.apache.cayenne.ObjectContext" %>
<%@ tag import="org.apache.cayenne.access.DataContext" %>
<%@ attribute name="issue" type="com.baseform.apps.power.processo.Processo" required="false" %>
<%@ attribute name="locale" type="java.util.Locale" required="false" %>
<%@ attribute name="id" type="java.lang.String" required="true" %>
<%@ attribute name="participant" type="com.baseform.apps.power.participante.Participante" required="false" %>
<%@ attribute name="systemId" type="java.lang.String" required="true" %>
<%
    final ResourceBundle currentLangBundle = PowerUtils.getBundle(locale);
    final ResourceBundle defaultBundleLangBundle = PowerUtils.getDefaultBundle();


    boolean showOverall = false;
    boolean labelVectors = false;
    boolean labelAxis=false;
    boolean showLegend=false;

    final ObjectContext oc = participant!=null?participant.getObjectContext(): DataContext.createDataContext();
    final GamificationValues overallValues = GamificationValues.getGamificationValuesForSystem(systemId, oc);
    final GamificationValues userValues = participant!=null?participant.getGamificationValues(systemId): null;

    double overallTotal = overallValues.getTotal();
    double total = participant != null ? userValues.getTotal() : -1;

    final DecimalFormat formatUser = new DecimalFormat("0", DecimalFormatSymbols.getInstance(Locale.US));
    final DecimalFormat formatOverall = new DecimalFormat("0.00", DecimalFormatSymbols.getInstance(Locale.US));
%>

<canvas id="gamification_chart<%=id%>" class="gamification_chart_canvas"></canvas>

<script type="text/javascript">
    var ctx<%=id%> = document.getElementById("gamification_chart<%=id%>").getContext('2d');
    var personalColor = '153, 204, 255';
    var socialColor = '153, 204, 153';
    var politicalColor = '255, 153, 153';
    var personalLabel = '<%=PowerUtils.localizeKey("cat.personal.impact",currentLangBundle,defaultBundleLangBundle,true)%>';
    var socialLabel = '<%=PowerUtils.localizeKey("cat.social.impact",currentLangBundle,defaultBundleLangBundle,true)%>';
    var politicalLabel = '<%=PowerUtils.localizeKey("cat.political.impact",currentLangBundle,defaultBundleLangBundle,true)%>';

    var chartConfiguration = {
        type: 'radar',
        data: {
            labels: [
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.PERSONAL_PROBLEM_AWARENESS.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.PERSONAL_PRACTICAL_KNOWLEDGE.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.PERSONAL_READY_FOR_ACTION.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.SOCIAL_PROBLEM_AWARENESS.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.SOCIAL_PRACTICAL_KNOWLEDGE.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.SOCIAL_READY_FOR_ACTION.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.POLITICAL_PROBLEM_AWARENESS.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.POLITICAL_PRACTICAL_KNOWLEDGE.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                "<%=labelVectors?GamificationValues.GAMIFICATION_CATEGORIES.POLITICAL_READY_FOR_ACTION.toString(currentLangBundle,defaultBundleLangBundle,true):""%>",
                ""
            ],
            datasets: [
                {
                    label: personalLabel,
                    data: [
                        <%
                    if(total>0){
                    %>
                        <%=formatUser.format(userValues.getPersonalProblemAwareness())%>,
                        <%=formatUser.format(userValues.getPersonalPracticalKnowledge())%>,
                        <%=formatUser.format(userValues.getPersonalReadyForAction())%>,
                        0.0,
                        0.0,0.0,0.0,
                        0.0,
                        0.0,0.0,0.0
                        <%
                        }
                        %>
                    ],
                    backgroundColor: 'rgba(' + personalColor + ', 0.5)',
                    borderColor: 'rgba('+personalColor+', 1)',
                    borderWidth: 1
                },
                {
                    label: socialLabel,
                    data: [
                        <%
                    if(total>0){
                    %>
                        0.0,0.0,0.0,
                        0.0,
                        <%=formatUser.format(userValues.getSocialProblemAwareness())%>,
                        <%=formatUser.format(userValues.getSocialPracticalKnowledge())%>,
                        <%=formatUser.format(userValues.getSocialReadyForAction())%>,
                        0.0,
                        0.0,0.0,0.0
                        <%
                        }
                        %>
                    ],
                    backgroundColor: 'rgba(' + socialColor + ', 0.5)',
                    borderColor: 'rgba('+socialColor+', 1)',
                    borderWidth: 1
                },
                {
                    label: politicalLabel,
                    data: [
                        <%
                    if(total>0){
                    %>
                        0.0,0.0,0.0,
                        0.0,
                        0.0,0.0,0.0,
                        0.0,
                        <%=formatUser.format(userValues.getPoliticalProblemAwareness())%>,
                        <%=formatUser.format(userValues.getPoliticalPracticalKnowledge())%>,
                        <%=formatUser.format(userValues.getPoliticalReadyForAction())%>
                        <%
                        }
                        %>
                    ],
                    backgroundColor: 'rgba(' + politicalColor + ', 0.5)',
                    borderColor: 'rgba('+politicalColor+', 1)',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive:true,
            animationDuration:700,
            scale: {
                gridLines:{
                    circular:true,
                    display: true,
                    <%=!labelVectors?"stepSize:100":""%>
                },
                beginAtZero: true,
                angleLines:{
                    display: true
                },
                pointLabels:{
                    display: <%=labelVectors%>,
                    fontFamily: 'Montserrat, Arial, Helvetica, \"sans-serif\"'
                },
                ticks: {
                    callback: function(value, index, values) {
                        return <%=labelAxis%>&&index%2==0?value:'';
                    }
                }
            },
            legend: {
                display: <%=showLegend%>,
                position: 'bottom',
                fullWidth: true,
                labels: {
                    fontFamily: 'Montserrat, Arial, Helvetica, \"sans-serif\"'
                }
            },
            tooltips:{
                bodyFontFamily: 'Montserrat, Arial, Helvetica, \"sans-serif\"',
                titleFontFamily: 'Montserrat, Arial, Helvetica, \"sans-serif\"',
                footerFontFamily: 'Montserrat, Arial, Helvetica, \"sans-serif\"',
                callbacks: {
                    labelColor: function(tooltipItem, chart) {
                        return {
                            backgroundColor: chart.data.datasets[tooltipItem.datasetIndex].backgroundColor,
                            borderColor: chart.data.datasets[tooltipItem.datasetIndex].borderColor
                        }
                    }
                }
            }
        }
    };
    var myChart<%=id%> = new Chart(ctx<%=id%>,chartConfiguration);


</script>