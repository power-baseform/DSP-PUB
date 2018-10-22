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

function PowerSocial(str, url, deployment, thumb_url) {
    this.str = str;
    this.hub_url = url;
    this.deployment = deployment;
    this.thumb_url = thumb_url;
}

PowerSocial.prototype.getParent = function () {
    return $(".social[data-id='" + this.str + "']");
};

PowerSocial.prototype.getExtra = function() {
    var parent = this.getParent().parent();
    var extra = parent.data("extra");

    if (extra == undefined) return "";
    return extra;
}

PowerSocial.prototype.share = function (url) {
    $.get(url, function(e) { })
};

PowerSocial.prototype.shareTweet = function() {
    var name = $('.utils').data("title").trim();
    var tag = $('.utils').data("tags").trim();
    PopupCenter("https://twitter.com/intent/tweet?text="+name+ " - "+
        "&url=" + this.hub_url + "/?location=challenge&loadP=" + $(".utils").data("id") + this.getExtra() +
        "&hashtags="+tag,
        "Twitter share",450,500);

    this.share('./?share=twitter&p='+$(".utils").data("id"));
};

PowerSocial.prototype.shareGoogle = function() {
    var parent = $(".social[data-id='" + this.str + "']").parent();
    var extra = parent.data("extra");
    PopupCenter("https://plus.google.com/share?url="
        + this.hub_url + "/?location=challenge&loadP=" + $(".utils").data("id") + this.getExtra(),
        "Google + share",450,500);
    this.share('./?share=google&p='+$(".utils").data("id"));
};

PowerSocial.prototype.emailCurrentPage  = function() {
    var name = $('.utils').data("title").trim();
    var subject = this.deployment + " " + window.translations.translate("digital.social.platform");
    window.location.href="mailto:?subject="+subject+" - "+name+"&body="+name+": "+ encodeURIComponent(this.hub_url + "/?location=challenge&loadP=" + $(".utils").data("id") + this.getExtra());
    this.share('./?share=email&p='+$(".utils").data("id"));
};

PowerSocial.prototype.shareFacebook = function() {
    FB.ui({
        method: 'share',
        mobile_iframe: true,
        picture: this.thumb_url,
        href: this.hub_url + '/?location=challenge&loadP=' + $(".utils").data("id") + this.getExtra()
    }, function (response) {
    });
    this.share('./?share=facebook&p=' + $(".utils").data("id"));
};

function PopupCenter(url, title, w, h) {
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;

    var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);

    // Puts focus on the newWindow
    if (window.focus) {
        newWindow.focus();
    }
}

