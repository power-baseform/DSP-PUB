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

function POWERController(trackId, appId, hasUser) {
    this.scrollEvents = {
        bar: null,
        menu: null,
        title: null,
        moveActions: null,
        infoBar: null,
        changeHeader: null
    };
    this.resizeEvents = {
        title: null,
        menu: null,
        bar: null,
        infoBar: null,
        tabsMenu: null,
        stickyHeader : null,
        moveActions: null
    };
    this.trackId = trackId;
    this.appId = appId;
    this.hasUser = hasUser;
    this.init();
}

function testImage(img) {
    if (img.src.indexOf('svg') < 0) return;

    var tester=new Image();
    tester.onload = function(e) {
        $(img).show();
    };
    tester.onerror=function(e){
        var oldSrc = $(img).attr('src');
        if (oldSrc.indexOf('svg'))
            $(img).attr('src', $(img).attr("data-alternative"));

        console.log('\n--------------------------------------------------------------');
        console.log('Error loading image: ' + oldSrc);
        console.log(e);
        console.log('--------------------------------------------------------------\n');
    };
    tester.src=img.src;
}

POWERController.prototype.init = function() {
    var view = this;
    if (window.docs == null)
        window.docs = [];

    if (window.params == null)
        window.params = {};

    (function(d, s, id){
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {return;}
        js = d.createElement(s); js.id = id;
        js.src = "//connect.facebook.net/en_US/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));

    window.fbAsyncInit = function() {
        FB.init({
            appId      : view.appId,
            status     : true,
            xfbml      : true,
            version    : 'v2.8'
        });

        var f = function(e) {
            if (!view.hasUser)
                location.reload();
        };

        FB.getLoginStatus(function(response) {
            if (response.status == "connected") view.loginUser(response, f);
        }, true);
    };

    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

    ga('create', view.trackId, 'auto');
    ga('send', 'pageview');

    document.addEventListener(
        'load',
        function(event){
            var tgt = event.target;
            if( tgt.tagName == 'IMG'){
                return testImage(tgt);
            }
        },
        true
    );

    $("html").on("mousemove",".hasCustomTitle", function(e) {
        e.preventDefault();
        var body = $("body");
        var cl = $(this).hasClass("rtl") ? "rtl" : "";
        if (body.find(".customTitle").length == 0) body.append($("<div class='HTMLContent customTitle " + cl + "'>" + $(this).data("custom-title") + "</div>"));
        var y = e.pageY - 72 + 10;
        var x = e.pageX + 10;

        var customTitle = $(".customTitle");
        if (window.innerWidth < e.clientX + customTitle.innerWidth()) {
            x -= Math.abs(window.innerWidth - (e.clientX + customTitle.innerWidth() + 20));
        } else if (window.innerHeight < e.clientY + customTitle.innerHeight()) {
            y -= Math.abs(window.innerHeight - (e.clientY + customTitle.innerHeight() + 20));
        }

        body.find(".customTitle").css({ top: y, left: x });
    });
    $("html").on("mouseout",".hasCustomTitle", function(e) {
        e.preventDefault();
        $(".customTitle").remove();
    });

    $("html").on("click",".closePopup, .overlay",function(e) {
        e.preventDefault();
        $(".overlay, .popup").remove()
    });

    $("html").on("click",".logout", function(e) {
        e.preventDefault();
        var href = this.href;
        try {
            FB.getLoginStatus(function(response) {
                if (response && response.status === 'connected') {
                    FB.logout(function(r) {
                        location.href = href;
                    });
                }
            }, true);
            if (gapi.auth2.getAuthInstance()) {
                gapi.auth2.getAuthInstance().signOut();
            }
        } finally {
            location.href = href;
        }
    });

    $(window).on("load", function(e) {
        $("html [title]").each(function(e, obj) {
            var title = $(obj).attr("title");
            $(obj).addClass("hasCustomTitle");
            $(obj).attr("title", null);
            obj.dataset.customTitle = title;
        });

        var f = function(e) {
            location.reload();
        };

        $("html").on("click",".fbLogin", function(e) {
            FB.login(function(response) {
                if (response.status === 'connected') {
                    view.loginUser(response, f);
                } else {
                    //location.reload();
                }
            }, {scope: 'email,public_profile'});
        });
        view.openLogin();

    });
};


POWERController.prototype.loginUser = function(response, callback) {
    $.get("loginFb.jsp", {params: JSON.stringify(response)}).done(function() {
        callback();
    });
};

POWERController.prototype.openLogin = function() {
    var view = this;
    $(".openLogin").on("click", function(e) {
        e.preventDefault();
        view.getModal("loginPopup.jsp",{ activeTab: "login"});
    });
};

POWERController.prototype.clearParams = function() {
    window.history.replaceState(null, null, window.location.pathname);
};

POWERController.prototype.initInputs = function() {
    // $("html").on("click","input[type='text']", function(e) {
    //     debugger;
    //     $(this).addClass("focusedByUser");
    //     // if (this.value != undefined) this.value = this.value + " ";
    //     // $(this).unbind("input");
    // });
    // $("html").on("input","input[type='text']", function(e) {
    //     // $(this).addClass("focusedByUser");
    //     // if ($(this).hasClass("focusedByUser")) return;
    //     var view = this;
    //     view.value = view.value + " ";
    //     setTimeout(function(e) {
    //         view.value = view.value.substr(0, view.value.length - 1);
    //     }, 50);
    //     $(view).unbind("input");
    // });
};

POWERController.prototype.sendPopupForms = function(sendClass) {
    $(sendClass).on("click", function(e) {
        e.preventDefault();
        $(this).closest("form").trigger("submit");
    });
};

POWERController.prototype.initEventCheckbox = function (parent) {
    parent.find("input[name='eventoCheck']").on("change", function(e) {
        debugger;
       go("./?" + this.dataset.param + "=" + this.dataset.id);
    });
};

POWERController.prototype.triggerAppendable = function(appendableType, cId, rId) {
  if (appendableType == "events") {
      $(".showEvents").first().trigger("click");
  } else if (appendableType == "surveys") {
      $(".jsSurvey").first().trigger("click");
  } else if (appendableType == "comments") {
      // $(".utils").data("cId", cId);
      // $(".showComments").first().trigger("click");
      var margin = 20;
      if ($(".intro.title.sticky").length == 0) margin += 35;

      if (cId != null && cId != "") {
          $("li.comment[data-id='"+ cId +"'] .actionLink.reply").trigger("click");
          $("li.comment[data-id='"+ (rId != null ? rId : cId) +"']").addClass("highlighted");
          $("html, body").animate({ scrollTop: $("li.comment[data-id='"+ cId +"']").offset().top - 200 - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
      } else {
          $("html, body").animate({ scrollTop: $(".tabContent#comments .title").offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
      }
  }
};

POWERController.prototype.initStickyHeader = function(headerClass, nextClass) {
    var head = $(headerClass);
    var height = head.height();
    head.addClass("sticky");
    $(nextClass).css("margin-top", height);

    this.resizeEvents.stickyHeader = function(e){
        $(nextClass).css("margin-top", head.height());
    }
};

POWERController.prototype.initScrollActions = function (actionsClass) {
    var actions = $(actionsClass);
    var actionsTop = actions.offset().top;

    if (($(window).scrollTop() + $(".section.header").innerHeight() + 10 + $(".intro.title").innerHeight()) >= actionsTop) {
        $(".tabAction").removeClass("hidden");
    }

    this.scrollEvents.moveActions = function(e) {
        if (($(window).scrollTop() + $(".section.header").innerHeight() + 10 + + $(".intro.title").innerHeight()) >= actionsTop) {
            $(".tabAction").removeClass("hidden");

        } else {
            $(".tabAction").addClass("hidden");

        }
    };
};

POWERController.prototype.initMobileMenu = function(btnClass, menuClass, toggleClass) {
    $(btnClass).on("click", function(e){
        e.preventDefault();
        if ($(menuClass).hasClass("toggleClass")) {
            $(menuClass).css({"height": 0});
        } else {
            var height = (window.innerHeight - $(".section.header").innerHeight() - $(".intro.title").innerHeight() - 60) - 200;
            $(menuClass).css({"height": height});
        }
        $(menuClass).toggleClass(toggleClass);
        // if (window.innerWidth < 680) {
        //     $(menuClass).find(".break680").removeClass("hidden");
        // } else {
        //     $(menuClass).find(".break680").addClass("hidden");
        // }
    });

    this.resizeEvents.tabsMenu = function(e) {
        if (window.innerWidth > 680) {
            $(menuClass).removeClass(toggleClass)
        }
    };
};

POWERController.prototype.initStatsLink = function(statsClass) {
    $(statsClass).on("click",function(e){
       e.preventDefault();
        window.location.href = "./?location=stats";
    });
};

POWERController.prototype.initTabs = function(tabClass, activeClass) {
    $("html").on("click", tabClass + ":not(.appendInfo) a", function(e) {
        e.preventDefault();

        $(".tabContent.appendable").addClass("hidden").html("");
        $(".tabContent:not(.appendable)").removeClass("hidden");
        $(tabClass).removeClass(activeClass);
        // $(this).closest(tabClass).addClass(activeClass);
        if ($(".mobileMenu").hasClass("active"))
            $(".showMenu").trigger("click");

        var margin = 20;
        if ($(".intro.title.sticky").length == 0) margin += 35;
        if ($($(this).attr("href")).length > 0)
            $("html, body").animate({ scrollTop: $($(this).attr("href")).offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
    })
};

POWERController.prototype.initLanguagePicker = function(tabClass, pickerClass) {
    $(tabClass + " .lang a").on("click", function(e) {
        e.stopPropagation();
    });
    $(tabClass).on("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        // if ($(this).attr("href") == "#") e.preventDefault();
        $(pickerClass).toggleClass("hidden");
        $(this).closest(".menuLink").toggleClass("active");
    });

};

POWERController.prototype.initFooterAutoHeight = function(footerClass){
    // var view = this;
    // var main = $("#mainDiv");
    //
    // var fHeight = footer.innerHeight();
    this.resizeEvents.footer = function(e){
        var footer =  $(footerClass);
        footer.css("bottom",-footer.innerHeight());
    }
    this.resizeEvents.footer();
};

POWERController.prototype.initChangeHeader = function(h1,h2, toggleEl) {
    var toggleElement = $(toggleEl);
    var header1 = $(h1);
    var header2 = $(h2);
    this.scrollEvents.changeHeader = function(e) {
        if ($(window).scrollTop() + header1.innerHeight() > toggleElement.offset().top + toggleElement.innerHeight()) {
            header1.addClass("hidden");
            header2.removeClass("hidden");
        } else {
            header1.removeClass("hidden");
            header2.addClass("hidden");
        }
    }
};

POWERController.prototype.initScrollEvents = function() {
    var view = this;
    var keys = Object.keys(view.scrollEvents);
    var f = function(v, k) {
        return function(e) {
            for (var i = 0; i < k.length; i++) {
                if (view.scrollEvents[k[i]] != undefined)
                    view.scrollEvents[k[i]](e);
            }
        }
    };

    $(window).on("scroll", f(view, keys));
};

POWERController.prototype.initResizeEvents = function() {
    var view = this;
    var keys = Object.keys(view.resizeEvents);
    var f = function(v, k) {
        return function(e) {
            for (var i = 0; i < k.length; i++) {
                if (view.resizeEvents[k[i]] != undefined)
                    view.resizeEvents[k[i]](e);
            }
        }
    };

    $(window).on("resize", f(view, keys));
};

POWERController.prototype.isVisible = function(elem)
{
    var docViewTop = $(window).scrollTop();
    var docViewBottom = docViewTop + $(window).innerHeight();

    if ($(elem).length == 0) return false;

    var elemTop = $(elem).offset().top;
    var elemBottom = elemTop + $(elem).innerHeight();

    return elemTop < docViewBottom;
}

POWERController.prototype.visibleSize = function(elem)
{
    var docViewTop = $(window).scrollTop();
    var docViewBottom = docViewTop + $(window).innerHeight();

    if ($(elem).length == 0) return false;

    var elemTop = $(elem).offset().top;
    var elemBottom = elemTop + $(elem).innerHeight();

    var size = docViewBottom - elemTop;

    return size > $(elem).innerHeight() ? $(elem).innerHeight() : size;
}

POWERController.prototype.initStickyInfo = function() {
    var info = $(".side.info");
    var view = this;

    info.data("initialHeight", info.height());
    this.infoTop = info.offset().top;


    this.resizeEvents.infoBar = function (e) {
        if (window.innerWidth < 680) {
            if ($(".side.menu .appendInfo .getInvolved").length == 0) {
                $(".side.menu .appendInfo").append($(".side.info").html());
            }
            if ($(".intro .mobileMenu .getInvolved").length == 0) {
                $(".intro .mobileMenu").append($(".side.menu").html());
            }
        // } else if (window.innerWidth > 680 && window.innerWidth < 1045) {

        } else if (window.innerWidth < 1045) {
            if ($(".side.menu .appendInfo .getInvolved").length == 0)
                $(".side.menu .appendInfo").append($(".side.info").html());
        } else {
            if ($(".side.menu .appendInfo .getInvolved").length > 0) {
                $(".side.info").html($(".side.menu .appendInfo").html());
                $(".side.menu .appendInfo").html("");
            }
        }


        var header = $(".section.header");
        var title = $(".intro.title");
        var tabs = window.innerWidth < 1045 ? $(".side.menu .tabs") : $(".side.info");

        var eleHeights = header.innerHeight() + 14 + title.innerHeight();
        var footerOffset = view.isVisible($(".footer")) ? view.visibleSize($(".footer")) : 0;

        if (view.mapHeights == null) {
            view.mapHeights = {
                events: $(".contentPartial.side .eventList").innerHeight(),
                surveys: $(".contentPartial.side .surveyList").innerHeight(),
                comments: $(".contentPartial.side .commentList").innerHeight(),
                apps: $(".contentPartial.side .appPromotion").innerHeight(),
                getInvolved: $(".contentPartial.side .getInvolved").innerHeight(),
                tweets: $(".contentPartial.side .tweetList").innerHeight()
            };
        }

        var functionMap = [
            {
                "apply": function(tabs) { tabs.find(".tweetList").addClass("hidden"); tabs.find(".tweetList").parent().find(".showMore").removeClass("hidden"); },
                "invert": function(tabs) {  tabs.find(".tweetList").removeClass("hidden"); tabs.find(".tweetList").parent().find(".showMore:not(.hasMore)").addClass("hidden"); },
                "height": view.mapHeights.tweets
            },
            {
                "apply": function(tabs) { tabs.find(".eventList").addClass("hidden"); tabs.find(".eventList").parent().find(".register").removeClass("hidden"); },
                "invert": function(tabs) {  tabs.find(".eventList").removeClass("hidden"); tabs.find(".eventList").parent().find(".register:not(.hasMore)").addClass("hidden"); },
                "height": view.mapHeights.events
            },
            {
                "apply": function(tabs) { tabs.find(".surveyList").addClass("hidden"); tabs.find(".surveyList").parent().find(".register").removeClass("hidden"); },
                "invert": function(tabs) {  tabs.find(".surveyList").removeClass("hidden"); tabs.find(".surveyList").parent().find(".register:not(.hasMore)").addClass("hidden"); },
                "height": view.mapHeights.surveys
            },
            {
                "apply": function(tabs) { tabs.find(".commentList").addClass("hidden"); tabs.find(".commentList").parent().find(".showMore").removeClass("hidden"); },
                "invert": function(tabs) {  tabs.find(".commentList").removeClass("hidden"); tabs.find(".commentList").parent().find(".showMore:not(.hasMore)").addClass("hidden"); },
                "height": view.mapHeights.comments
            },
            {
                "apply": function(tabs) { tabs.find(".appPromotion").addClass("hidden"); },
                "invert": function(tabs) {  tabs.find(".appPromotion").removeClass("hidden"); },
                "height": view.mapHeights.apps
            },
            {
                "apply": function(tabs) { tabs.find(".getInvolved").addClass("hidden"); },
                "invert": function(tabs) {  tabs.find(".getInvolved").removeClass("hidden"); },
                "height": view.mapHeights.getInvolved
            },
            {
                "apply": function(tabs) { tabs.css({"overflow-y": "scroll", "height": window.innerHeight - eleHeights - 20}); },
                "invert": function(tabs) { tabs.css({"overflow-y": "", "height": "auto"}) },
                "height": 20
            }
        ];

        if (window.innerWidth <= 680) {
            for (var x = 0; x<functionMap.length-1; x++) {
                functionMap[x].apply($(".intro .mobileMenu"));
            }
            return;
        }

        var availableSpace = window.innerHeight - footerOffset - eleHeights - 10;
        var invert = false;

        for (var i = 0; i<functionMap.length; i++) {
            if (tabs.height() >= availableSpace ) {
                functionMap[i].apply(tabs);
            } else if (i == 0) {
                invert = true;
                break;
            } else {
                break;
            }
        }

        if (invert) {
            for (var k = functionMap.length - 1; k >= 0; k--) {
                if (availableSpace >= tabs.height() + functionMap[k].height) {
                    functionMap[k].invert(tabs);
                } else {
                    break;
                }
            }
        }
    };

    this.scrollEvents.infoBar = function(e) {
        if (window.innerWidth < 1045) return;
        if (!info.hasClass("sticky")) {
            view.infoTop = info.offset().top;
        }
        if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()) >= view.infoTop) {
            // if (!menu.hasClass("sticky")) {
            info.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
            info.addClass("sticky");
            // }
        } else {
            info.css({top: 0});
            info.removeClass("sticky");
        }

        if (view.isVisible($(".footer"))) {
            view.resizeEvents.infoBar();
        }
    };

    this.scrollEvents.infoBar();
    if (window.innerWidth < 1045 || !view.isVisible($(".footer")))  view.resizeEvents.infoBar();
};

POWERController.prototype.initStickyMenu =  function (menuClass){
    var menu = $(".menu .tabs");
    var view = this;

    this.menuTop = menu.offset().top;

    if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()) >= this.menuTop) {
        menu.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
        menu.addClass("sticky");
    }

    this.scrollEvents.bar = function(e) {
        $(".customTitle").remove();
        if (!menu.hasClass("sticky")) {
            view.menuTop = menu.offset().top;
        }
        if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + + $(".intro.title").innerHeight()) >= view.menuTop) {
            // if (!menu.hasClass("sticky")) {
                menu.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
                menu.addClass("sticky");
            // }
        } else {
            menu.css({top: 0});
            menu.removeClass("sticky");
        }
    };


    this.resizeEvents.bar = function(e) {
        view.menuTop = menu.offset().top;
        if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + + $(".intro.title").innerHeight()) >= view.menuTop) {
            menu.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
            menu.addClass("sticky");
        } else {
            menu.css({top: $(".section.header").innerHeight() + $(".intro.title").innerHeight()});
            menu.removeClass("sticky");
        }
    };


};

POWERController.prototype.initStickyMenuSingle =  function (menuClass){
    var menu = $(".menu .tabs");
    var view = this;

    this.menuTop = menu.offset().top;

    if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()) >= this.menuTop) {
        menu.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
        menu.addClass("sticky");
    }

    this.scrollEvents.bar = function(e) {
        if (!menu.hasClass("sticky")) {
            view.menuTop = menu.offset().top;
        }
        if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + + $(".intro.title").innerHeight()) >= view.menuTop) {
            // if (!menu.hasClass("sticky")) {
            menu.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
            menu.addClass("sticky");
            // }
        } else {
            menu.css({top: 0});
            menu.removeClass("sticky");
        }
    };


    this.resizeEvents.bar = function(e) {
        view.menuTop = menu.offset().top;
        if (window.innerHeight > 1045) {
            if (($(window).scrollTop() + $(".section.header").innerHeight() + 14 + +$(".intro.title").innerHeight()) >= view.menuTop) {
                menu.css({top: $(".section.header").innerHeight() + 14 + $(".intro.title").innerHeight()});
                menu.addClass("sticky");
            } else {
                menu.css({top: $(".section.header").innerHeight() + $(".intro.title").innerHeight()});
                menu.removeClass("sticky");
            }
        }
    };


};

POWERController.prototype.initAppButtons = function() {
    $("html").on("click",".appStore", function(e){
       if ($(this).attr("href") == "#") {
           e.preventDefault();
           //POWERController.customAlert("Available Soon");
       }
    });
};

POWERController.prototype.initScrollTitle = function (menuClass) {
    var title = $(menuClass);
    var titleTop = title.offset().top;

    this.scrollEvents.title = function(e) {
        var h = $(".section.header");
        if ($(window).scrollTop() + h.innerHeight() + 30 >= titleTop) {

            var topp = h.length > 0 ? h.innerHeight() : 0;
            title.css({width: title.parent().width(), top: topp});
            title.addClass("sticky");
            $(title.siblings()[0]).css({marginTop: title.innerHeight() - 10});
        } else {
            title.css({width: "auto", top: "auto"});
            $(title.siblings()[0]).css({marginTop: 0});
            title.removeClass("sticky");
        }
    };

    this.resizeEvents.title = function(e) {
        title.css({width: title.parent().width()});
    }
    this.scrollEvents.title();
};

POWERController.prototype.removeScrollTitle = function (menuClass) {
    var title = $(menuClass);
    title.css({width: "auto", top: "auto"});
    $(title.siblings()[0]).css({marginTop: 0});
    title.removeClass("sticky");
    this.scrollEvents.title = null;
    this.resizeEvents.title = null;
};


POWERController.prototype.initScrollTab = function (menuClass, tabClass, activeClass) {
    this.scrollEvents.menu = function(e) {
        if ($(".appendable:not(.hidden)").length > 0) return;
        var menu = $(menuClass);
        var tabs = menu.find(tabClass);
        var tops = [];
        for (var i = 0; i < tabs.length; i++) {
            var t = $($(tabs[i]).find("a").attr("href"));
            if (t.length > 0)
                tops[i] = t.offset().top;
        }
        var idx = getClosest($(window).scrollTop() + $(".section.header").innerHeight() + 20 + $(".intro.title").innerHeight(), tops);
        if (idx > -1) {
            var tab = tabs[idx];
            $(tabClass).removeClass(activeClass);
            $(tab).addClass(activeClass);
        }
    }
};

POWERController.prototype.initCustomSelects = function() {
    $(".customSelect").on("click", function(e){
        $(this).find(".customSelectOptions").toggleClass("active");
        $(this).toggleClass("active");
    });

    $(".customSelect .option").on("click", function(e){
        e.preventDefault();

        var select = $(this).closest(".customSelect");
        var txt = $(this).find("a").text();
        select.find(".option").removeClass("active");
        select.find("input").val(txt);
        select.find(".customSelectTitle").html(txt);
        $(this).addClass("active");
    });
    $("html").on("click", function(e){
        var wrappers = $(".customSelect");
        for (var i = 0; i < wrappers.length; i++) {
            var w = $(wrappers[i]);
            if (!$.contains(w[0], $(e.target)[0])) {
                w.find(".customSelectOptions").removeClass("active");
            }
        }
    });
};

POWERController.prototype.initChooseFile = function() {
    $(".chooseFile").on("click", function(e) {
        e.preventDefault();
        $(this).parent().find("input[type='file'].fileInput").trigger("click");
    });
    $("html").on("change", ".customFileInput", function(e) {
        if ($(this).parent().find(".chooseFile").data("multiple") != null) {
            var l = $(this).parent().find(".chooseFile").data("multiple");
            if ($(this).parent().find(".customFileInput").length < l) {
                var clone = $(this).clone();
                clone.attr("data-order", clone.data("order") + 1);
                var attr = clone.attr("name");
                clone.attr("name", attr.split("_")[0] + "_" + (parseInt(attr.split("_")[1]) + 1));
                clone.val("");
                clone.insertAfter(this);
                $(this).parent().find(".chooseFile").removeClass("disabled");
            } else {
                $(this).parent().find(".chooseFile").addClass("disabled");
            }
            $(this).removeClass("fileInput");
            var name = this.files[0].name;
            $(this).parent().find(".fileName").html($(this).parent().find(".fileName").html() + "<div class='fileItem' data-order='" + $(this).data("order") + "'>" + name + "<a href='#' class='removeFile'>Remove File</a></div>");
        } else {
            var name = this.files[0].name;
            $(this).parent().find(".fileName").html("<div class='fileItem' data-order='" + 1 + "'>" + name + "<a href='#' class='removeFile'>Remove File</a></div>");
        }
    });
    $("html").on("click", ".removeFile", function(e) {
        e.preventDefault();
        $(this).closest(".noLabel").find(".chooseFile").removeClass("disabled");

        var data = $(this).parent().data("order");
        var input = $(this).closest(".noLabel").find("input[type='file'][data-order='" + data + "']");
        var clone = $(input).clone();
        clone.addClass("fileInput");

        var maxO = 0;
        var hasInput = false;
        var inputs = $(this).closest(".noLabel").find("input[type='file']");
        for (var i = 0; i< inputs.length; i++) {
            if (parseInt(inputs[i].dataset.order) > maxO) maxO = parseInt(inputs[i].dataset.order);
            if ($(inputs[i]).hasClass("fileInput")) hasInput = true;
        }
        clone.attr("data-order", parseInt(maxO) + 1);
        var attr = clone.attr("name");
        clone.attr("name", attr.split("_")[0] + "_" + (parseInt(maxO) + 1));
        clone.addClass("fileInput");
        clone.val("");
        if (!hasInput)
            clone.insertAfter(input);

        input.remove();
        $(this).parent().remove();
    });
};

function getClosest(x, a) {
    var temp = [];
    for (var i = 0; i<a.length; i++) {
        temp[i]=x-a[i];
    }
    temp = temp.filter(function(x) { return x > -1 });
    return temp.indexOf(Math.min.apply(null,temp));
}

POWERController.prototype.downloadFile =  function (doc, total, url){
    go(url + "/doc?id=" + doc);
    if(total > 0 && window.docs.indexOf(doc) == -1) {
        POWERController.customAlert("You have been awarded " + total + " points for your participation!");
        docs[docs.length] = doc;
    }
};

POWERController.prototype.initShowMap = function(showMapClass) {
    $(showMapClass).on("click", function(e) {
        e.preventDefault(); POWERController.getModal('mapPopup.jsp', {});
    })
}

POWERController.prototype.initCustomCheckbox = function() {
    $(".customCheckbox input[type='checkbox']").on("change", function(e){
        if ($(this).prop("checked")){
            $(this).closest(".customCheckbox").addClass("checked");
        } else {
            $(this).closest(".customCheckbox").removeClass("checked");
        }
    });
};

POWERController.prototype.initReply = function() {
    var lists = $(".commentListPage");
    lists.on("click",".actionLink.reply", function(e) {
        $(this).closest(".comment").find(".replyBox").toggleClass("hidden");

        if ($(this).closest(".comment").find(".replyBox").hasClass("hidden")) {
            $(this).text(window.translations.translate("action.comment") + " (" + this.dataset.count + ")");
        } else {
            $(this).text(window.translations.translate("hide replies"));
        }
    });
};

POWERController.prototype.initPagination = function() {
    var lists = $(".commentListPage");
    // for (var i = 0; i<lists.length; i++) {
    //     this.getCommentPage($(lists[i]), lists[i].dataset.page, lists[i].dataset.type);
    // }

    var v = this;
    lists.on("click", ".pagination .page",function(e) {
        e.preventDefault();
        if (this.dataset.page == 1) {
            window.ts = new Date().getTime();
        }
        v.getCommentPage($(".commentListPage[data-type='" + $(this).closest(".pagination").data("type") + "']"), this.dataset.page, $(this).closest(".pagination").data("type"));
    });

    lists.on("click", ".loadMoreResponses",function(e) {
        e.preventDefault();
        var cs = $(this).closest(".appendResponses").find(".comment");
        v.getReplyPage($(cs[cs.length - 1]), this.dataset.page, this.dataset.id, this);
    });
    lists.on("click", ".loadMoreComments", function(e) {
        e.preventDefault();
        var cs = $(this).parent().find(".appendComments").find(".comment:not(.replyBox .comment)");
        v.appendComments($(cs[cs.length - 1]), this.dataset.page, this.dataset.type, this);
    });
    lists.on("click", ".reloadComments", function(e) {
        e.preventDefault();
        var cs = $(this).parent().parent().find(".appendComments").find(".comment:not(.replyBox .comment)");
        v.getNewComments($(cs[0]), this.dataset.type);
    });
    lists.on("click", ".reloadResponses", function(e) {
        e.preventDefault();
        var cs = $(this).parent().parent().find(".appendResponses").find(".comment");
        v.getNewResponses($(cs[0]), this.dataset.id);
    });
};

POWERController.prototype.getReplyPage = function(content, page, commentId, a) {
    $.get("replyPage.jsp", { page: page, comment: commentId, timestamp: window.ts }, function(data, d, req) {
        content.after($(data));
        if (req.getResponseHeader("hideBtn_response_" + commentId) != null)
            $(a).addClass("hidden");
        else
            a.dataset.page = parseInt(a.dataset.page) + 1;

        if (req.getResponseHeader("newResponses_" + commentId) != null) {
            content.closest(".replyBox").find(".newResponses").removeClass("hidden");
            content.closest(".replyBox").find(".newResponses .count").html(req.getResponseHeader("newResponses_" + commentId));
        } else {
            content.closest(".replyBox").find(".newResponses").addClass("hidden");
        }
    });
};

POWERController.prototype.getNewComments = function(content, type) {
    $.get("commentList.jsp", { type: type, timestamp: window.ts }, function(data) {
        content.before(data);
        window.ts = new Date().getTime();
        content.closest(".commentListPage").find(".newComments").addClass("hidden");
    });
};

POWERController.prototype.getNewResponses = function(content, commentId) {
    $.get("replyPage.jsp", { comment: commentId, timestamp: window.ts }, function(data) {
        content.before(data);
        window.ts = new Date().getTime();
        content.closest(".replyBox").find(".newResponses").addClass("hidden");
    });
};

POWERController.prototype.getCommentPage = function(content, page, type) {
    $.get("commentList.jsp", { page: page, type: type, timestamp: window.ts }, function(data) {
        content.html(data);
    });
};

POWERController.prototype.appendComments = function(content, page, type, a) {
    $.get("commentList.jsp", { page: page, type: type, timestamp: window.ts }, function(data, k , req) {
        content.after($(data));
        if (req.getResponseHeader("hideBtn_" + type) != null)
            $(a).addClass("hidden");
        else
            a.dataset.page = parseInt(a.dataset.page) + 1;

        if (req.getResponseHeader("newComments_" + type) != null) {
            content.closest(".commentListPage").find(".newComments").removeClass("hidden");
            content.closest(".commentListPage").find(".newComments .count").html(req.getResponseHeader("newComments_" + type));
        } else {
            content.closest(".commentListPage").find(".newComments").addClass("hidden");
        }
    });
};

POWERController.prototype.initSurveys = function(surveyClass, showMoreClass) {
    $("html").on("click", surveyClass, function(e){
        e.preventDefault();
        if ($(".mobileMenu").hasClass("active"))
            $(".showMenu").trigger("click");

        if ($(".tabContent.appendable .surveys").length > 0) {
            $(".tabContent.appendable").addClass("hidden").html("");
            $(".tabContent:not(.appendable)").removeClass("hidden");
        } else {
            $(".tab.active").removeClass("active");
            $.get("getSurvey.jsp", { id: this.dataset.id }, function(data) {
                $(".tabContent.appendable").removeClass("hidden").html(data);
                $(".tabContent:not(.appendable)").addClass("hidden");
                var margin = 20;
                if ($(".intro.title.sticky").length == 0) margin += 35;
                $("html, body").animate({ scrollTop: $(".tabContent.appendable .title").offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
            });
        }
    });
    $("html").on("click",showMoreClass, function(e){
        e.preventDefault();
        if ($(".mobileMenu").hasClass("active"))
            $(".showMenu").trigger("click");

        if ($(".tabContent.appendable .surveys").length > 0) {
            $(".tabContent.appendable").addClass("hidden").html("");
            $(".tabContent:not(.appendable)").removeClass("hidden");
        } else {
            $(".tab.active").removeClass("active");
            $.get("getSurveyList.jsp", { id: this.dataset.id }, function(data) {
                $(".tabContent.appendable").removeClass("hidden").html(data);
                $(".tabContent:not(.appendable)").addClass("hidden");
                $(".tabContent.appendable").css("min-height", $(".side.info").data("initialHeight"));
                var margin = 20;
                if ($(".intro.title.sticky").length == 0) margin += 35;
                $("html, body").animate({ scrollTop: $(".tabContent.appendable .title").offset().top - ($(".section.header").innerHeight() + margin + $(".intro.title").innerHeight())}, 1000);
            });
        }
    });
};

function go(where) {
    document.location.href = where;
}

POWERController.prototype.initParticpationTypes = function() {
    $(".participationList .participationType a").on("click", function(e) {
        e.preventDefault();
        return;
        var ct = $(this).closest(".issue").find(".participationContent .participationType[data-type='" + this.dataset.type + "']");
        $(this).closest(".issue").find(".participationContent .participationType").not(ct).addClass("hidden");
        if (ct.hasClass("hidden")) {
            ct.removeClass("hidden");
        } else {
            ct.addClass("hidden");
        }
    });

    $(".participationType .survey .title, .participationType .survey .details").on("click", function(e){
        e.preventDefault();
        return;
        $(this).closest(".survey").find(".content").toggleClass("hidden");
    });
}

POWERController.prototype.forgotPassword = function() {
    $(".forgotPassword").on("click", function(e){
        e.preventDefault();
        $(".forgotPasswordHolder").toggleClass("hidden");
    });
}

POWERController.prototype.initRegisterForm = function(registerFormClass) {
    var view = this;
    $(registerFormClass).on("submit", function(e) {
        e.preventDefault();
        view.getModal("registerPopup.jsp", {email: $(this).find("#registerUsername").val(), pwd: $(this).find("#registerPassword").val()});
    });
};

POWERController.prototype.initRegisterMobile = function(registerMobileClass) {
    var view = this;
    $(registerMobileClass).on("click", function(e) {
        e.preventDefault();
        view.getModal("loginPopup.jsp",{ activeTab: "register"});
    });
};

POWERController.prototype.initActions =  function (shareClass, followClass, shareNameClass){
    var view = this;
    var utils = $(".utils").data();
    $("html").on("click",followClass, function(e){
        if (utils.status) {
            if(utils.followstatus) {
                go("?location=challenge&"+utils.loadp+"="+utils.id+"&"+utils.action+"="+utils.actionunfollow+"&"+utils.iprocesso+"=" + utils.id);
            }else {
                go("?location=challenge&"+utils.loadp+"="+utils.id+"&"+utils.action+"="+utils.actionfollow+"&"+utils.iprocesso+"="+utils.id);
            }
        } else {
            view.getModal("loginPopup.jsp",{ activeTab: "login"});
        }
    });

    $("html").on("click",shareClass, function(e){
        e.preventDefault();
        $(this).find(".actionName").addClass("hidden");
        $(this).find(".social").addClass("active");
    });
    $("html").on("click",shareClass + " .actionSvg", function(e){
        if ($(this).parent(".action").find(".social.active").length > 0) {
            e.stopPropagation();
            $(this).parent(".action").find(".actionName").removeClass("hidden");
            $(this).parent(".action").find(".social").removeClass("active");
        }
    });
};

POWERController.prototype.initShare = function(social) {
    social.getParent().find(".facebook").on("click", function(e){
        social.shareFacebook();
    });

    social.getParent().find(".email").on("click", function(e){
        social.emailCurrentPage();
    });

    social.getParent().find(".twitter").on("click", function(e){
        social.shareTweet();
    });

    social.getParent().find(".google").on("click", function(e){
        social.shareGoogle();
    });
}

POWERController.prototype.getModal = function(url, params, cbk) {
    $.get(url, params, function(data){
        var popup = $(data);
        $("body").append(popup);
        $("form.tabContent[data-tab='login']").on("submit", function(e) {
           if (cbk != null){
               e.preventDefault();
               cbk(e);
           }
        });
    });
};
POWERController.prototype.getPopup = function(url, top, left) {
    $.get(url, function(data){
        var popup = $(data);
        popup.css({
            top: top,
            left: left
        });
        $("body").append(popup);
    });
    $("html").on("click", function(e) {
        var popups = $(".popup");
        for (var j = 0; j < popups.length; j++) {
            var p = $(popups[j]);
            if (!$.contains(p[0], $(e.target)[0])) {
                p.remove();
            }
        }
    });
};
POWERController.prototype.initTweets = function(showClass) {
    $("html").on("click",showClass, function(e) {
        e.preventDefault();
        if ($(".mobileMenu").hasClass("active"))
            $(".showMenu").trigger("click");

        if ($(".tabContent.appendable .tweets").length > 0) {
            $(".tabContent.appendable").addClass("hidden").html("");
            $(".tabContent:not(.appendable)").removeClass("hidden");
        } else {
            $(".tab.active").removeClass("active");
            $.get("tweetList.jsp", function(data) {
                $(".tabContent.appendable").removeClass("hidden").html(data);
                $(".tabContent:not(.appendable)").addClass("hidden");
                $(".tabContent.appendable").css("min-height", $(".side.info").data("initialHeight"));
                var margin = 20;
                if ($(".intro.title.sticky").length == 0) margin += 35;
                $("html, body").animate({ scrollTop: $(".tabContent.appendable .title").offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
            });
        }
    });
};
POWERController.prototype.initResponsiveBackground = function(bgContainer) {
    var image_url = $(bgContainer).css('background-image'),
        image;

    var view = this;
    var runned = false;

    // Remove url() or in case of Chrome url("")
    image_url = image_url.match(/^url\("?(.+?)"?\)$/);
    var width, height;

    if (image_url[1]) {
        image_url = image_url[1];
        image = new Image();

        // just in case it is not already loaded
        $(image).load(function () {
            runned = true;
            width = image.width;
            height = image.height;
            f();
        });

        image.src = image_url;
    }
    var f = function(e) {
        if ($(bgContainer).width() < width) {
            $(bgContainer).css("background-size", "auto auto");
        }
        if ($(bgContainer).width() > width) {
            $(bgContainer).css("background-size", "100% auto");
        }
        if ($(bgContainer).width() > width && $(bgContainer).height() > height) {
            $(bgContainer).css("background-size", "100% 100%");
        }
    };
    $(window).on("resize", f);

    if (!runned && image.width != undefined) {
        width = image.width;
        height = image.height;
        f();
    }
}

POWERController.prototype.initLegalCheckbox = function(legalClass) {
    $(legalClass + " input[type='checkbox']").on("change", function(e) {
        $(this).closest("label").toggleClass("active");
    });
}

POWERController.prototype.initComments = function(showClass) {
    $("html").on("click",showClass, function(e) {
        e.preventDefault();
        if ($(".mobileMenu").hasClass("active"))
            $(".showMenu").trigger("click");

        $(".tabContent.appendable").addClass("hidden").html("");
        $(".tabContent:not(.appendable)").removeClass("hidden");

        var margin = 20;
        if ($(".intro.title.sticky").length == 0) margin += 35;
        $("html, body").animate({ scrollTop: $(".tabContent#comments .title").offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
        //
        // if ($(".tabContent.appendable .comments").length > 0) {
        //     $(".tabContent.appendable").addClass("hidden").html("");
        //     $(".tabContent:not(.appendable)").removeClass("hidden");
        // } else {
        //     $(".tab.active").removeClass("active");
        //     var params = {};
        //     var cId = $(".utils").data("cId");
        //     if (cId != null  && cId != "" ) params = { cId: cId };
        //     $.get("commentBox.jsp", params, function(data) {
        //         $(".tabContent.appendable").removeClass("hidden").html(data);
        //         $(".tabContent:not(.appendable)").addClass("hidden");
        //         $(".tabContent.appendable").css("min-height", $(".side.info").data("initialHeight"));
        //         var margin = 20;
        //         if ($(".intro.title.sticky").length == 0) margin += 35;
        //
        //         if (cId != null && cId != "") {
        //             $("li.comment[data-id='"+ cId +"']").addClass("highlighted");
        //             $("li.comment[data-id='"+ cId +"'] .actionLink.reply").trigger("click");
        //             $(".utils").data("cId", null);
        //             $("html, body").animate({ scrollTop: $("li.comment[data-id='"+ cId +"']").offset().top - 200 - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
        //         } else {
        //             $("html, body").animate({ scrollTop: $(".tabContent.appendable .title").offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
        //         }
        //     });
        // }
    });
};
POWERController.prototype.initEvents = function(showClass) {
    $("html").on("click",showClass, function(e) {
        e.preventDefault();
        if ($(".mobileMenu").hasClass("active"))
            $(".showMenu").trigger("click");

        if ($(".tabContent.appendable .events").length > 0) {
            $(".tabContent.appendable").addClass("hidden").html("");
            $(".tabContent:not(.appendable)").removeClass("hidden");
        } else {
            $(".tab.active").removeClass("active");
            $.get("eventList.jsp", function(data) {
                $(".tabContent.appendable").removeClass("hidden").html(data);
                $(".tabContent:not(.appendable)").addClass("hidden");
                $(".tabContent.appendable").css("min-height", $(".side.info").data("initialHeight"));
                var margin = 20;
                if ($(".intro.title.sticky").length == 0) margin += 35;
                $("html, body").animate({ scrollTop: $(".tabContent.appendable .title").offset().top - ($(".section.header").innerHeight() + margin + + $(".intro.title").innerHeight())}, 1000);
            });
        }
    });
};

POWERController.prototype.popupRegister = function (button) {
    var view = this;
    $(button).on("click", function(e){
        e.preventDefault();
        $(".overlay, .popup").remove();
        view.getModal("registerPopup.jsp", {});
    });
};

POWERController.prototype.popupForgotPassword = function (button) {
    var view = this;
    $(button).on("click", function(e){
        e.preventDefault();
        $(".overlay, .popup").remove();
        view.getModal("forgotPasswordPopup.jsp", {});
    });
};

POWERController.prototype.initBoxGrow = function() {
    $("html").on("click",".comments textarea", function(e) {
        $("textarea.focus").removeClass("focus");
        $(this).addClass("focus");
    });

    $("html").on("click", function(e){
        var wrappers = $(".comments");
        var remove = true;
        for (var i = 0; i < wrappers.length; i++) {
            var w = $(wrappers[i]);
            if (!$.contains(w[0], $(e.target)[0])) {
                remove = true;
            } else {
                remove = false;
                break;
            }
        }
        if (remove) $(".comments textarea.focus").removeClass("focus");
    });
}

POWERController.prototype.initFormSubmit = function () {
    var view = this;
    $("html").on("click", ".sendComment", function(e) {
        var f = $(this).closest("form");
        if (this.dataset.participante == "true") {
            f.submit();
        } else {
            var cbk = function(f) {
                return function(e) {
                    f.find("input[name='loginEmail']").val($(e.currentTarget).find("#loginUsername").val());
                    f.find("input[name='loginPassword']").val($(e.currentTarget).find("#loginPassword").val());
                    f.submit();
                };
            };
            view.getModal("loginPopup.jsp",{ activeTab: "login"}, cbk(f))
        }
    });
};

POWERController.prototype.popupTabs = function(tabClass) {
  $(tabClass).on("click", function(e) {
      e.preventDefault();
      var tab = this.dataset.tab;
      if (tab.length == 0) return;

      $(this).siblings().removeClass("active");
      $(this).addClass("active");
      $(this).closest(".popup").find(".tabContent").addClass("hidden");
      $(this).closest(".popup").find(".tabContent[data-tab='" + tab + "']").removeClass("hidden");
  });
};

POWERController.prototype.initMobileHeaderMenu = function(menuClickClass, menuClass, toggleClass) {
    // this.resizeEvents.mobileMenu = function(e) {
    //     if (window.innerWidth < 680) {
    //         $(".header.issue .menu").addClass("mobile");
    //     } else {
    //         $(".header.issue .menu").removeClass("mobile");
    //         $(".header.issue .menu .userActions").remove();
    //     }
    // };
    // this.resizeEvents.mobileMenu();
    //
    // $(".header.issue .showMobileMenu").on("click", function (e) {
    //    e.preventDefault();
    //    $(".header.issue .menu.mobile").toggleClass("active");
    //    if ($(".header.issue .menu.mobile .loginForm").length == 0) {
    //        $(".header.issue .menu.mobile").append("<li class='userActions'>" + $(".header.issue .loginForm")[0].outerHTML + "" + $(".header.issue .userMenu")[0].outerHTML + "</li>")
    //    } else {
    //        $(".header.issue .menu.mobile .loginForm, .header.issue .menu.mobile .userMenu").remove();
    //    }
    // });
    // $(menuClickClass).on("click", function(e) { $(menuClass).toggleClass(toggleClass); });
};

POWERController.prototype.gotIt = function() {
    $(".jsGotIt").on("click", function(e){
        e.preventDefault();
        gotIt(this.dataset.id, $(this));
    });
};

POWERController.prototype.cleanHTMLContent = function(content) {
    var rules = {
        "font-family": '',
        "font-size": '',
        "float": '',
        "color": '',
        "background": '',
        "background-color": ''
    };

    $(content).css(rules);

    $(content).find("img").each(function(e) {
        if ($(this).attr("alt") == null) {
            $(this).attr("alt", $(this).attr("title"));
        }
    });

    $(content).find("a").each(function(e) {
        if ($(this).attr("href") && $(this).attr("href").indexOf("#") == 0) return;
        $(this).attr('target', '_blank');
    });

    $(content).find("a").on("click", function(e) {
        if ($(this).attr("href") && $(this).attr("href").indexOf("#") == 0) {
            e.preventDefault();
            $("html").animate({ scrollTop: parseInt($($(e.target).attr("href"))[0].getBoundingClientRect().top) }, 200);
            }
    });

    if (window.innerWidth < 420){
        $(content).css({
            "padding-left": 0,
            "padding-right": 0,
            "margin-left": 0,
            "marign-right": 0
        });
    }
    //
    // var lineBreaks = $(content).filter("p").filter(function(e){
    //    if (this.innerHTML.match(/(\s*&nbsp;\s*)/g)) return true;
    // });
    // lineBreaks.remove();
};

POWERController.prototype.setLinkGrabber = function(content) {
    var clickLink = $(".utils").data("clickLink");
    var pId = $(".utils").data("id");



    $(content).find("a").each(function(e) {
        var url = $(this).attr('href');
        if (url.startsWith("#")) return;
        $(this).attr('href',"./?location=link_grabber&p=" + pId + "&" + clickLink + "="+url);
    });
};

POWERController.prototype.getPointsPopup = function(obj) {
    $.get("pointsPopup.jsp", {params: JSON.stringify(obj)}, function(data){
        var popup = $(data);
        $("body").append(popup);
        window.POWER.updateClients();
    });
};

POWERController.prototype.customAlert = function(str) {
    $.get("customAlert.jsp", {str: str}, function(data){
        var popup = $(data);
        $("body").append(popup);
        setTimeout(function(e){
            popup.addClass("positioned");
        }, 200);
    });
};

POWERController.prototype.initChartClick = function(str) {
    $(str).on("click", function(e){
       location.href = "./?location=area";
    });
};


POWERController.prototype.resizeHTMLContent = function(content, parent) {
    var c = $(content);
    var p = $(parent);
    var f = function(e) {
        var els = c.filter(function(i) {
            return this.offsetWidth > p.innerWidth() || ($(this).attr("initialWidth") != null && this.offsetWidth < $(this).attr("initialWidth"));
        });

        for (var i = 0; i<els.length; i++) {
            var el = els[i];
            if ($(el).attr("initialWidth") == undefined) $(el).attr("initialWidth", el.offsetWidth);
            var rules = {width: p.innerWidth()};
            if (!$(el).is("iframe")) {
                rules.height = "auto";
                $(el).attr("height", "auto");
            }
            $(el).css(rules).attr("width", p.innerWidth());
        }
    };

    this.resizeEvents.htmlContent = f;
    f();
};

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


function gotIt(sectionId,elem){
    var button = elem;
    params['got_it_section']=sectionId;
    $.post('ajax/gotItSection.jsp',params,function(data){
        if(data.gotit){
            button.addClass("alreadyGot");
            checkPointsAward(data.points);
        }else POWERController.customAlert('error saving \"got it!\"');
    });
}


function checkPointsAward (points_awarded){
    if(points_awarded != "")
    {
        if(points_awarded == "-1") {
            POWERController.customAlert("Error processing point awards!");
        }
        else if(Object.keys(points_awarded).length > 0) {
            POWERController.getPointsPopup(points_awarded);
        }
    }
}


function like(id){
    jQuery.ajax({
        url: "./ajax/processLikes.jsp?like="+id,
        type: "get",
        contentType: "html",
        success: function (res) {
            var obj = JSON.parse(res);
            $("#like_"+id).html(obj[0].likes);
            var points_awarded = "";
            checkPointsAward(points_awarded);
        }
    });
}

function dislike(id){
    jQuery.ajax({
        url: "./ajax/processLikes.jsp?dislike="+id,
        type: "get",
        contentType: "html",
        success: function (res) {
            var obj = JSON.parse(res);
            $("#like_"+id).html(obj[0].likes);
            var points_awarded = "";
            checkPointsAward(points_awarded);
        }
    });
}
