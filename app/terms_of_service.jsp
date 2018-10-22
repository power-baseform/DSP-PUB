<%@ page import="com.baseform.apps.power.PowerUtils" %>
<%@ page import="com.baseform.apps.power.frontend.PowerPubManager" %>
<%@ page import="com.baseform.apps.power.frontend.PublicManager" %><%--
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

<%--
  Created by IntelliJ IDEA.
  User: snunes
  Date: 31/07/17
  Time: 17:22
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% PowerPubManager pm = (PowerPubManager) PublicManager.get(request,PowerPubManager.class);%>
<html>
<head>
    <title>Terms of service</title>
    <style>
        <!--
        /* Font Definitions */
        @font-face
        {font-family:Arial;
            panose-1:2 11 6 4 2 2 2 2 2 4;}
        @font-face
        {font-family:"Courier New";
            panose-1:2 7 3 9 2 2 5 2 4 4;}
        @font-face
        {font-family:Wingdings;
            panose-1:5 0 0 0 0 0 0 0 0 0;}
        @font-face
        {font-family:"Cambria Math";
            panose-1:2 4 5 3 5 4 6 3 2 4;}
        @font-face
        {font-family:Calibri;
            panose-1:2 15 5 2 2 2 4 3 2 4;}
        @font-face
        {font-family:"Segoe UI";}
        /* Style Definitions */
        p.MsoNormal, li.MsoNormal, div.MsoNormal
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Calibri;}
        h1
        {margin-top:7.0pt;
            margin-right:0cm;
            margin-bottom:0cm;
            margin-left:5.85pt;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Arial;
            font-weight:bold;}
        h3
        {margin-top:2.0pt;
            margin-right:0cm;
            margin-bottom:0cm;
            margin-left:0cm;
            margin-bottom:.0001pt;
            font-size:12.0pt;
            font-family:Cambria;
            color:#243F60;
            font-weight:normal;}
        p.MsoCommentText, li.MsoCommentText, div.MsoCommentText
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:10.0pt;
            font-family:Calibri;}
        p.MsoHeader, li.MsoHeader, div.MsoHeader
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Calibri;}
        p.MsoFooter, li.MsoFooter, div.MsoFooter
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Calibri;}
        p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
        {margin-top:0cm;
            margin-right:0cm;
            margin-bottom:0cm;
            margin-left:5.85pt;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Arial;}
        a:link, span.MsoHyperlink
        {color:#0563C1;
            text-decoration:underline;}
        a:visited, span.MsoHyperlinkFollowed
        {color:purple;
            text-decoration:underline;}
        p
        {margin-top:0cm;
            margin-right:0cm;
            margin-bottom:7.5pt;
            margin-left:0cm;
            font-size:12.0pt;
            font-family:"Times New Roman";}
        p.MsoCommentSubject, li.MsoCommentSubject, div.MsoCommentSubject
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:10.0pt;
            font-family:Calibri;
            font-weight:bold;}
        p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:9.0pt;
            font-family:"Segoe UI","sans-serif";}
        p.MsoRMPane, li.MsoRMPane, div.MsoRMPane
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Calibri;}
        p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Calibri;}
        p.TableParagraph, li.TableParagraph, div.TableParagraph
        {margin:0cm;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:Calibri;}
        span.Heading3Char
        {font-family:Cambria;
            color:#243F60;}
        span.CommentSubjectChar
        {font-weight:bold;}
        span.BalloonTextChar
        {font-family:"Segoe UI","sans-serif";}
        .MsoChpDefault
        {font-size:11.0pt;
            font-family:Calibri;}
        /* Page Definitions */
        @page WordSection1
        {size:595.0pt 841.0pt;
            margin:52.0pt 50.0pt 63.8pt 48.0pt;}
        div.WordSection1
        {page:WordSection1;}
        /* List Definitions */
        ol
        {margin-bottom:0cm;}
        ul
        {margin-bottom:0cm;}
        -->
    </style>

</head>

<body lang=EN-US link="#0563C1" vlink=purple>
    <%= PowerUtils.getTermsOfServiceDescription(pm.getCurrentLocale(), pm.getSystemId(request), pm.getDc(request))%>
</body>

</html>