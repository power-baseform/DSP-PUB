<%@ tag import="com.baseform.apps.power.PowerUtils" %>
<%@ tag import="com.baseform.apps.power.participante.GamificationValues" %>
<%@ tag import="java.text.DecimalFormat" %>
<%@ tag import="java.text.DecimalFormatSymbols" %>
<%@ tag import="java.util.Arrays" %>
<%@ tag import="java.util.Collections" %>
<%@ tag import="java.util.Locale" %>
<%@ tag import="java.util.ResourceBundle" %>
<%@ attribute name="issue" type="com.baseform.apps.power.processo.Processo" required="false" %>
<%@ attribute name="locale" type="java.util.Locale" required="false" %>
<%@ attribute name="id" type="java.lang.String" required="true" %>
<%@ attribute name="labelVectors" type="java.lang.Boolean" required="false" %>
<%@ attribute name="labelAxis" type="java.lang.Boolean" required="false" %>
<%@ attribute name="showLegend" type="java.lang.Boolean" required="false" %>
<%
    final ResourceBundle currentLangBundle = PowerUtils.getBundle(locale);
    final ResourceBundle defaultBundleLangBundle = PowerUtils.getDefaultBundle();

    if(labelVectors==null)
        labelVectors = false;
    if(labelAxis==null)
        labelAxis=false;
    if(showLegend==null)
        showLegend=false;

    final GamificationValues issueValues = issue.getGamificationValues();

    final DecimalFormat format = new DecimalFormat("0", DecimalFormatSymbols.getInstance(Locale.US));
    final Double personalProblemAwareness = issueValues.getPersonalProblemAwareness();
    final Double personalPracticalKnowledge = issueValues.getPersonalPracticalKnowledge();
    final Double personalReadyForAction = issueValues.getPersonalReadyForAction();
    final Double socialProblemAwareness = issueValues.getSocialProblemAwareness();
    final Double socialPracticalKnowledge = issueValues.getSocialPracticalKnowledge();
    final Double socialReadyForAction = issueValues.getSocialReadyForAction();
    final Double politicalProblemAwareness = issueValues.getPoliticalProblemAwareness();
    final Double politicalPracticalKnowledge = issueValues.getPoliticalPracticalKnowledge();
    final Double politicalReadyForAction = issueValues.getPoliticalReadyForAction();
    final Double max = Collections.max(Arrays.asList(personalProblemAwareness, personalPracticalKnowledge, personalReadyForAction, socialProblemAwareness, socialPracticalKnowledge, socialReadyForAction, politicalProblemAwareness, politicalPracticalKnowledge, politicalReadyForAction));
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
                        <%=format.format(personalProblemAwareness)%>,
                        <%=format.format(personalPracticalKnowledge)%>,
                        <%=format.format(personalReadyForAction)%>,
                        0.0,
                        0.0,0.0,0.0,
                        0.0,
                        0.0,0.0,0.0
                    ],
                    backgroundColor: 'rgba(' + personalColor + ', 1)',
                    borderWidth:0,
                    <%=!labelVectors?"pointRadius:0":""%>

                },
                {
                    label: socialLabel,
                    data: [
                        0.0,0.0,0.0,
                        0.0,
                        <%=format.format(socialProblemAwareness)%>,
                        <%=format.format(socialPracticalKnowledge)%>,
                        <%=format.format(socialReadyForAction)%>,
                        0.0,
                        0.0,0.0,0.0
                    ],
                    backgroundColor: 'rgba(' + socialColor + ', 1)',
                    borderWidth:0,
                    <%=!labelVectors?"pointRadius:0":""%>
                },
                {
                    label: politicalLabel,
                    data: [
                        0.0,0.0,0.0,
                        0.0,
                        0.0,0.0,0.0,
                        0.0,
                        <%=format.format(politicalProblemAwareness)%>,
                        <%=format.format(politicalPracticalKnowledge)%>,
                        <%=format.format(politicalReadyForAction)%>
                    ],
                    backgroundColor: 'rgba(' + politicalColor + ', 1)',
                    borderWidth:0,
                    <%=!labelVectors?"pointRadius:0":""%>
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
                    <%
                    if(!labelVectors&&!showLegend){
                    %>
                    max:<%=format.format(max+1)%>,
                    <%
                    }
                    %>
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