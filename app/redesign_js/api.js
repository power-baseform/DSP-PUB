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

function PowerApi() {
    this.user = null;
    this.challenge = null;
    this.global = null;

    this.listen();
    this.fetch(true);
}

PowerApi.prototype.listen = function() {
    var receiver = function(scope) {
        return function(e) {
            if (e.data.action != null) {
                if (e.data.action == "put") {
                    scope.put(e.data.data, function(s) {
                        e.source.postMessage({action: "putSuccess", data: s.sendableScope()}, '*');
                    })
                }
            }
        }
    };
    window.addEventListener("message", receiver(this));
};

PowerApi.prototype.updateClients = function () {
    var scope = this;
    $.get("fetchApiData.jsp").done(function (data) {
        var parse = JSON.parse(data);
        scope.user = parse.user;
        scope.challenge = parse.challenge;
        scope.global = parse.global;

        $("iframe").each(function () {
            try {
                this.contentWindow.postMessage({action: "objectChanged", data: scope.sendableScope()}, '*');
            } catch (e) {
            }
        });
    });
};

PowerApi.prototype.fetch = function(comms) {
    var scope = this;
    $.get("fetchApiData.jsp").done(function (data) {
        var parse = JSON.parse(data);
        scope.user = parse.user;
        scope.challenge = parse.challenge;
        scope.global = parse.global;

        if (comms) {
            $("iframe").each(function () {
                try {
                    this.contentWindow.postMessage({action: "new", data: scope.sendableScope()}, '*');
                } catch (e) {
                }
            });
        }
    });
};

PowerApi.prototype.sendableScope = function() {
    return {
        user: this.user,
        challenge: this.challenge,
        global: this.global
    }
};

PowerApi.prototype.put = function(points, callback) {
    var scope = this;

    if (this.user) {
        $.post("saveApiData.jsp", {points: JSON.stringify(points), user_id: this.user.id, challenge_id: this.challenge.id}).done(function(e) {
            scope.fetch(false);
            if (callback != null) callback(scope);
        }).fail(function() {
            throw "something happened and the points weren't saved"
        });
    }
};