<%@ page import="com.baseform.apps.power.PowerUtils"
%><%@ page import="com.baseform.apps.power.frontend.PowerPubManager"
%><%@ page import="com.baseform.apps.power.participante.Participante"
%><%@ page import="com.baseform.apps.power.processo.GotItSection"
%><%@ page import="com.baseform.apps.power.processo.Processo"
%><%@ page import="com.baseform.apps.power.processo.Seccao"
%><%@ page import="com.baseform.apps.power.utils.RequestParameters"
%><%@ page import="com.baseform.apps.power.json.JSONObject"
%><%@ page import="org.apache.cayenne.DataObjectUtils"
%><%@ page import="org.apache.cayenne.ObjectContext"
%><%@ page import="com.baseform.apps.power.frontend.PublicManager"%><%@ page contentType="application/json;charset=UTF-8" language="java" %><%--
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
    final PublicManager pm = PublicManager.get(request);
    final Participante participante = pm==null?null:pm.getParticipante();
    final JSONObject res = new JSONObject();
    res.put("gotit",false);
    if(participante!=null){
        if(request.getParameter(RequestParameters.GOT_IT_SECTION)!=null && !request.getParameter(RequestParameters.GOT_IT_SECTION).isEmpty()){
            final ObjectContext dc = pm.getDc(request);
            final Seccao section = DataObjectUtils.objectForPK(dc, Seccao.class, request.getParameter(RequestParameters.GOT_IT_SECTION));
            if(section!=null && !participante.hasGotSection(section)){
                final GotItSection gotItSection = dc.newObject(GotItSection.class);
                gotItSection.setParticipante((Participante) dc.localObject(participante.getObjectId(),participante));
                gotItSection.setSeccao(section);
                try{
                    dc.commitChanges();
                    participante.logAction(section.getProcesso(),DataObjectUtils.pkForObject(section).toString(),Processo.GAMIFICATION_ACTIONS.GOT_IT_SECTION,request);
                    res.put("points",request.getAttribute(RequestParameters.POINTS_AWARDED));
                    res.put("gotit",true);
                } catch (Exception e){
                    PowerUtils.logErr(e,getClass(),participante);
                }
            }
        }
    }
    out.write(res.toString(2));
%>
