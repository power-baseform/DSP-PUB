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

import java.util.Locale;
import java.util.ResourceBundle;

/**
 * Created by snunes on 01/08/17.
 */
public class FrontendUtils {

    public static ResourceBundle getFrontendBundle(Locale locale){
        return PowerUtils.mergeBundles(PowerUtils.getBundle(locale),PowerUtils.getBundle(locale,"com.baseform.apps.power.frontend.localization"));
    }

    public static ResourceBundle getFrontendDefaultBundle(){
        return PowerUtils.mergeBundles(PowerUtils.getDefaultBundle(),PowerUtils.getDefaultBundle("com.baseform.apps.power.frontend.localization"));
    }

}
