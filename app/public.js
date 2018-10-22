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

$(document).ready(function () {

    $("img").error(function(e){
        var oldSrc = $(this).attr('src');
        if(oldSrc.indexOf('svg'))
            $(this).attr('src', $(this).data("alternative"));
        console.log('\n--------------------------------------------------------------');
        console.log('Error loading image: '+oldSrc);
        console.log(e);
        console.log('--------------------------------------------------------------\n');
    }).load(function(){
        $(this).show();
    });

    $(".toggleNext").click(function () {
        $(this).next().toggle("slow");
    });

    $(".selInput").focus(function () {
        $(this).blur();
    });

    $(".selectable").click(function (event) {
        closeSelect(event);
        if ($(this).find(".leftSelect").hasClass("lsDark"))
            $(this).find(".leftSelect").addClass("lsDarkOpen");

        if ($(this).find(".leftSelect").hasClass("lsLight"))
            $(this).find(".leftSelect").addClass("lsLightOpen");
        fillSelect($(this))
    });

    $("body").click(function (event) {
        var className = event.target.className;
        if (className.indexOf("selInput") != 0) {
            closeSelect(event);
        }
    });
});

function pField(pwd2, txt) {
    var elements = document.getElementsByClassName(pwd2);

    for (var p = 0; p < elements.length; p++) {

        var element = elements[p];
        var text_to_show = txt;
        element.type = "text"; // set the type to text for the first time
        element.value = text_to_show; // set the message for the first time
        element.onfocus = function () {
            if (this.value == text_to_show) {
                this.type = "password";
                this.value = '';
            }
        }
        element.onblur = function () {
            if (this.value == '') {
                this.type = "text";
                this.value = text_to_show;
            }
        }
    }
}

function closeSelect(e) {
    e.stopPropagation();
    $(".lsLightOpen").removeClass("lsLightOpen");
    $(".lsDarkOpen").removeClass("lsDarkOpen");
    $(".scrollableDiv").css("display", "none");
}

function setVal(event, ele) {

    $(".lsLightOpen").removeClass("lsLightOpen");
    $(".lsDarkOpen").removeClass("lsDarkOpen");

    var sib = $(ele).closest(".slimScrollDiv").siblings('.inputDiv');

    var children = sib.children(".innerSelect");
    children.children(".selInput2").val($(ele).attr('title'));
    children.children(".tId").val($(ele).attr('id').split("_")[1]);
    children.children(".selInput2").trigger("change");

    $(ele).parent(".scrollableDiv").hide();
    event.stopPropagation();
}

function go(where) {
    document.location.href = where;
}

function toggleShape(shapeID) {

    if (map != undefined) {
        var layers2 = map.getLayers();
        var a = layers2.a;
        for (var qq = 0; qq < a.length; qq++) {
            if (a[qq].q.id == shapeID)
                if (a[qq].q.visible == false)
                    a[qq].q.visible = true;
                else
                    a[qq].q.visible = false;
        }
        map.render();
    }
}

function fillSelect(ele) {

    var txt = $(ele).val().trim();

    var children = $(ele).closest(".select").find(".scrollableDiv");

    $(children).css("display", "block");
    $(children).children(".mySelect").each(function () {
        if ($(this).children("span").text().trim().toLowerCase().indexOf(txt.toLowerCase()) < 0) {
            $(this).css("display", "none");
        } else  if ($(this).children("span").text().trim().toLowerCase().indexOf(txt.toLowerCase()) >= 0) {
            $(this).css("display", "block");
        }

    });
}

function setVal2(event, ele) {
    closeSelect(event);
    var idConcelho = $(ele).attr("id").split("_")[1];
    var nomeConcelho = $(ele).attr("title");
    doSelect(ele, idConcelho, nomeConcelho);
}

function doSelect(ele, idConcelho, nomeConcelho) {
    var value = $(ele).val();
    var numDivs = $(".concelhos").length;
    var divsNome = $("#concelhos_");
    var clone = $(divsNome).clone();
    $(clone).attr("id", $(clone).attr("id") + numDivs);
    $(clone).children(".nome").children("input[type=hidden]").attr("name", $(clone).children(".nome").children("input[type=hidden]").attr("name") + numDivs);
    $(clone).children(".nome").children("input[type=hidden]").attr("value", idConcelho);
    $(clone).children(".nome").children("span").html(nomeConcelho);
    $(clone).show();
    $(clone).insertBefore($(divsNome));
}

function showSec(id, ele) {

    if (id != "") {
        $(".sec").removeClass("btnSiteSelected").addClass("btnSite");
        $(".secTit").removeClass("btnSiteSelected").addClass("btnSite");
        $(ele).children("span").removeClass("btnSite").addClass("btnSiteSelected");
    } else {
        $(".sec").removeClass("btnSiteSelected").addClass("btnSite");
        $(".secTit").removeClass("btnSite").addClass("btnSiteSelected");
        $(ele).children("span").removeClass("btnSite").addClass("btnSiteSelected");
    }

    $(".seccao").hide();
    $('#s' + id).show();
}


//Detecta si se trata de un dispositivo tactil
function tactil() {
    if (navigator.platform == 'Android' || navigator.platform == 'iPad' || navigator.platform == 'iPad Simulator' || navigator.platform == 'iPhone' || navigator.platform == 'iPod' || navigator.platform == 'Linux armv6l' || navigator.platform == 'Linux armv7l')
    {
        return true;
    } else {
        return false;
    }
}