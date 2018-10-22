/*
 * Baseform
 * Copyright (C) 2018  Baseform
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.baseform.apps.power.frontend;

import com.baseform.apps.power.PowerUtils;
import com.baseform.apps.power.json.JSONException;
import com.baseform.apps.power.participante.Messages;
import com.baseform.apps.power.participante.Participante;
import com.baseform.apps.power.participante.RParticipanteProcesso;
import com.baseform.apps.power.processo.Documento;
import com.baseform.apps.power.processo.Evento;
import com.baseform.apps.power.processo.Processo;
import org.apache.cayenne.CayenneRuntimeException;
import org.apache.cayenne.DataObjectUtils;
import org.apache.cayenne.access.DataContext;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.SelectQuery;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

/**
 * Created by joaofeio on 02/03/17.
 */
public class MailerTask implements ServletContextListener {
    private static boolean running = false;

    private String url = "";
    private String host = "";
    private String smtp_server_port = "";
    private boolean smtp_ssl = false;
    private String username = "";
    private String password = "";
    private String from = "";
    private String deployment = "";
    private String system = "";
    private Timer timerMail;

    private final static long EMAIL_INIT_DELAY_MS = 5L * 60L * 1000L ; //5mins
    private final static long EMAIL_SCAN_PERIOD_MS = 1000 * 60 * 1440; // 1440 min - 24 h


    private synchronized boolean isRunning() {
        if (!running) {
            running = true;
            return false;
        }
        return true;
    }

    public void sendEmails() {

        if (isRunning()) {
            PowerUtils.logInfo("MailerTask is running. Come back later.", MailerTask.class);
            return;
        }
        PowerUtils.logInfo("POWER MailerTask start run.", MailerTask.class);


        final ResourceBundle defaultBundle = FrontendUtils.getFrontendDefaultBundle();

        DataContext dc = DataContext.createDataContext();


        running = true;
        Date now = new Date();

        Calendar cal = Calendar.getInstance();   //now
        Calendar cal1 = Calendar.getInstance();   //now


        cal.add(Calendar.DATE, -2);
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);

        cal1.add(Calendar.DATE, -1);
        cal1.set(Calendar.HOUR_OF_DAY, 23);
        cal1.set(Calendar.MINUTE, 59);
        cal1.set(Calendar.SECOND, 59);


        List<Participante> mapa = new ArrayList<>();
        HashMap<Participante, String> mapProcessos = new HashMap<Participante, String>();


        SelectQuery qe = new SelectQuery(Evento.class);
        qe.setQualifier(ExpressionFactory.betweenExp(Evento.DATA_REGISTO_PROPERTY, cal.getTime(), cal1.getTime()));
        qe.andQualifier(ExpressionFactory.matchExp(Evento.PROCESSO_PROPERTY + '.' + Processo.PUBLICADO_PROPERTY, true));
        qe.andQualifier(ExpressionFactory.matchExp(Evento.PROCESSO_PROPERTY + '.' + Processo.SISTEMA_PROPERTY, system));
        List<Evento> eventos = dc.performQuery(qe);

        SelectQuery qd = new SelectQuery(Documento.class);
        qd.setQualifier(ExpressionFactory.betweenExp(Documento.DATA_DOCUMENTO_PROPERTY, cal.getTime(), cal1.getTime()));
        qd.andQualifier(ExpressionFactory.matchExp(Documento.PROCESSO_PROPERTY + '.' + Processo.PUBLICADO_PROPERTY, true));
        qd.andQualifier(ExpressionFactory.matchExp(Documento.PROCESSO_PROPERTY + '.' + Processo.SISTEMA_PROPERTY, system));

        List<Documento> documentos = dc.performQuery(qd);

        SelectQuery qseguir = new SelectQuery(RParticipanteProcesso.class);
        qseguir.setQualifier(ExpressionFactory.matchExp(RParticipanteProcesso.IS_FOLLOWING_PROPERTY, true));
        qseguir.andQualifier(ExpressionFactory.matchExp(RParticipanteProcesso.PROCESSO_PROPERTY + "." + Processo.SISTEMA_PROPERTY, system));

        List<RParticipanteProcesso> processoSeguidos = dc.performQuery(qseguir);

        HashMap<Participante, String> mapEventos = new HashMap<Participante, String>();
        HashMap<Participante, String> mapDocumentos = new HashMap<Participante, String>();

        String includes = "<link href=\"https://fonts.googleapis.com/css?family=Montserrat\" rel=\"stylesheet\">" + "<style>" +
            "* { font-family: 'Montserrat', sans-serif; }"+
        "</style>";

        for (RParticipanteProcesso processoSeguido : processoSeguidos) {
            Participante participante = processoSeguido.getParticipante();
            Processo processo = processoSeguido.getProcesso();

            Locale preferred_locale = null;
            try {
                preferred_locale = participante.getPreferredLocale();
            } catch (JSONException e) {
                PowerUtils.logErr(e, MailerTask.class);
            }
            final ResourceBundle bundle = FrontendUtils.getFrontendBundle(preferred_locale != null ? preferred_locale : PowerUtils.getDefaultLocale());

            for (Evento evento : eventos) {

                if (evento.getProcesso().getId() == processo.getId()) {

                    if (mapEventos.containsKey(participante)) {
                        String s = mapEventos.get(participante);
                        String s1 = "<br/><a target=\"_blank\" href=\""+url + "/?location=challenge&loadP=" + processo.getId()+"\">"+ processo.getTitulo() + ": " + evento.getDesignacao() + " - " + PowerUtils.DATE_FORMAT.format(evento.getData())+"</a>";
                        if (!s.contains(s1)) {
                            s += s1 + "<br/>";
                        }
                        mapEventos.put(participante, s);
                    } else {
                        if (!mapa.contains(participante))
                            mapa.add(participante);

                        String s = "<br/><br/><span style=\"font-weight:bold\">"+PowerUtils.localizeKey("new.events.scheduled", bundle, defaultBundle)+"</span><br/><br/>" +"<a target=\"_blank\" href=\""+url + "/?location=challenge&loadP=" + processo.getId()+"\">"+ processo.getTitulo() + ": " + evento.getDesignacao() + " - " + PowerUtils.DATE_FORMAT.format(evento.getData())+"</a>";
                        mapEventos.put(participante, s);
                    }
                }
            }

            for (Documento documento : documentos) {

                if (documento.getProcesso().getId() == processo.getId()) {

                    if (mapDocumentos.containsKey(participante)) {
                        String s = mapDocumentos.get(participante);
                        String s1 = "<br/><a target=\"_blank\" href=\""+url + "/?location=challenge&loadP=" + processo.getId()+"\">"+ processo.getTitulo() + ": " + documento.getDesignacao() +"</a>";
                        if (!s.contains(s1)) {
                            s += s1 + "<br/>";
                        }
                        mapDocumentos.put(participante, s);
                    } else {
                        if (!mapa.contains(participante))
                            mapa.add(participante);

                        String s = "<br/><br/><span style=\"font-weight:bold\">"+PowerUtils.localizeKey("new.documents.available", bundle, defaultBundle)+"</span><br/><br/><a target=\"_blank\" href=\""+url + "/?location=challenge&loadP=" + processo.getId()+"\">"+ processo.getTitulo() + ": " + documento.getDesignacao() +"</a>";
                        mapDocumentos.put(participante, s);
                    }
                }
            }
        }

        Calendar cal2 = Calendar.getInstance();   //now
        cal2.set(Calendar.HOUR_OF_DAY, 0);       //hoje  0:00
        cal2.set(Calendar.MINUTE, 0);
        cal2.set(Calendar.SECOND, 0);

        for (Participante participante : mapa) {
            Locale preferred_locale = null;
            try {
                preferred_locale = participante.getPreferredLocale();
            } catch (JSONException e) {
                PowerUtils.logErr(e, MailerTask.class);
            }
            final ResourceBundle bundle = FrontendUtils.getFrontendBundle(preferred_locale != null ? preferred_locale : PowerUtils.getDefaultLocale());

            String textoInicio = PowerUtils.localizeKey("notification.intro", bundle, defaultBundle, new String []{deployment});
            String textoFim = "<br/><br/>"+PowerUtils.localizeKey("msg.notification.preferences", bundle, defaultBundle)+"<br/><br/><span style=\"font-weight:bold\">"+PowerUtils.localizeKey("notification.signature", bundle, defaultBundle, new String []{deployment})+"</span>\n";

            String txt = "";

            SelectQuery sq = new SelectQuery(Messages.class);
            sq.setQualifier(ExpressionFactory.betweenExp(Messages.DATE_PROPERTY, cal2.getTime(), new Date()));
            sq.andQualifier(ExpressionFactory.matchExp(Messages.PARTICIPANTE_PROPERTY, participante));
            sq.andQualifier(ExpressionFactory.matchExp(Messages.SISTEMA_PROPERTY, system));

            List<Messages> list = dc.performQuery(sq);

            if (list.isEmpty() && participante.getEmail().contains("@")) {
                Messages m = new Messages();
                m.setAbout(PowerUtils.localizeKey("dsp.news", bundle, defaultBundle, new String []{deployment}));
                m.setParticipante(participante);

                m.setStatus(Messages.NOT_SENT);
                m.setSistema(system);

                String s = mapProcessos.get(participante);

                if(s!=null) {
                    txt = s;
                }

                s = mapDocumentos.get(participante);

                if(s!=null) {
                    txt += s;
                }

                s = mapEventos.get(participante);

                if(s!=null) {
                    txt += s;
                }

                m.setBody(includes + textoInicio + " " + txt + " " + textoFim);
                dc.commitChanges();
            }
        }

        SelectQuery q = new SelectQuery(Messages.class);
        q.setQualifier(ExpressionFactory.matchExp(Messages.STATUS_PROPERTY, Messages.NOT_SENT));
        q.andQualifier(ExpressionFactory.matchExp(Messages.SISTEMA_PROPERTY, system));

        List<Messages> ms = dc.performQuery(q);

        for (Messages m : ms) {
            final Participante participante = m.getParticipante();

            String txt = m.getBody();
            String sbj = m.getAbout();
            String to = participante.getEmail();
            try {
                PowerUtils.sendEmail(host, smtp_ssl, smtp_server_port, username, password, from, sbj, txt, to);
                m.setStatus(Messages.SENT);
                PowerUtils.logInfo("Sent email to " + to + " with subject " + sbj, MailerTask.class);
                m.setDate(now);
            } catch (Exception e) {
                PowerUtils.logInfo("Error send  " + to + " with subject " + sbj, MailerTask.class);
                PowerUtils.logErr(e, MailerTask.class);
                m.setStatus(Messages.ERROR);
            }

            try {
                dc.commitChanges();
            } catch (CayenneRuntimeException r) {
                PowerUtils.logErr(r, MailerTask.class);
                dc.rollbackChanges();
            }
        }

        PowerUtils.logInfo("MailerTask end run.", MailerTask.class);
        running = false;
    }

    private void initMailerTask(ServletContextEvent servletContextEvent) {
        if(servletContextEvent.getServletContext().getInitParameter("send_emails") != null && servletContextEvent.getServletContext().getInitParameter("send_emails").equals("true")) {
            timerMail = new Timer("pubEmailListener", true);
            timerMail.schedule(new TimerTask() {
                @Override
                public void run() {
                    try {
                        PowerUtils.logInfo("Will send PUB emails", MailerTask.class);
                        sendEmails();
                    } catch (Exception e) {
                        PowerUtils.logErr(e, MailerTask.class);
                    }
                }
            }, EMAIL_INIT_DELAY_MS, EMAIL_SCAN_PERIOD_MS);
            PowerUtils.logInfo("Init", MailerTask.class);
        }
    }

    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        url = servletContextEvent.getServletContext().getInitParameter("server_href");
        host = servletContextEvent.getServletContext().getInitParameter("smtp_server");
        smtp_server_port = servletContextEvent.getServletContext().getInitParameter("smtp_port");

        final String tempSMTP_SSL = servletContextEvent.getServletContext().getInitParameter("smtp_use_ssl");
        smtp_ssl = false;
        if (tempSMTP_SSL != null)
            smtp_ssl = Boolean.parseBoolean(tempSMTP_SSL);

        username = servletContextEvent.getServletContext().getInitParameter("smtp_username");
        password = servletContextEvent.getServletContext().getInitParameter("smtp_password");
        from = servletContextEvent.getServletContext().getInitParameter("from");
        deployment = servletContextEvent.getServletContext().getInitParameter("deployment_name");
        system = servletContextEvent.getServletContext().getInitParameter("current_system");

        initMailerTask(servletContextEvent);
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
        running = false;
        if(timerMail !=null)
            timerMail.cancel();
    }
}