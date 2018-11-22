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
import com.baseform.apps.power.json.JSONArray;
import com.baseform.apps.power.json.JSONException;
import com.baseform.apps.power.json.JSONObject;
import com.baseform.apps.power.participante.Participante;
import com.baseform.apps.power.participante.ParticipanteImagem;
import com.baseform.apps.power.participante.RParticipanteNotTipologia;
import com.baseform.apps.power.participante.RParticipanteSistema;
import com.baseform.apps.power.processo.*;
import com.baseform.apps.power.utils.RequestParameters;
import com.baseform.apps.power.utils.SmartRequest;
import nl.captcha.Captcha;
import org.apache.cayenne.DataObjectUtils;
import org.apache.cayenne.DataRow;
import org.apache.cayenne.ObjectContext;
import org.apache.cayenne.access.DataContext;
import org.apache.cayenne.exp.Expression;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.Ordering;
import org.apache.cayenne.query.SQLTemplate;
import org.apache.cayenne.query.SelectQuery;
import org.apache.cayenne.query.SortOrder;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.lang.reflect.Constructor;
import java.util.*;

/**
 * Created by snunes on 12/09/17.
 *
 */
@SuppressWarnings({"unchecked","unused"})
public abstract class PublicManager {

    String errors = null;
    protected String msg = null;
    private Locale curr_locale;
    protected ResourceBundle manBundle;
    private JSONObject translations;
    protected Participante participant;
    protected Processo challenge;
    private Seccao section;

    protected String current_location;

    private static String DIR_DOCS;

    private boolean mobileRequest;
    private boolean failedLogin;
    List<Locale> locales;

    protected PublicManager(HttpServletRequest request) {
        curr_locale = PowerUtils.getDefaultLocale();
        DIR_DOCS = request.getSession().getServletContext().getInitParameter("docs").startsWith("/")
                ? request.getSession().getServletContext().getInitParameter("docs")
                : request.getServletContext().getRealPath("/")+request.getSession().getServletContext().getInitParameter("docs");

    }

    protected PublicManager(Participante participant, HttpServletRequest request) {
        this(request);
        this.participant = participant;
        if(participant!=null)
            try {
                if (participant.getMetadata() != null && !participant.getMetadata().isEmpty()) {
                    curr_locale = new Locale(PowerUtils.getStringAsJson(participant.getMetadata()).get("locale").toString());
                } else if (curr_locale != null) {
                    participant.setMetadata(PowerUtils.getStringAsJson(participant.getMetadata()).put("locale", curr_locale.getLanguage()).toString());
                    getDc(request).commitChanges();
                }
            } catch (Exception e) {
                PowerUtils.logErr(e, getClass(), participant);
            }
    }

    public static PublicManager get(HttpServletRequest request) {
        return (PublicManager) request.getSession().getAttribute(PublicManager.class.getSimpleName());
    }

    public static PublicManager get(HttpServletRequest request, Class<?extends PublicManager> type) {
        PublicManager publicManager = get(request);
        if(publicManager!=null && type.equals(publicManager.getClass()))
            return publicManager;
        final Constructor<? extends PublicManager> constructor;
        try {
            constructor = type.getConstructor(HttpServletRequest.class);
            publicManager = constructor.newInstance(request);
            request.getSession().setAttribute(PublicManager.class.getSimpleName(),publicManager);
            return publicManager;
        } catch (Exception e) {
            PowerUtils.logErr(e,PublicManager.class);
        }
        return null;
    }

    protected void set(HttpServletRequest request) {
        request.getSession().setAttribute(PublicManager.class.getSimpleName(), this);
    }

    protected abstract PublicManager getNewInstance(HttpServletRequest request, Participante u);


    public boolean getFailedLogin() {
        if (participant != null) setFailedLogin(false);
        return failedLogin;
    }

    public void setFailedLogin(boolean status) { failedLogin = status; }

    public String getCurrentLocation(){
        return current_location+".jsp";
    }

    public String getCurrentLocationName(){
        return current_location;
    }

    public String getSystemId(HttpServletRequest request){
        return request.getServletContext().getInitParameter("current_system");
    }

    public Participante getParticipant(ObjectContext oc) {
        if(participant==null)
            return null;
        return (Participante) oc.localObject(participant.getObjectId(),participant);
    }
    public Participante getParticipante() {
        return participant;
    }

    private ObjectContext getAppDc(HttpServletRequest request){
        ObjectContext oc;
        final String attName = ObjectContext.class.getName();
        final String attNameTime = ObjectContext.class.getName()+"_time";
        final ServletContext servletContext = request.getSession().getServletContext();
        synchronized (PublicManager.class) {
            oc = (ObjectContext) servletContext.getAttribute(attName);
            final Long time = (Long) servletContext.getAttribute(attNameTime);

            if(oc==null||time==null||time<System.currentTimeMillis()-1000*60*5) {
                oc = DataContext.createDataContext(false);
                servletContext.setAttribute(attName,oc);
                servletContext.setAttribute(attNameTime,System.currentTimeMillis());
            }
        }

        return oc;
    }

    public ObjectContext getDc(HttpServletRequest request) {
        return getAppDc(request);
    }

    public void renewDc(HttpServletRequest request) {
        final ServletContext servletContext = request.getSession().getServletContext();
        final String attName = ObjectContext.class.getName();
        synchronized (PublicManager.class) {
            servletContext.removeAttribute(attName);
        }
        PowerUtils.logInfo("Renew app ObjectContext. Session: "+request.getSession().getId(),getClass(),participant);
    }




    public JSONObject getTranslations() throws com.baseform.apps.power.json.JSONException {
        if(translations==null)
            translations = new JSONObject();

        Locale currentLocale = getCurrentLocale();
        if(!translations.has(currentLocale.getLanguage())){
            ResourceBundle currentBundle = getCurrentLangBundle();
            JSONObject currentObj = new JSONObject();
            translations.put(currentLocale.getLanguage(), currentObj);
            for (Object key : Collections.list(currentBundle.getKeys())) {
                currentObj.put(key.toString(),currentBundle.getString(key.toString()));
            }
        }


        Locale defaultLocale = PowerUtils.getDefaultLocale();
        if(!translations.has(defaultLocale.getLanguage()) && !defaultLocale.equals(currentLocale)){
            ResourceBundle defaultBundle = getDefaultLangBundle();
            JSONObject defaultObj = new JSONObject();
            translations.put(defaultLocale.getLanguage(), defaultObj);
            for (Object key : Collections.list(defaultBundle.getKeys())) {
                defaultObj.put(key.toString(),defaultBundle.getString(key.toString()));
            }
        }

        translations.put("defaultLocale", defaultLocale.getLanguage());
        return translations;
    }

    protected void changeLocale(HttpServletRequest request) {
        String newLocale = request.getParameter(RequestParameters.CHANGE_LOCALE);
        final ObjectContext dc = getDc(request);
        final Participante participant = getParticipant(dc);
        if (!newLocale.equals("") && !curr_locale.getLanguage().equals(newLocale)) {
            curr_locale = new Locale(newLocale);
            manBundle = null;
            if(participant!=null) {
                try {
                    JSONObject json = new JSONObject();
                    json.put("locale", curr_locale.getLanguage());
                    participant.setMetadata(json.toString());
                    dc.commitChanges();
                }catch(Exception e) {
                    PowerUtils.logErr(e, getClass(), participant);
                }
            }
            final Processo challenge = getChallenge(dc);
            if(challenge!=null){
                if(!challenge.getLocale().equals(newLocale))
                    this.challenge = Processo.getProcessoForCodeAndLocale(challenge.getCodigo(),newLocale, getDefaultLangBundle().getLocale().getLanguage(), challenge.getSistema(),dc);
            }
        }

    }

    public Locale getCurrentLocale() {
        //TODO ler header html e descobrir lingua do navegante
        return curr_locale != null ? curr_locale : PowerUtils.getDefaultLocale();
    }

    public abstract ResourceBundle getCurrentLangBundle();

    public abstract ResourceBundle getDefaultLangBundle();

    public List<Locale> getLocales(HttpServletRequest request) {
        if (locales != null && locales.size() > 0) return locales;

        locales = new ArrayList<>(PowerUtils.getAvailableLocales(request));

        String current_system = request.getServletContext().getInitParameter("current_system");
        SelectQuery selectQuery1 = new SelectQuery(SystemLanguages.class, ExpressionFactory.matchExp(SystemLanguages.SYSTEM_ID_PROPERTY, current_system));
        List<SystemLanguages> list1 = getDc(request).performQuery(selectQuery1);

        List<String> strLocales = new ArrayList<>();
        for (SystemLanguages systemLanguages : list1) {
            strLocales.add(systemLanguages.getLanguage().getLocale());
        }

        List<Locale> toRemove = new ArrayList<>();

        for (Locale locale : locales) {
            if (!strLocales.contains(locale.toString())) toRemove.add(locale);
        }

        locales.remove(getCurrentLocale());
        locales.removeAll(toRemove);
        locales.sort(Comparator.comparing(o -> o.getDisplayLanguage(o)));

        return locales;
    }


    public boolean systemHasLocale(HttpServletRequest request, Locale locale) {
        String current_system = request.getServletContext().getInitParameter("current_system");

        SelectQuery selectQuery = new SelectQuery(Languages.class, ExpressionFactory.matchExp(Languages.LOCALE_PROPERTY, locale.toString()));
        List<Languages> list = getDc(request).performQuery(selectQuery);

        if (list.size() == 0) return false;
        Languages lang = list.get(0);

        SelectQuery selectQuery1 = new SelectQuery(SystemLanguages.class, ExpressionFactory.matchExp(SystemLanguages.LANGUAGE_PROPERTY, lang).andExp(ExpressionFactory.matchExp(SystemLanguages.SYSTEM_ID_PROPERTY, current_system)));
        List list1 = getDc(request).performQuery(selectQuery1);

        return list1.size() > 0;
    }

    public void process(HttpServletRequest request, HttpServletResponse response){
        errors = "";
        msg = "";

        set(request);

        //Periodically renew data context

        final Long time = (Long) request.getSession().getAttribute(ObjectContext.class.getName() + "_time");
        if (time == null || time < System.currentTimeMillis() - 1000 * 60 * 5)
            renewDc(request);

        if (request.getParameter(RequestParameters.LOGOUT) != null) {
            final String currLoc = getCurrentLocale().getLanguage();

            String url = "./?location=home&" + RequestParameters.CHANGE_LOCALE + "=" + currLoc;
            if (isMobileRequest()) url += "&mobileReq=true";

            request.getSession().invalidate();
            try {
                response.sendRedirect(url);
                return;
            } catch (Exception ignored) {

            }
        }

        if (request.getParameter(RequestParameters.LOGOUT_MOB) != null) {
            request.getSession().invalidate();
            PowerPubManager man = new PowerPubManager(request);
            man.set(request);
        }

        updateLocation(request);

        if (!handleNiceChallengeURL(request)) return;

        if (request.getParameter(RequestParameters.REGISTO) != null) {
            register(request, response);
        }

        if (request.getParameter(RequestParameters.NEW_PWD) != null) {
            changePassword(request, response);
        }

        if (request.getParameter(RequestParameters.REQUEST_PWD) != null && request.getParameter("emailRecuperar") != null && !request.getParameter("emailRecuperar").trim().isEmpty()) {
            requestPassword(request);
        }

        if (request.getParameter(RequestParameters.ALTERAR) != null) {
            changeParticipantData(request);
        }

        if (request.getParameter("rreg") != null) {
            finalizeRegistration(request);
        }

        if (request.getParameter(RequestParameters.LOGIN) != null) {
            if (request.getParameter(Participante.EMAIL_PROPERTY) != null && !request.getParameter(Participante.EMAIL_PROPERTY).isEmpty() && request.getParameter(RequestParameters.PWD) != null && !request.getParameter(RequestParameters.PWD).isEmpty()) {
                login(request.getParameter(Participante.EMAIL_PROPERTY), request.getParameter(RequestParameters.PWD), request);
                return;
            } else {
                errors = PowerUtils.localizeKey("msg.wrong.user.password", getCurrentLangBundle(), getDefaultLangBundle());
                setFailedLogin(true);
            }
        }

        if (request.getParameter(RequestParameters.CHANGE_LOCALE) != null && !request.getParameter(RequestParameters.CHANGE_LOCALE).isEmpty()){
            changeLocale(request);
        }

        if (request.getParameter(RequestParameters.SHARE) != null && !request.getParameter(RequestParameters.SHARE).isEmpty()){
            handleShare(request);
        }

        if (request.getParameter(RequestParameters.LOAD_P) != null && !request.getParameter(RequestParameters.LOAD_P).isEmpty()) {
            current_location = "challenge";
            challenge = DataObjectUtils.objectForPK(getDc(request), Processo.class, request.getParameter(RequestParameters.LOAD_P));
            if (participant != null) {
                participant.logAction(getProcess(), "-1", Processo.GAMIFICATION_ACTIONS.VIEW_ISSUE, request);
            }
        }
    }

    public boolean saveApiData(HttpServletRequest request) throws JSONException {
        SmartRequest req = new SmartRequest(request);
        String points = req.getParameter("points");

        Participante reqParticipant = DataObjectUtils.objectForPK(getDc(request), Participante.class, req.getParameter("user_id"));
        Processo reqChallenge = DataObjectUtils.objectForPK(getDc(request), Processo.class, req.getParameter("challenge_id"));

        if (points.length() != 0) {
            JSONObject pointsJSON = new JSONObject(points);

            String userGamificaitonStr = reqParticipant.getGamification();
            JSONObject userGamificationObj = new JSONObject(userGamificaitonStr);

            JSONObject systemGamification = userGamificationObj.getJSONObject(reqChallenge.getSistema());

            Iterator keys = pointsJSON.keys();
            while(keys.hasNext()) {
                Object next = keys.next();
                String key = (String) next;

                JSONObject dimensionObj = pointsJSON.getJSONObject(key);
                Iterator dimensionKeys = dimensionObj.keys();
                while(dimensionKeys.hasNext()) {
                    Object next2 = dimensionKeys.next();
                    String key2 = (String) next2;

                    if (dimensionObj.getDouble(key2) > 0) {
                        systemGamification.put("cat." + key + "." + key2, systemGamification.getDouble("cat." + key + "." + key2) + dimensionObj.getDouble(key2));
                    }
                }
            }

            reqParticipant.setGamification(userGamificationObj.toString(2));
            reqParticipant.getObjectContext().commitChanges();
        }

        return true;
    }


    private boolean handleNiceChallengeURL(HttpServletRequest request) {
        if (request.getParameter("issue") != null || request.getParameter("challenge")!=null) {
            final String code = PowerUtils.readString(request.getParameter("issue") != null ? "issue" : "challenge",request);
            final Processo processo = Processo.getProcessoForCodeAndLocale(code, getCurrentLocale().getLanguage(), getDefaultLangBundle().getLocale().getLanguage(), getSystemId(request), getDc(request));
            if (processo == null)
                return false;

            Seccao seccao = null;
            if (request.getParameter("section") != null) {
                final List<Seccao> sections = ExpressionFactory.matchExp(Seccao.INDICE_PROPERTY, Integer.valueOf(request.getParameter("section"))).filterObjects(processo.getSeccoes());
                seccao = sections.size() == 1 ? sections.get(0) : null;
            }

            setProcess(processo);
            setSeccao(seccao);
            current_location = "challenge";
        }
        return true;
    }



    void setErros(String errors) {
        this.errors = errors;
    }

    public String getErros() {
        return errors;
    }

    public String getMsg() {
        return msg;
    }



    public Processo getProcess(HttpServletRequest request) {
        final int challengId = PowerUtils.readInteger(RequestParameters.LOAD_P,request,Integer.MIN_VALUE);
        if (challenge == null && challengId!=Integer.MIN_VALUE) {
            renewDc(request);
            challenge = DataObjectUtils.objectForPK(getDc(request), Processo.class, challengId);
        }

        return getProcess();
    }

    public Processo getProcess() {
        return challenge;
    }

    public Processo getChallenge(ObjectContext context) {
        if(challenge==null)
            return null;
        return (Processo) context.localObject(challenge.getObjectId(),challenge);
    }

    public void setProcess(Processo challenge) {
        this.challenge = challenge;
    }

    void setSeccao(Seccao section) {
        this.section = section;
    }


    protected abstract void updateLocation(HttpServletRequest request);



    private void validateMail(String val) {
        if (val == null || val.length() == 0) {
            errors = PowerUtils.localizeKey("msg.email.mandatory", getCurrentLangBundle(), getDefaultLangBundle());
            return;
        }

        if (!PowerUtils.validMailSequence(val)) {
            errors = PowerUtils.localizeKey("msg.invalid.email", getCurrentLangBundle(), getDefaultLangBundle());
        }
    }


    private boolean validatePasswords(String pwd, String pwd2) {
        if (pwd != null && !pwd.isEmpty()) {
            if (pwd2 != null && !pwd2.isEmpty()) {
                if (!pwd.equals(pwd2)) {
                    errors = PowerUtils.localizeKey("msg.password.different", getCurrentLangBundle(), getDefaultLangBundle());
                }
            } else {
                errors = PowerUtils.localizeKey("msg.confirmation.mandatory", getCurrentLangBundle(), getDefaultLangBundle());
                return false;
            }
        } else {
            errors = PowerUtils.localizeKey("msg.password.mandatory", getCurrentLangBundle(), getDefaultLangBundle());
            return false;
        }
        return true;
    }



    public void loginByToken(String tok, HttpServletRequest request, ResourceBundle bundle) {

        String[] toks = tok.split("__");

        setErros("");

        DataContext dc = DataContext.createDataContext();
        Participante registado = DataObjectUtils.objectForPK(dc, Participante.class, toks[0].replace("?tok=",""));

        String realTok = registado.getAutologinToken();
        if (realTok.equals(tok)) {
            try {
                PublicManager man = getNewInstance(request, registado);
                man.set(request);
                man.current_location = "home";
                if (isMobileRequest()) man.setMobileRequest();
            } catch (Exception e) {
                PowerUtils.logErr(e, getClass(), null);
            }
        } else
            setErros(PowerUtils.localizeKey("msg.wrong.user.password", getCurrentLangBundle(),bundle));
    }



    protected void login(String email, String password, HttpServletRequest request) {

        PublicManager man = this;
        man.setErros("");

        SelectQuery sq = new SelectQuery(Participante.class, ExpressionFactory.matchExp(Participante.EMAIL_PROPERTY, email));

        List<Participante> registados = man.getDc(request).performQuery(sq);

        if (registados.isEmpty()) {
            man.setErros(PowerUtils.localizeKey("msg.wrong.user.password", man.getCurrentLangBundle(),getDefaultLangBundle()));
            setFailedLogin(true);
            return;
        }

        Participante registado = registados.get(0);

        if (registado.getCheckKey() != null) {
            man.setErros(PowerUtils.localizeKey("msg.conclude.registry", man.getCurrentLangBundle(),getDefaultLangBundle()));
            return;
        }


        String pwmd5 = com.baseform.apps.power.MD5Crypt.crypt(password, email);

        if (pwmd5.equals(registado.getMd5pwd())) {
            try {
                final DataContext dc = DataContext.createDataContext();
                registado = (Participante) dc.localObject(registado.getObjectId(),registado);
                request.removeAttribute(getClass().getSimpleName());
                man = getNewInstance(request, registado);
                man.set(request);
                final ObjectContext objectContext = man.getDc(request);

                man.current_location=current_location;
                if (challenge != null)
                    man.setProcess((Processo) objectContext.localObject(challenge.getObjectId(),challenge));
                if(isMobileRequest())
                    man.setMobileRequest();
                registado=(Participante) objectContext.localObject(registado.getObjectId(),registado);
                request.getSession().setAttribute("loggedinUser",DataObjectUtils.pkForObject(registado));

                String system_id = man.getSystemId(request);
                RParticipanteSistema participa_sistema = registado.getParticipaSistema(system_id);
                if( participa_sistema == null){
                    participa_sistema = objectContext.newObject(RParticipanteSistema.class);
                    participa_sistema.setFksistema(system_id);
                    participa_sistema.setParticipante(registado);
                }
                participa_sistema.setDataLogin(new Date());

                final GamificationLog log = objectContext.newObject(GamificationLog.class);
                log.setSystemId(system_id);
                log.setIssueLocale(man.getCurrentLocale().getLanguage());
                log.setIssueCode("LOGIN");
                log.setAction("action.login");
                log.setUsername(registado.getEmail());
                log.setTimestamp(new Date());

                objectContext.commitChanges();

//                if(current_location.equals("login"))
//                    current_location="home";

                if (request.getParameter(RequestParameters.COMENTARIO) != null)
                    man.createComment(request);
            } catch (Exception e) {
                PowerUtils.logErr(e, getClass(), registado);
            }
        } else {
            man.setErros(PowerUtils.localizeKey("msg.wrong.user.password", man.getCurrentLangBundle(), getDefaultLangBundle()));
            setFailedLogin(true);
        }
    }



    protected abstract void createComment(HttpServletRequest request);


    private void changePassword(HttpServletRequest request, HttpServletResponse response) {

        errors = "";
        msg = "";
        String ck = request.getParameter("ck");
        String cId = request.getParameter("c");

        try {

            if (ck != null && !ck.isEmpty() && cId != null && !cId.isEmpty()) {
                String pwd = request.getParameter(RequestParameters.PWD);
                String pwd2 = request.getParameter(RequestParameters.PWD2);

                if(validatePasswords(pwd, pwd2))
                    try {
                        if (errors.isEmpty()) {
                            Participante u = DataObjectUtils.objectForPK(getDc(request), Participante.class, cId);
                            u.setPassword(pwd);
                            u.setCheckKey(null);
                            u.getObjectContext().commitChanges();

                            msg = PowerUtils.localizeKey("msg.password.changed", getCurrentLangBundle(),getDefaultLangBundle());
                            response.sendRedirect("./?location=home");
                        }
                    } catch (Exception e) {
                        PowerUtils.logErr(e, getClass(), participant);
                        errors = PowerUtils.localizeKey("msg.registry.error", getCurrentLangBundle(),getDefaultLangBundle());
                    }

            } else {
                errors = PowerUtils.localizeKey("msg.password.recovery.error", getCurrentLangBundle(),getDefaultLangBundle());
            }

        } catch (Exception e) {
            PowerUtils.logErr(e, getClass(), participant);
        }
    }



    private void requestPassword(HttpServletRequest request) {
        final String email = request.getParameter("emailRecuperar");

        final String captchaValue = request.getParameter(RequestParameters.CAPTCHA);
        final Captcha captcha = (Captcha) request.getSession().getAttribute(Captcha.NAME);

        if (captchaValue == null || captcha == null || !captcha.isCorrect(captchaValue)) {
            errors = PowerUtils.localizeKey("msg.captcha.wrong", getCurrentLangBundle(),getDefaultLangBundle());
            PowerUtils.logErr("ResetPassword request: error in captcha for email "+email, getClass(), participant);
            return;
        }

        try {


            final Participante u = (Participante) DataObjectUtils.objectForQuery(getDc(request),new SelectQuery(Participante.class,ExpressionFactory.matchExp(Participante.EMAIL_PROPERTY, email.trim().toLowerCase())));
            if (u==null) {
                errors = PowerUtils.localizeKey("msg.unknown.user", getCurrentLangBundle(),getDefaultLangBundle());
                PowerUtils.logErr("ResetPassword request: no participant for email "+email, getClass(), participant);
                return;
            }

            u.setCheckKey(PowerUtils.doRandomCharacters(36));
            getDc(request).commitChanges();

            final String link = request.getSession().getServletContext().getInitParameter("server_href") + "/?location=resetPass&c=" + DataObjectUtils.pkForObject(u) + "&ck=" + u.getCheckKey();

            final StringBuilder txt = new StringBuilder();
            txt.append(PowerUtils.localizeKey("msg.dear.user", getCurrentLangBundle(),getDefaultLangBundle()));
            txt.append("\n");
            txt.append(PowerUtils.localizeKey("msg.click.link.for.password", getCurrentLangBundle(),getDefaultLangBundle()));
            txt.append("\n");
            txt.append(link);
            txt.append("\n");
            txt.append(PowerUtils.localizeKey("msg.regards", getCurrentLangBundle(),getDefaultLangBundle()));
            txt.append("\n");
            txt.append(request.getSession().getServletContext().getInitParameter("deployment_name"));
            txt.append(" ");
            txt.append(PowerUtils.localizeKey("digital.social.platform",getCurrentLangBundle(),getDefaultLangBundle()));

            try {
                final String subject = PowerUtils.localizeKey("msg.password.recovery.header", getCurrentLangBundle(),getDefaultLangBundle());
                PowerUtils.sendEmail(request, subject, txt.toString(), email);
                msg = PowerUtils.localizeKey("msg.consult.email", getCurrentLangBundle(),getDefaultLangBundle());
                PowerUtils.logInfo("ResetPassword request: sent reset email to "+email, getClass(), participant);
            } catch (Exception er) {
                PowerUtils.logErr("ResetPassword request: exception1 "+er.getClass().getSimpleName()+" for email "+email, getClass(), participant);
                PowerUtils.logErr(er, getClass(), participant);
                errors = PowerUtils.localizeKey("msg.error", getCurrentLangBundle(),getDefaultLangBundle());
            }

        } catch (Exception e) {
            PowerUtils.logErr("ResetPassword request: exception2 "+e.getClass().getSimpleName()+" for email "+email, getClass(), participant);
            PowerUtils.logErr(e, getClass(), participant);
        }
    }

    private void changeParticipantData(HttpServletRequest request) {
        SmartRequest req = new SmartRequest(request);
        errors = "";
        msg = "";

        String nome = req.getParameter(Participante.NOME_PROPERTY);
        String pwd = PowerUtils.readString(RequestParameters.PWD,req);
        String pwd2 = PowerUtils.readString(RequestParameters.PWD2,req);

        HashMap<String, FileItem> files = req.getFiles();
        ParticipanteImagem avatar = participant.getImagem();
        File tempFile = null;

        try
        {
            if(pwd!=null && !validatePasswords(pwd,pwd2))
                return;

            List<RParticipanteNotTipologia> toDelete = new ArrayList<>();

            if(pwd!=null)
                participant.setPassword(pwd);

            if(nome != null && !nome.isEmpty() && !nome.equals(getParticipante().getNome()))
                getParticipante().setNome(nome);

            for (String s : files.keySet()) {

                FileItem item = files.get(s);
                String fileName = item.getName();

                tempFile = File.createTempFile(FilenameUtils.getBaseName(fileName) + System.currentTimeMillis(), FilenameUtils.getExtension(fileName).isEmpty() ? "" : "." + FilenameUtils.getExtension(fileName));
                InputStream is = new FileInputStream(tempFile);
                FileOutputStream fos = new FileOutputStream(tempFile);
                org.apache.commons.io.IOUtils.copy(is, fos);
                fos.close();

                File dir = new File(DIR_DOCS);
                if (!dir.exists()) {
                    dir.mkdir();
                }

                File dirThumbs = new File(DIR_DOCS + File.separator + "/user_avatars/");

                if (!dirThumbs.exists()) {
                    dirThumbs.mkdir();
                }

                if (avatar == null)
                    avatar = new ParticipanteImagem();

                avatar.setNomeFicheiro(fileName);
                avatar.setParticipante(participant);
                avatar.setMime(req.getContentType());

                getDc(request).commitChanges();

                File file = new File(dirThumbs + File.separator + participant.getId());

                item.write(file);
            }

            getParticipante().getObjectContext().commitChanges();
            msg = PowerUtils.localizeKey("msg.data.changed", getCurrentLangBundle(),getDefaultLangBundle());
        }
        catch(Exception e)
        {
            PowerUtils.logErr(e, getClass(), participant);
            getParticipante().getObjectContext().rollbackChanges();
            errors = PowerUtils.localizeKey("msg.registration.error", getCurrentLangBundle(),getDefaultLangBundle());
        }
    }

    private void finalizeRegistration(HttpServletRequest request) {
        errors = "";
        msg = "";
        String ck = request.getParameter("ck");
        String cId = request.getParameter("c");

        try {

            if (ck != null && !ck.isEmpty() && cId != null && !cId.isEmpty()) {

                try {
                    if (errors.isEmpty()) {
                        Participante u = DataObjectUtils.objectForPK(DataContext.createDataContext(), Participante.class, cId);
                        u.setCheckKey(null);
                        u.setActivo(true);
                        u.setDataRegisto(new Date());
                        u.getObjectContext().commitChanges();

                        PublicManager man = getNewInstance(request, u);
                        man.set(request);

                        String system_id = man.getSystemId(request);

                        RParticipanteSistema participa_sistema = u.getParticipaSistema(system_id);
                        if( participa_sistema == null){
                            participa_sistema = new RParticipanteSistema();
                            participa_sistema.setFksistema(system_id);
                            participa_sistema.setParticipante(u);
                        }
                        participa_sistema.setDataLogin(new Date());
                        man.getDc(request).commitChanges();

                    }
                } catch (Exception e) {
                    PowerUtils.logErr(e, getClass(), participant);
                    errors = PowerUtils.localizeKey("msg.activation.error", getCurrentLangBundle(),getDefaultLangBundle());
                }

            } else {
                errors = PowerUtils.localizeKey("msg.activation.error", getCurrentLangBundle(),getDefaultLangBundle());
            }

        } catch (Exception e) {
            PowerUtils.logErr(e, getClass(), participant);
        }
    }



    private void register(HttpServletRequest request, HttpServletResponse response) {
        errors = "";
        msg = "";

        String nom = "", ema = "";
        boolean mobile = false;


        if (request.getParameter("mobile") != null) {
            mobile = true;
        }

        if (request.getParameter(Participante.NOME_PROPERTY) == null || request.getParameter(Participante.NOME_PROPERTY).isEmpty() || request.getParameter(Participante.NOME_PROPERTY).equals(PowerUtils.localizeKey("name", getCurrentLangBundle(),getDefaultLangBundle())))
            errors = PowerUtils.localizeKey("msg.mandatory.fields", getCurrentLangBundle(),getDefaultLangBundle());
        else
            nom = request.getParameter(Participante.NOME_PROPERTY);

        if (request.getParameter(Participante.EMAIL_PROPERTY) == null || request.getParameter(Participante.EMAIL_PROPERTY).isEmpty() || request.getParameter(Participante.EMAIL_PROPERTY).equals(PowerUtils.localizeKey("email", getCurrentLangBundle(),getDefaultLangBundle())))
            errors = PowerUtils.localizeKey("msg.mandatory.fields", getCurrentLangBundle(),getDefaultLangBundle());
        else
            ema = request.getParameter(Participante.EMAIL_PROPERTY);

        if (request.getParameter(RequestParameters.LEGAL) == null || request.getParameter(RequestParameters.LEGAL).isEmpty() || request.getParameter(RequestParameters.LEGAL).equals(false))
            errors = PowerUtils.localizeKey("msg.mandatory.legal", getCurrentLangBundle(),getDefaultLangBundle());

        if (!errors.isEmpty())
            return;

        String nome = nom;
        String email = ema;
        String pwd = request.getParameter(RequestParameters.PWD);
        String pwd2 = request.getParameter(RequestParameters.PWD2);

        validateMail(email);

        validatePasswords(pwd, pwd2);


        if (email != null && !email.isEmpty()) {
            SelectQuery q = new SelectQuery(Participante.class);
            q.setQualifier(ExpressionFactory.likeExp(Participante.EMAIL_PROPERTY, email.toLowerCase()));
            if (!getDc(request).performQuery(q).isEmpty()) {
                errors = PowerUtils.localizeKey("msg.already.registered", getCurrentLangBundle(),getDefaultLangBundle());
            }
        }

        try {
            if (errors.isEmpty()) {
                Participante participante = getDc(request).newObject(Participante.class);
                participante.writeProperty(Participante.NOME_PROPERTY, nome);
                participante.writeProperty(Participante.EMAIL_PROPERTY, email.toLowerCase());
                participante.writeProperty(Participante.MD5PWD_PROPERTY, com.baseform.apps.power.MD5Crypt.crypt(pwd, email.toLowerCase()));
                participante.writeProperty(Participante.ACTIVO_PROPERTY, false);
                participante.writeProperty(Participante.CHECK_KEY_PROPERTY, PowerUtils.doRandomCharacters(36));

                if (request.getParameter(Participante.AGE_BRACKET_PROPERTY) != null && !request.getParameter(Participante.AGE_BRACKET_PROPERTY).equals("--"))
                    participante.writeProperty(Participante.AGE_BRACKET_PROPERTY, request.getParameter(Participante.AGE_BRACKET_PROPERTY));
                if (request.getParameter(Participante.EDUCATION_LEVEL_PROPERTY) != null && !request.getParameter(Participante.EDUCATION_LEVEL_PROPERTY).equals("--"))
                    participante.writeProperty(Participante.EDUCATION_LEVEL_PROPERTY, request.getParameter(Participante.EDUCATION_LEVEL_PROPERTY));
                if (request.getParameter(Participante.NUMBER_CHILDREN_PROPERTY) != null && !request.getParameter(Participante.NUMBER_CHILDREN_PROPERTY).equals("--"))
                    participante.writeProperty(Participante.NUMBER_CHILDREN_PROPERTY, request.getParameter(Participante.NUMBER_CHILDREN_PROPERTY));
                if (request.getParameter(Participante.PROFESSION_PROPERTY) != null && !request.getParameter(Participante.PROFESSION_PROPERTY).equals("--"))
                    participante.writeProperty(Participante.PROFESSION_PROPERTY, request.getParameter(Participante.PROFESSION_PROPERTY));
                if (request.getParameter(Participante.GENDER_PROPERTY) != null && !request.getParameter(Participante.GENDER_PROPERTY).equals("--"))
                    participante.writeProperty(Participante.GENDER_PROPERTY, request.getParameter(Participante.GENDER_PROPERTY));

                boolean sendEmail = PowerUtils.sendConfirmationEmail(request.getSession().getServletContext().getInitParameter("current_system"), getDc(request));
                if (mobile || !sendEmail) {
                    participante.writeProperty(Participante.CHECK_KEY_PROPERTY, null);
                }

                if (!sendEmail) participante.setActivo(true);

                getDc(request).commitChanges();
                if (sendEmail) {
                    try {
                        String host = request.getSession().getServletContext().getInitParameter("smtp_server");
                        String smtp_server_port = request.getSession().getServletContext().getInitParameter("smtp_port");

                        final String tempSMTP_SSL = request.getSession().getServletContext().getInitParameter("smtp_use_ssl");
                        boolean smtp_ssl = false;
                        if (tempSMTP_SSL != null)
                            smtp_ssl = Boolean.parseBoolean(tempSMTP_SSL);

                        String username = request.getSession().getServletContext().getInitParameter("smtp_username");
                        String password = request.getSession().getServletContext().getInitParameter("smtp_password");

                        String from = request.getSession().getServletContext().getInitParameter("from");

                        String link = request.getSession().getServletContext().getInitParameter("server_href") + "/?location=activate&rreg&c=" + DataObjectUtils.pkForObject(participante) + "&ck=" + participante.getCheckKey();
                        String[] deployment = {request.getSession().getServletContext().getInitParameter("deployment_name")};

                        String subject = PowerUtils.localizeKey("power.registry", getCurrentLangBundle(), getDefaultLangBundle());
                        String msgEmail = PowerUtils.localizeKey("msg.welcome.power", getCurrentLangBundle(), getDefaultLangBundle(), deployment) + "\n" +
                                "\n" + PowerUtils.localizeKey("msg.activate.account", getCurrentLangBundle(), getDefaultLangBundle()) + " <a href=\"" + link + "\">" + link + "</a>. " + "\n";

                        if (mobile) {
                            msgEmail = PowerUtils.localizeKey("msg.welcome.power", getCurrentLangBundle(), getDefaultLangBundle(), deployment) + "\n";
                        }

                        PowerUtils.sendEmail(host, smtp_ssl, smtp_server_port, username, password, from, subject, msgEmail, participante.readProperty(Participante.EMAIL_PROPERTY).toString());
                    } catch (Exception e) {
                        PowerUtils.logErr(e, getClass(), participante);
                        errors = PowerUtils.localizeKey("msg.registry.error", getCurrentLangBundle(), getDefaultLangBundle());
                        getDc(request).deleteObject(participante);
                    }
                }


                msg = PowerUtils.localizeKey("msg.registry.success", getCurrentLangBundle(),getDefaultLangBundle());
                getDc(request).commitChanges();
            }
        } catch (Exception e) {

            PowerUtils.logErr(e, getClass(), participant);
            errors = PowerUtils.localizeKey("msg.registry.error", getCurrentLangBundle(),getDefaultLangBundle());
            getDc(request).rollbackChanges();
        }
    }



    private void handleShare(HttpServletRequest request) {
        final Participante participant = getParticipante();
        if (participant != null && request.getParameter("p") != null) {
            if (request.getParameter(RequestParameters.SHARE).equals("facebook"))
                participant.logAction(DataObjectUtils.objectForPK(getDc(request), Processo.class, request.getParameter("p")), "-1", Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_FACEBOOK,request);
            if (request.getParameter(RequestParameters.SHARE).equals("twitter"))
                participant.logAction(DataObjectUtils.objectForPK(getDc(request), Processo.class, request.getParameter("p")), "-1", Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_TWITTER,request);
            if (request.getParameter(RequestParameters.SHARE).equals("google"))
                participant.logAction(DataObjectUtils.objectForPK(getDc(request), Processo.class, request.getParameter("p")), "-1", Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_GOOGLE,request);
            if (request.getParameter(RequestParameters.SHARE).equals("email"))
                participant.logAction(DataObjectUtils.objectForPK(getDc(request), Processo.class, request.getParameter("p")), "-1", Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_EMAIL,request);
        }
    }



    public List<Processo> getIssueList(HttpServletRequest request) {
        return getIssuesList(request,null);
    }

    private List<Processo> getIssuesList(HttpServletRequest request, City city) {
        final ObjectContext oc = getDc(request);
        return Processo.getChallenges(city, getCurrentLocale().getLanguage(), getDefaultLangBundle().getLocale().getLanguage(), getSystemId(request), oc);
    }

    public List<Processo> getCityChallengesList(HttpServletRequest request, City city) {
        return getIssuesList(request,city);
    }



    public List<SiteTab> getSiteTabsByLocale(HttpServletRequest request) {
        SelectQuery q = new SelectQuery(SiteTab.class);
        Expression exp = ExpressionFactory.matchExp(SiteTab.LOCALE_PROPERTY, getCurrentLocale().getLanguage())
                .andExp(ExpressionFactory.matchExp(SiteTab.ONLINE_PROPERTY, true))
                .andExp(ExpressionFactory.matchExp(SiteTab.SISTEMA_PROPERTY, getSystemId(request)));
        q.andQualifier(exp);
        List<SiteTab> tabs = getDc(request).performQuery(q);

        if(tabs.isEmpty()){
            SelectQuery _q = new SelectQuery(SiteTab.class);
            Expression _exp = ExpressionFactory.matchExp(SiteTab.LOCALE_PROPERTY, PowerUtils.getDefaultLocale().getLanguage())
                    .andExp(ExpressionFactory.matchExp(SiteTab.ONLINE_PROPERTY, true))
                    .andExp(ExpressionFactory.matchExp(SiteTab.SISTEMA_PROPERTY, getSystemId(request)));
            _q.andQualifier(_exp);
            tabs = getDc(request).performQuery(_q);
        }

        new Ordering(SiteTab.ID_PK_COLUMN, SortOrder.ASCENDING).orderList(tabs);
        return tabs;
    }


    public int getSharesStat(HttpServletRequest request, ObjectContext dc, JSONArray issuesSharedStat) throws JSONException {
        // Partilhas -> count gamification log entries
        final List<Pair<Processo.GAMIFICATION_ACTIONS, String>> shareActions = Arrays.asList(
                new ImmutablePair<>(Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_FACEBOOK, RequestParameters.FACEBOOK),
                new ImmutablePair<>(Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_TWITTER, RequestParameters.TWITTER),
                new ImmutablePair<>(Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_GOOGLE, RequestParameters.GOOGLE),
                new ImmutablePair<>(Processo.GAMIFICATION_ACTIONS.SHARE_ISSUE_EMAIL, RequestParameters.EMAIL)
        );
        int countShares = 0;
        for (Pair<Processo.GAMIFICATION_ACTIONS, String> shareAction : shareActions) {
            final SQLTemplate query = new SQLTemplate(GamificationLog.class, "select count(*) as count from processos.gamification_log where action = '" + shareAction.getLeft().getKey() + "' and system_id='"+getSystemId(request)+"'");
            query.setFetchingDataRows(true);
            final List<DataRow> rows = dc.performQuery(query);
            final int count = rows != null && !rows.isEmpty() ? ((Long) rows.get(0).get("count")).intValue() : 0;
            countShares += count;
            final JSONObject oProcesso20 = new JSONObject();
            oProcesso20.put("label", shareAction.getRight());
            oProcesso20.put("data", count);
            issuesSharedStat.put(oProcesso20);
        }
        return countShares;
    }


    public void setMobileRequest() {
        mobileRequest = true;
    }

    public Boolean isMobileRequest() {
        return mobileRequest;
    }
}
