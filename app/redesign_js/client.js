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

function PowerApiClient(callback) {
    this.callback = callback;
    this.api = {};
    this.init();
}

PowerApiClient.PERSONAL = "personal";
PowerApiClient.SOCIAL = "social";
PowerApiClient.POLITICAL = "political";

PowerApiClient.PROBLEM_AWARENESS = "problem.awareness";
PowerApiClient.PRACTICAL_KNOWLEDGE = "practical.knowledge";
PowerApiClient.READY_FOR_ACTION = "ready.for.action";

PowerApiClient.prototype.init = function() {
    var scope = this;
    window.addEventListener("message", function (e) {
        if (e.data.action != null) {
            scope.api = e.data.data;
            scope.api.user = new ApiObject(scope.api.user);
            scope.api.challenge = new ApiObject(scope.api.challenge);
            scope.api.global = new ApiObject(scope.api.global);

            if (e.data.action == "new" && scope.callback != null) scope.callback(scope);
            else if (e.data.action == "putSuccess" && scope.receiveCallback != null) scope.receiveCallback(scope);
            else if (e.data.action == "objectChanged" && scope.objectChangedCallback != null) scope.objectChangedCallback(scope);
        }
    }, false);
};

PowerApiClient.prototype.setObjectChangedCallback = function (cbk) {
    this.objectChangedCallback = cbk;
};

PowerApiClient.prototype.put = function(data, callback) {
    this.receiveCallback = callback;
    window.top.postMessage({action: "put", data: data}, '*');
};

PowerApiClient.prototype.getEmptyObject = function() {
    var returnObj = {};
    var object = {};

    if (this.getUser()) {
        object = this.getUser().getGamification();
    } else if (this.getChallenge()) {
        object = this.getChallenge().getGamification();
    } else {
        return {};
    }

    for (var i = 0; i < Object.keys(object).length; i++) {
        var obj = Object.keys(object)[i];
        var secondObject = object[obj];
        returnObj[obj] = {};

        for (var j = 0; j < Object.keys(secondObject).length; j++) {
            var obj1 = Object.keys(secondObject)[j];
            returnObj[obj][obj1] = 0;
        }
    }

    return returnObj;
};

PowerApiClient.prototype.getUser = function() {
    return this.api.user;
};

PowerApiClient.prototype.getChallenge = function() {
    return this.api.challenge
};

PowerApiClient.prototype.getGlobal = function() {
    return this.api.global
};

function ApiObject(obj) {
    this.obj = obj;
}

ApiObject.prototype.getGamification = function() {
    return this.obj.gamification;
};

ApiObject.prototype.getId = function() {
    return this.obj.id;
};

ApiObject.prototype.getAttr = function(attr) {
    return this.obj[attr];
};