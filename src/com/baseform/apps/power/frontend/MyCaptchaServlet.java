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

import nl.captcha.Captcha;
import nl.captcha.backgrounds.FlatColorBackgroundProducer;
import nl.captcha.noise.StraightLineNoiseProducer;
import nl.captcha.servlet.CaptchaServletUtil;
import nl.captcha.text.renderer.DefaultWordRenderer;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.io.IOException;
import java.util.*;

/**
 * Created by nunodomingues on 03/06/15.
 */
public class MyCaptchaServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static int _width = 120;
    private static int _height = 24;
    private static final java.util.List<Color> COLORS = new ArrayList(2);
    private static final java.util.List<Font> FONTS = new ArrayList(3);

    static {
        COLORS.add(new Color(51, 102, 204));
        FONTS.add(new Font("Courier", 1, 26));
    }

    public MyCaptchaServlet() {
    }

    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        if(this.getInitParameter("captcha-height") != null) {
            _height = Integer.valueOf(this.getInitParameter("captcha-height")).intValue();
        }

        if(this.getInitParameter("captcha-width") != null) {
            _width = Integer.valueOf(this.getInitParameter("captcha-width")).intValue();
        }

    }

    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
//        ColoredEdgesWordRenderer wordRenderer = new ColoredEdgesWordRenderer(COLORS, FONTS);
        DefaultWordRenderer wordRenderer = new DefaultWordRenderer(COLORS, FONTS);

        if (req.getParameter("captcha-height") != null)
            setHeight(req.getParameter("captcha-height"));

        if (req.getParameter("captcha-width") != null)
            setWidth(req.getParameter("captcha-width"));

        Captcha captcha = (new Captcha.Builder(_width, _height))
                .addText(wordRenderer)
//                .gimp(new ShearGimpyRenderer())
                .addNoise(new StraightLineNoiseProducer(new Color(51, 102, 204), 2))
                .addBackground(new FlatColorBackgroundProducer(new Color(255, 255, 255)))
                .build();

        CaptchaServletUtil.writeImage(resp, captcha.getImage());
        req.getSession().setAttribute("simpleCaptcha", captcha);
    }

    public void setWidth(String width) {
        _width = Integer.valueOf(width);
    }
    public void setHeight(String height) {
        _height = Integer.valueOf(height);
    }
}
