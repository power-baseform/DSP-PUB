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
import com.baseform.apps.power.basedados.*;
import com.baseform.apps.power.json.*;
import com.baseform.apps.power.json.JSONException;
import com.baseform.apps.power.json.JSONObject;
import com.baseform.apps.power.participante.*;
import com.baseform.apps.power.processo.*;
import com.baseform.apps.power.utils.RequestParameters;
import com.baseform.apps.power.utils.SmartRequest;
import com.baseform.apps.power.utils.inputs.Input;
import com.caucho.db.sql.Expr;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.util.IOUtils;
import org.apache.cayenne.DataObjectUtils;
import org.apache.cayenne.ObjectContext;
import org.apache.cayenne.PersistenceState;
import org.apache.cayenne.access.DataContext;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.Ordering;
import org.apache.cayenne.query.SelectQuery;
import org.apache.cayenne.query.SortOrder;
import org.apache.commons.codec.binary.*;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import twitter4j.*;
import twitter4j.conf.ConfigurationBuilder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.*;
import java.util.Base64;

public class PowerPubManager extends PublicManager {
    public static Integer pagination = 5;
    public static final String BEST_PRACTICES_ID = "280";

    public PowerPubManager(Participante participant, HttpServletRequest request) {
        super(participant,request);
        current_location = "home";
    }

    public PowerPubManager(HttpServletRequest request) {
        super(request);
        current_location = "home";
    }

    @Override
    protected PowerPubManager getNewInstance(HttpServletRequest request, Participante u) {
        return new PowerPubManager(u, request);
    }

    public String isRtl() {
        if (getCurrentLocale().equals(Locale.forLanguageTag("iw")) || getCurrentLocale().equals(Locale.forLanguageTag("ar"))) return "rtl";
        return "";
    }

    @Override
    protected void updateLocation(HttpServletRequest request){
        if(request.getParameter("location") != null) {
            final boolean changeLocation = request.getParameter("location") != null && (current_location==null || !request.getParameter("location").equals(current_location));
            current_location = request.getParameter("location");
            if (current_location.equals("consulta")) current_location = "challenge";

            if(current_location.equals("area") && participant==null)
                current_location = "home";

            if(request.getParameter("location").equals("area") && participant==null && isMobileRequest())
                current_location = "login";

            if(current_location.equals("login") && participant!=null)
                current_location = "home";

//            if(!current_location.equals("challenge"))
//                processo=null;
            if(changeLocation && current_location.equals("home") && participant!=null)
                renewDc(request);
        }
    }



    @Override
    public ResourceBundle getCurrentLangBundle(){
        if(manBundle ==null)
            manBundle = FrontendUtils.getFrontendBundle(getCurrentLocale());
        return manBundle;
    }

    @Override
    public ResourceBundle getDefaultLangBundle(){
        return FrontendUtils.getFrontendDefaultBundle();
    }



    @Override
    public void process(HttpServletRequest request, HttpServletResponse response) {
        super.process(request,response);

        if (request.getParameter(RequestParameters.ACTION) != null && !request.getParameter(RequestParameters.ACTION).isEmpty()) {
            try {
                if (this.participant != null && this.participant.getPersistenceState() == PersistenceState.COMMITTED) {
                    if (request.getParameter(RequestParameters.ACTION).equals(RequestParameters.PARTICIPAR)) {
                        response.sendRedirect("./?location=challenge&be_heard&loadP=" + request.getParameter(RequestParameters.IPROCESSO));
                    } else if (request.getParameter(RequestParameters.ACTION).equals(RequestParameters.SEGUIR)) {
                        seguir(request);
                    } else if (request.getParameter(RequestParameters.ACTION).equals(RequestParameters.REMOVER_SEGUIR)) {
                        try {
                            Processo p = DataObjectUtils.objectForPK(getDc(request), Processo.class, request.getParameter(RequestParameters.IPROCESSO));
                            RParticipanteProcesso rsp = this.participant.segueProcesso(p);
                            boolean foundP = false;
                            if (rsp != null) {
                                rsp.setIsFollowing(false);
                                foundP = true;
                            } else if (p != null) {
                                List<Processo> bySameCode = p.getBySameCode();
                                for (Processo processo : bySameCode) {
                                    RParticipanteProcesso rParticipanteProcesso = this.participant.segueProcesso(processo);
                                    if (rParticipanteProcesso != null) {
                                        rParticipanteProcesso.setIsFollowing(false);
                                        foundP = true;
                                        rsp = rParticipanteProcesso;
                                    }
                                }
                            }
                            if (foundP) {
                                msg = PowerUtils.localizeKey("not.following.challenge", getCurrentLangBundle(), getDefaultLangBundle());
                                rsp.getObjectContext().commitChanges();
                            }
                        } catch (Exception e) {
                            getDc(request).rollbackChanges();
                            PowerUtils.logErr(e, getClass(), participant);
                            setErros(e.toString());
                        }
                    }
                }
            } catch (Exception e) {
                PowerUtils.logErr(e, getClass(), participant);
            }
        }

//        if (request.getParameter(RequestParameters.REMOVER_SEGUIR) != null && !request.getParameter(RequestParameters.REMOVER_SEGUIR).isEmpty()) {
//            try {
//                RParticipanteProcesso rsp = DataObjectUtils.objectForPK(getDc(request), RParticipanteProcesso.class, request.getParameter(RequestParameters.REMOVER_SEGUIR));
//                rsp.setIsFollowing(false);
//                msg = PowerUtils.localizeKey("not.following.challenge", getCurrentLangBundle(), getDefaultLangBundle());
//                rsp.getObjectContext().commitChanges();
//            } catch (Exception e) {
//                getDc(request).rollbackChanges();
//                PowerUtils.logErr(e, getClass(), participant);
//                setErros(e.toString());
//            }
//        }

        if (request.getParameter(RequestParameters.REMOVER_PARTICIPAR) != null && !request.getParameter(RequestParameters.REMOVER_PARTICIPAR).isEmpty()) {
            try {
                RParticipanteProcesso rpp = DataObjectUtils.objectForPK(getDc(request), RParticipanteProcesso.class, request.getParameter(RequestParameters.REMOVER_PARTICIPAR));
                getDc(request).deleteObject(rpp);
                getDc(request).commitChanges();
            } catch (Exception e) {
                getDc(request).rollbackChanges();
                PowerUtils.logErr(e, getClass(), participant);
                setErros(e.toString());
            }
        }

        handleEvents(request);

        if (request.getParameter(RequestParameters.COMENTAR) != null) {
            createComment(request);
        }

        if (request.getParameter(RequestParameters.SAVE_ANSWERS) != null) {
            try {
                saveAnswers(request);
            } catch (Exception e) {
                PowerUtils.logErr(e, getClass(), participant);
            }
        }

        if (request.getParameter(RequestParameters.REABRIR_INQUERITO) != null && request.getParameter("hIdR") != null && !request.getParameter("hIdR").isEmpty()) {
            reopenSurvey(request);
        }

        if (request.getParameter(CommunityProcesso.CREATE_PARAM) != null) {
            try {
                createCommunityChallenge(request);
            } catch (Exception e) {
                errors = e.getMessage();
            }
        }
    }

    private void createCommunityChallenge(HttpServletRequest request) throws Exception {
        final ObjectContext dc = getDc(request);
        final Participante participant = getParticipant(dc);
        if (participant == null) return;

        SmartRequest req = new SmartRequest(request);

        CommunityProcesso communityProcesso = dc.newObject(CommunityProcesso.class);

        communityProcesso.setParticipante(participant);

        Scope scope = DataObjectUtils.objectForPK(dc, Scope.class, req.getParameter(CommunityProcesso.SCOPE_PROPERTY));
        communityProcesso.setScope(scope);
        communityProcesso.setTitle(req.getParameter(CommunityProcesso.TITLE_PROPERTY));
        communityProcesso.setBody(req.getParameter(CommunityProcesso.BODY_PROPERTY));

        SelectQuery selectQuery = new SelectQuery(City.class, ExpressionFactory.matchExp(City.NAME_PROPERTY, req.getParameter(CommunityProcesso.CITY_PROPERTY)));
        List<City> list = dc.performQuery(selectQuery);
        if (list.size() != 1) throw new Exception();

        communityProcesso.setCity(list.get(0));

        dc.commitChanges();

        int size = scope.getScopeTags().size();
        for (int i = 0; i<size; i++) {
            String parameter = req.getParameter(CommunityProcesso.COMMUNITY_PROCESSO_TAGS_PROPERTY + i);
            if (parameter != null) {
                CommunityProcessoTags communityProcessoTags = dc.newObject(CommunityProcessoTags.class);
                communityProcessoTags.setTag(DataObjectUtils.objectForPK(dc, Tag.class, parameter));
                communityProcessoTags.setCommunityProcesso(communityProcesso);
                dc.commitChanges();
            }
        }

        int i = DataObjectUtils.intPKForObject(communityProcesso);

        HashMap<String, FileItem> files = req.getFiles();

        for (String s : files.keySet()) {
            FileItem item = files.get(s);
            String fileName = item.getName();
            File tempFile = File.createTempFile(FilenameUtils.getBaseName(fileName) + System.currentTimeMillis(), FilenameUtils.getExtension(fileName).isEmpty() ? "" : "." + FilenameUtils.getExtension(fileName));
            InputStream is = new FileInputStream(tempFile);
            FileOutputStream fos = new FileOutputStream(tempFile);
            IOUtils.copy(is, fos);
            fos.close();
            is.close();

            String DIR_DOCS = request.getSession().getServletContext().getInitParameter("docs").startsWith("/")
                    ? request.getSession().getServletContext().getInitParameter("docs")
                    : request.getServletContext().getRealPath("/")+request.getSession().getServletContext().getInitParameter("docs");
            File dir = new File(DIR_DOCS);
            if (!dir.exists()) {
                dir.mkdir();
            }
            File dirProcesso = new File(dir + File.separator + i);
            if (!dirProcesso.exists()) {
                dirProcesso.mkdir();
            }


            File file = null;
            if (s.contains(CommunityProcesso.DOCUMENTS_PROPERTY)) {
                File subDir = new File(dirProcesso + File.separator + "community_processos_documents");
                if (!subDir.exists()) {
                    subDir.mkdir();
                }

                CommunityDocument communityDocument = dc.newObject(CommunityDocument.class);
                communityDocument.setCommunityProcesso(communityProcesso);
                communityDocument.setMime(item.getContentType());
                communityDocument.setData(new Date());
                communityDocument.setDataDocumento(new Date());
                communityDocument.setDesignacao(fileName);
                communityDocument.setNomeFicheiro(fileName);
                dc.commitChanges();

                file = new File(subDir + File.separator + DataObjectUtils.intPKForObject(communityDocument));
            } else if (s.contains(CommunityProcesso.COMMUNITY_PROCESSO_IMAGES_PROPERTY)) {
                File subDir = new File(dirProcesso + File.separator + "community_processos_thumbnail");
                if (!subDir.exists()) {
                    subDir.mkdir();
                }

                TemporaryThumbnail temporaryThumbnail = dc.newObject(TemporaryThumbnail.class);
                temporaryThumbnail.setMime(item.getContentType());
                temporaryThumbnail.setName(fileName);
                dc.commitChanges();
                file = new File(subDir + File.separator + DataObjectUtils.intPKForObject(temporaryThumbnail));


                CommunityProcessoImages image = dc.newObject(CommunityProcessoImages.class);
                image.setCommunityProcesso(communityProcesso);
                image.setTemporaryThumbnail(temporaryThumbnail);
                dc.commitChanges();
            } else if (s.contains(CommunityProcesso.THUMBNAIL_PROPERTY)) {
                File subDir = new File(dirProcesso + File.separator + "community_processos_thumbnail");
                if (!subDir.exists()) {
                    subDir.mkdir();
                }

                TemporaryThumbnail temporaryThumbnail = dc.newObject(TemporaryThumbnail.class);
                temporaryThumbnail.setMime(item.getContentType());
                temporaryThumbnail.setName(fileName);
                dc.commitChanges();

                communityProcesso.setThumbnail(temporaryThumbnail);
                dc.commitChanges();
                file = new File(subDir + File.separator + DataObjectUtils.intPKForObject(temporaryThumbnail));
            }

            item.write(file);
        }

        msg = PowerUtils.localizeKey("msg.community.challenge.submitted", getCurrentLangBundle(),getDefaultLangBundle(), new String[]{participant.getNome()});
    }

    private void handleEvents(HttpServletRequest request) {
        final ObjectContext dc = getDc(request);
        final Participante participant = getParticipant(dc);
        if (request.getParameter(RequestParameters.NIR_EVENTO) != null && !request.getParameter(RequestParameters.NIR_EVENTO).isEmpty()) {
            try {
                Evento evento = DataObjectUtils.objectForPK(dc, Evento.class, request.getParameter(RequestParameters.NIR_EVENTO));
                if (participant.participaEvento(evento) != null) {
                    dc.deleteObject(participant.participaEvento(evento));
                    dc.commitChanges();
                    msg = PowerUtils.localizeKey("msg.unfollow.event", getCurrentLangBundle(), getDefaultLangBundle());
                }
            } catch (Exception e) {
                dc.rollbackChanges();
                PowerUtils.logErr(e, getClass(), participant);
                setErros(e.toString());
            }
        }

        if (request.getParameter(RequestParameters.IR_EVENTO) != null && !request.getParameter(RequestParameters.IR_EVENTO).isEmpty()) {
            try {
                boolean exists = false;
                Evento evento = DataObjectUtils.objectForPK(dc, Evento.class, request.getParameter(RequestParameters.IR_EVENTO));

                List<RParticipanteEvento> participanteEvento = participant.getParticipanteEvento();
                for (RParticipanteEvento rParticipanteEvento : participanteEvento) {
                    if (rParticipanteEvento.getEvento().getId() == evento.getId())
                        exists = true;
                    msg = PowerUtils.localizeKey("msg.refollow.event", getCurrentLangBundle(), getDefaultLangBundle());
                }

                if (!exists) {
                    RParticipanteEvento rpe = dc.newObject(RParticipanteEvento.class);
                    rpe.setEvento(evento);
                    rpe.setParticipante(participant);
                    dc.commitChanges();
                    participant.logAction(getProcess(), evento.getId() + "", Processo.GAMIFICATION_ACTIONS.ATTEND_MEETING, request);
                    msg = PowerUtils.localizeKey("msg.follow.event", getCurrentLangBundle(), getDefaultLangBundle());
                }

            } catch (Exception e) {
                dc.rollbackChanges();
                PowerUtils.logErr(e, getClass(), participant);
                setErros(e.toString());
            }
        }
    }

    @Override
    public void createComment(HttpServletRequest request) {
        ObjectContext dc = getDc(request);
        try {
            SmartRequest req;

            if (request instanceof SmartRequest) {
                req = (SmartRequest) request;
            } else {
                req = new SmartRequest(request);
            }

            if (getParticipant(dc) == null && req.getParameter("loginEmail") != null && req.getParameter("loginPassword") != null) {
                login(req.getParameter("loginEmail"), req.getParameter("loginPassword"), req);
                return;
            }


            Boolean isReply = Boolean.valueOf(req.getParameter("isReply"));

            String DIR_DOCS = request.getSession().getServletContext().getInitParameter("docs").startsWith("/")
                    ? request.getSession().getServletContext().getInitParameter("docs")
                    : request.getServletContext().getRealPath("/")+request.getSession().getServletContext().getInitParameter("docs");

            HashMap<String, FileItem> files = req.getFiles();

            if (!getChallenge(dc).getEmConsulta()) {
                errors = PowerUtils.localizeKey("msg.comment.closed", getCurrentLangBundle(),getDefaultLangBundle());
                return;
            }

            String comentario = req.getParameter(RequestParameters.COMENTARIO);

            if (comentario.length() > 1500) {
                errors = PowerUtils.localizeKey("msg.comment.too.large", getCurrentLangBundle(),getDefaultLangBundle());
                return;
            }

            getParticipant(dc).logAction(getProcess(), "-1", Processo.GAMIFICATION_ACTIONS.COMMENT, request);

            RParticipanteComentario rpc = dc.newObject(RParticipanteComentario.class);

            if (isReply) {
                RParticipanteComentario responseTo = DataObjectUtils.objectForPK(dc,RParticipanteComentario.class, req.getParameter("responseTo"));
                if (responseTo == null) return;
                rpc.setResponseTo(responseTo);
                rpc.setTipo(responseTo.getTipo());
                rpc.setProcesso(responseTo.getProcesso());
            } else {
                rpc.setProcesso(getChallenge(dc));
                rpc.setTipo(req.getParameter(RParticipanteComentario.TIPO_PROPERTY) != null && !req.getParameter(RParticipanteComentario.TIPO_PROPERTY).trim().isEmpty() ? req.getParameter(RParticipanteComentario.TIPO_PROPERTY) : "N/A");
            }

            rpc.setParticipante(getParticipant(dc));
            rpc.setTitle(req.getParameter("title").trim());
            rpc.setComentario(comentario);
            rpc.setStatus(RParticipanteComentario.PENDING_APPROVAL);
            rpc.setLikes(0);
            rpc.setDislikes(0);
            rpc.setData(new Date());

            for (String s : files.keySet()) {

                FileItem item = files.get(s);
                String fileName = item.getName();

                File tempFile = File.createTempFile(FilenameUtils.getBaseName(fileName) + System.currentTimeMillis(), FilenameUtils.getExtension(fileName).isEmpty() ? "" : "." + FilenameUtils.getExtension(fileName));
                InputStream is = new FileInputStream(tempFile);
                FileOutputStream fos = new FileOutputStream(tempFile);
                IOUtils.copy(is, fos);
                fos.close();
                is.close();

                File dir = new File(DIR_DOCS);
                if (!dir.exists()) {
                    dir.mkdir();
                }

                File dirProcesso = new File(dir + File.separator + DataObjectUtils.pkForObject(getChallenge(dc)));
                if (!dirProcesso.exists()) {
                    dirProcesso.mkdir();
                }

                File dirComentarios = new File(dirProcesso + File.separator + "comment");
                if (!dirComentarios.exists()) {
                    dirComentarios.mkdir();
                }

                ComentarioFicheiro comentarioFicheiro = new ComentarioFicheiro();
                comentarioFicheiro.setNomeFicheiro(fileName);
                comentarioFicheiro.setComentario(rpc);
                comentarioFicheiro.setMime(item.getContentType());
                comentarioFicheiro.setSize(new Long(item.getSize()).intValue());
                comentarioFicheiro.getObjectContext().commitChanges();

                File file = new File(dirComentarios + File.separator + comentarioFicheiro.getId());

                item.write(file);

            }

            participar(request);
            dc.commitChanges();


            msg = PowerUtils.localizeKey("msg.comment.submitted", getCurrentLangBundle(),getDefaultLangBundle());
        } catch (Exception e) {
            PowerUtils.logErr(e, getClass(), participant);
            dc.rollbackChanges();
        }

    }



    public void processClickOnLink(HttpServletRequest request) {
        final Participante participant = getParticipante();
        if (request.getParameter(RequestParameters.CLICK_LINK) != null && participant != null &&
                getProcess() != null) {
            participant.logAction(getProcess(), request.getParameter(RequestParameters.CLICK_LINK), Processo.GAMIFICATION_ACTIONS.CLICK_LINK,request);
        }
    }



    private void seguir(HttpServletRequest request) {
        if (challenge == null || String.valueOf(challenge.getId()).equals(request.getParameter(RequestParameters.IPROCESSO))) {
            challenge = DataObjectUtils.objectForPK(participant.getObjectContext(), Processo.class, request.getParameter(RequestParameters.IPROCESSO));
            participar(true,request);
        }
    }



    private void participar(HttpServletRequest request) {
        participar(false, request);
    }



    private void participar(boolean message, HttpServletRequest request) {
        follow(message,request);
    }



    private void follow(boolean message, HttpServletRequest request) {
        List<RParticipanteProcesso> processosAcompanhados = participant.getProcessosAcompanhados();

        int procId = challenge.getId();
        for (RParticipanteProcesso processosAcompanhado : processosAcompanhados)
            if (processosAcompanhado.getProcesso().getId() == procId) {
                processosAcompanhado.setData(new Date());
                processosAcompanhado.setIsFollowing(true);
                if (message) {
                    msg = PowerUtils.localizeKey("following.challenge", getCurrentLangBundle(),getDefaultLangBundle());
                    participant.logAction(getProcess(), "-1", Processo.GAMIFICATION_ACTIONS.FOLLOW_ISSUE,request);
                }
                participant.getObjectContext().commitChanges();
                return;
            }
        RParticipanteProcesso rpp = participant.getObjectContext().newObject(RParticipanteProcesso.class);
        rpp.setProcesso(DataObjectUtils.objectForPK(participant.getObjectContext(), Processo.class, procId));
        rpp.setParticipante(participant);
        rpp.setIsFollowing(true);
        rpp.setData(new Date());
        if (message)
            msg = PowerUtils.localizeKey("following.challenge", getCurrentLangBundle(),getDefaultLangBundle());
        participant.logAction(getProcess(), "-1", Processo.GAMIFICATION_ACTIONS.FOLLOW_ISSUE,request);
        participant.getObjectContext().commitChanges();
    }



    private void saveAnswers(HttpServletRequest request) throws InvocationTargetException, IllegalAccessException {
        final ObjectContext oc = getDc(request);
        Participante localParticipante = getParticipant(oc);
        final Formulario f = DataObjectUtils.objectForPK(oc, Formulario.class, request.getParameter("fid"));
        Resposta resposta = f.getRespostaForParticipante(localParticipante);

        if (resposta == null) {
            resposta = oc.newObject(Resposta.class);
            resposta.setFormulario(f);
            resposta.setParticipante(localParticipante);
            oc.commitChanges();
        }

        Date now = new Date();

        //Ficheiros nao se gravam neste bloco
        final List<Item> items = ExpressionFactory.noMatchExp(Item.TIPO_PROPERTY + "." + TTipoItem.ID_PROPERTY, TTipoItem.FICHEIRO).filterObjects(resposta.getFormulario().getItems());
        for (Item i : items) {
            final Input input = i.getInput();
            final String value = input.getValue(request);
            ItemResposta r1 = resposta.getRespostaItem(i);
            if (value == null) {
                if (r1 != null) {
                    oc.deleteObject(r1);
                    oc.commitChanges();
                }
            } else {
                if(r1==null) {
                    r1 = oc.newObject(ItemResposta.class);
                    r1.setItem(i);
                    r1.setResposta(resposta);
                }
                r1.setValor(value);
                resposta.setDataUltimaAlteracao(now);
                oc.commitChanges();
            }
        }
        msg = PowerUtils.localizeKey("msg.survey.saved", getCurrentLangBundle(),getDefaultLangBundle());

        if (request.getParameter(RequestParameters.SUBMIT + "_" + resposta.getFormulario().getId()) != null &&
                !request.getParameter(RequestParameters.SUBMIT + "_" + resposta.getFormulario().getId()).isEmpty()) {
            resposta.setDataSubmissao(now);
            resposta.setDataUltimaAlteracao(now);
            challenge = resposta.getFormulario().getProcesso();
            participant.logAction(challenge, resposta.getFormulario().getId()+"", Processo.GAMIFICATION_ACTIONS.TAKE_SURVEY,request);
            oc.commitChanges();
            msg = PowerUtils.localizeKey("msg.submit.survey", getCurrentLangBundle(),getDefaultLangBundle());
            participar(request);
        }

    }

    private void reopenSurvey(HttpServletRequest request) {
        final ObjectContext oc = getDc(request);
        try {
            final Resposta resposta = DataObjectUtils.objectForPK(oc, Resposta.class, request.getParameter("hIdR"));
            if (resposta != null) {
                resposta.setDataSubmissao(null);
                oc.commitChanges();
                msg = PowerUtils.localizeKey("msg.survey.reopened", getCurrentLangBundle(), getDefaultLangBundle());
                participant.logAction(challenge, DataObjectUtils.pkForObject(resposta.getFormulario()).toString(), Processo.GAMIFICATION_ACTIONS.REOPEN_SURVEY, request);
            } else {
                return;
            }
        } catch (Exception e) {
            PowerUtils.logErr(e, getClass(), participant);
        }
    }



    private static HashMap <String, Pair<Date,List<Status>>> tweetListCache = new HashMap<>();
    public static List<Status> SearchTweetsAsList(String search, int limit, String consumerKey, String consumerSecret, String accessToken, String accessTokenSecret, int max_query_age_millis, Locale locale){
        Pair<Date, List<Status>> cache = tweetListCache.get(search);
        if(cache==null || new Date(System.currentTimeMillis()-max_query_age_millis).after(cache.getLeft())) {

            ConfigurationBuilder cb = new ConfigurationBuilder();
            cb.setDebugEnabled(true)
                    .setOAuthConsumerKey(consumerKey)
                    .setOAuthConsumerSecret(consumerSecret)
                    .setOAuthAccessToken(accessToken)
                    .setOAuthAccessTokenSecret(accessTokenSecret);
            TwitterFactory tf = new TwitterFactory(cb.build());
            Twitter twitter = tf.getInstance();
            try {
                Query query = new Query(search + "+filter:safe");
                QueryResult result;
                result = twitter.search(query);
                List<Status> tweets = result.getTweets();
                tweetListCache.put(search,new ImmutablePair<>(new Date(), tweets));
            } catch (TwitterException te) {
                PowerUtils.logErr("Failed to search tweets: " + te, PowerPubManager.class, null);
                return new ArrayList<>();
            }
        }
        return tweetListCache.get(search).getRight();
    }

    public String getRegisterValueFor(String property, HttpServletRequest request) {
        String v = "";
        if (request.getParameter(RequestParameters.REGISTO) != null && request.getParameter(property) != null)
            v = request.getParameter(property);
        return v;
    }

    public void loginOrCreateFromFacebook(String token, JSONObject paramsObj, HttpServletRequest request) throws JSONException {
        String id = paramsObj.getString("id");
        String email = paramsObj.getString("email");
        String name = paramsObj.getString("name");

        final SelectQuery query = new SelectQuery(Participante.class, ExpressionFactory.matchExp(Participante.UID_PROPERTY, id).orExp(ExpressionFactory.matchExp(Participante.EMAIL_PROPERTY, email)));
        List<Participante> list = getDc(request).performQuery(query);

        if (list.size() > 0) {
            participant = list.get(0);
            participant.setToken(token);
            participant.setNome(name.trim());
            participant.setEmail(email.trim());
            participant.getObjectContext().commitChanges();
        } else {
            Participante participante = getDc(request).newObject(Participante.class);
            participante.setCheckKey(PowerUtils.doRandomCharacters(36));
            participante.setNome(name.trim());
            participante.setEmail(email.trim());
            participante.setToken(token);
            participante.setUid(id);
            participante.setProvider("fb");
            participante.setActivo(true);
            participante.setDataRegisto(new Date());
            participante.setPassword(MD5Crypt.crypt(getSaltString(), email.trim().toLowerCase()));

            getDc(request).commitChanges();
            participant = participante;
        }

        String system_id = getSystemId(request);
        RParticipanteSistema participa_sistema = participant.getParticipaSistema(system_id);
        if( participa_sistema == null){
            participa_sistema = getDc(request).newObject(RParticipanteSistema.class);
            participa_sistema.setFksistema(system_id);
            participa_sistema.setParticipante(participant);
        }
        participa_sistema.setDataLogin(new Date());
        getDc(request).commitChanges();

        setFailedLogin(false);
    }

    protected String getSaltString() {
        String SALTCHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        StringBuilder salt = new StringBuilder();
        Random rnd = new Random();
        while (salt.length() < 18) { // length of the random string.
            int index = (int) (rnd.nextFloat() * SALTCHARS.length());
            salt.append(SALTCHARS.charAt(index));
        }
        String saltStr = salt.toString();
        return saltStr;
    }

    public void loginOrCreateFromGoogle(String token, GoogleIdToken.Payload payload, HttpServletRequest request) {
        String id = payload.getSubject();
        String email = payload.getEmail();
        String name = (String) payload.get("name");

        final SelectQuery query = new SelectQuery(Participante.class, ExpressionFactory.matchExp(Participante.UID_PROPERTY, id).orExp(ExpressionFactory.matchExp(Participante.EMAIL_PROPERTY, email)));
        List<Participante> list = getDc(request).performQuery(query);

        if (list.size() > 0) {
            participant = list.get(0);
            participant.setToken(token);
            participant.setNome(name.trim());
            participant.setEmail(email.trim());
            participant.getObjectContext().commitChanges();
        } else {
            Participante participante = getDc(request).newObject(Participante.class);
            participante.setCheckKey(PowerUtils.doRandomCharacters(36));
            participante.setNome(name.trim());
            participante.setEmail(email.trim());
            participante.setToken(token);
            participante.setUid(id);
            participante.setProvider("google");
            participante.setActivo(true);
            participante.setDataRegisto(new Date());
            participante.setPassword(MD5Crypt.crypt(getSaltString(), email.trim().toLowerCase()));

            getDc(request).commitChanges();
            participant = participante;
        }

        String system_id = getSystemId(request);
        RParticipanteSistema participa_sistema = participant.getParticipaSistema(system_id);
        if( participa_sistema == null){
            participa_sistema = getDc(request).newObject(RParticipanteSistema.class);
            participa_sistema.setFksistema(system_id);
            participa_sistema.setParticipante(participant);
        }
        participa_sistema.setDataLogin(new Date());
        getDc(request).commitChanges();

        setFailedLogin(false);
    }

    public void createCommentFromApp(SmartRequest smartRequest) throws IOException {
        String challengeId = smartRequest.getParameter("challenge").trim();
        String title = smartRequest.getParameter("title").trim();
        String body = smartRequest.getParameter("body").trim();

        ObjectContext dc = getDc(smartRequest);
        Processo processo = DataObjectUtils.objectForPK(dc, Processo.class, challengeId);
        if (processo == null) return;


        RParticipanteComentario rpc = dc.newObject(RParticipanteComentario.class);
        rpc.setTitle(title);
        rpc.setComentario(body);
        rpc.setProcesso(processo);
        rpc.setParticipante(getParticipant(dc));
        rpc.setStatus(RParticipanteComentario.PENDING_APPROVAL);
        rpc.setLikes(0);
        rpc.setDislikes(0);
        rpc.setData(new Date());
        rpc.setTipo("comment");
        dc.commitChanges();

        String DIR_DOCS = smartRequest.getSession().getServletContext().getInitParameter("docs").startsWith("/")
                ? smartRequest.getSession().getServletContext().getInitParameter("docs")
                : smartRequest.getServletContext().getRealPath("/")+smartRequest.getSession().getServletContext().getInitParameter("docs");


        if (smartRequest.getFiles().size() > 0) {
            FileItem photo = smartRequest.getFiles().get("photo");
            if (photo == null) return;

            byte[] decodedImg = photo.get();

            String fileName = photo.getName();

            File tempFile = File.createTempFile(FilenameUtils.getBaseName(fileName) + System.currentTimeMillis(), FilenameUtils.getExtension(fileName).isEmpty() ? "" : "." + FilenameUtils.getExtension(fileName));
            InputStream is = new FileInputStream(tempFile);
            FileOutputStream fos = new FileOutputStream(tempFile);
            IOUtils.copy(is, fos);
            fos.close();
            is.close();

            File dir = new File(DIR_DOCS);
            if (!dir.exists()) {
                dir.mkdir();
            }

            File dirProcesso = new File(dir + File.separator + DataObjectUtils.pkForObject(processo));
            if (!dirProcesso.exists()) {
                dirProcesso.mkdir();
            }

            File dirComentarios = new File(dirProcesso + File.separator + "comment");
            if (!dirComentarios.exists()) {
                dirComentarios.mkdir();
            }

            ComentarioFicheiro comentarioFicheiro = new ComentarioFicheiro();
            comentarioFicheiro.setNomeFicheiro(fileName);
            comentarioFicheiro.setComentario(rpc);
            comentarioFicheiro.setMime(photo.getContentType());
            comentarioFicheiro.setSize(decodedImg.length);
            comentarioFicheiro.getObjectContext().commitChanges();

            File file = new File(dirComentarios + File.separator + comentarioFicheiro.getId());

            FileUtils.writeByteArrayToFile(file, decodedImg);
        }

        challenge = processo;
        participar(smartRequest);
    }
}
