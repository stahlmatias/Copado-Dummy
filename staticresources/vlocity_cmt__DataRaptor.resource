(function(){var fileNsPrefix=function(){"use strict";var scripts=document.getElementsByTagName("script");var lastScript=scripts[scripts.length-1];var scriptName=lastScript.src;var parts=scriptName.split("/");var thisScript=parts[parts.length-1];if(thisScript===""){thisScript=parts[parts.length-2]}if(scriptName.indexOf("__")!=-1&&thisScript.indexOf("__")==-1){thisScript=parts[5]&&parts[5].indexOf("__")!=-1?parts[5]:thisScript}var lowerCasePrefix=thisScript.indexOf("__")==-1?"":thisScript.substring(0,thisScript.indexOf("__")+2);lowerCasePrefix=lowerCasePrefix===""&&localStorage.getItem("nsPrefix")?localStorage.getItem("nsPrefix"):lowerCasePrefix;if(lowerCasePrefix!==""){lowerCasePrefix=/__$/.test(lowerCasePrefix)?lowerCasePrefix:lowerCasePrefix+"__"}if(lowerCasePrefix.length===0){return function(){lowerCasePrefix=window.nsPrefix?window.nsPrefix:lowerCasePrefix;if(lowerCasePrefix!==""){lowerCasePrefix=/__$/.test(lowerCasePrefix)?lowerCasePrefix:lowerCasePrefix+"__"}return lowerCasePrefix}}else{var resolvedNs=null;return function(){if(resolvedNs){return resolvedNs}try{var tofind=lowerCasePrefix.replace("__","");var name;var scanObjectForNs=function(object,alreadySeen){if(object&&object!==window&&alreadySeen.indexOf(object)==-1){alreadySeen.push(object);Object.keys(object).forEach(function(key){if(key==="ns"){if(typeof object[key]==="string"&&object[key].toLowerCase()===tofind){name=object[key]+"__";return false}}if(Object.prototype.toString.call(object[key])==="[object Array]"){object[key].forEach(function(value){var result=scanObjectForNs(value,alreadySeen);if(result){name=result;return false}})}else if(typeof object[key]=="object"){var result=scanObjectForNs(object[key],alreadySeen);if(result){name=result;return false}}if(name){return false}});if(name){return name}}};if(typeof Visualforce!=="undefined"){scanObjectForNs(Visualforce.remoting.Manager.providers,[])}else{return lowerCasePrefix}if(name){return resolvedNs=name}else{return resolvedNs=lowerCasePrefix}}catch(e){return lowerCasePrefix}}}}();var fileNsPrefixDot=function(){var prefix=fileNsPrefix();if(prefix.length>1){return prefix.replace("__",".")}else{return prefix}};
(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
/* globals fileNsPrefixDot, fileNsPrefix */
angular.module('dataraptor', ['vlocity'])
  .config(['$compileProvider', function ($compileProvider) {
      'use strict';
      $compileProvider.debugInfoEnabled(false);
  }]).constant('fileNsPrefixDot', fileNsPrefixDot)
     .constant('fileNsPrefix', fileNsPrefix);

require('./modules/dataraptor/config/config.js');

require('./modules/dataraptor/directive/dataraptor.js');

},{"./modules/dataraptor/config/config.js":2,"./modules/dataraptor/directive/dataraptor.js":3}],2:[function(require,module,exports){
angular.module('dataraptor')
    .config(['remoteActionsProvider', 'fileNsPrefixDot', function(remoteActionsProvider, fileNsPrefixDot) {
        'use strict';
        var remoteActions = {
            createNewBundle: {
                action: fileNsPrefixDot() + 'DRMapperController3.SaveBundleJSON'
            }
        };
        remoteActionsProvider.setRemoteActions(remoteActions);
    }]);

},{}],3:[function(require,module,exports){
angular.module('dataraptor')
    .factory('$dataraptor', function(remoteActions, $window) {
        'use strict';
        function ensurePropertiesNamespaced(json) {
            return Object.keys(json).reduce(function(obj, key) {
                if (/__c/.test(key)) {
                    obj[fileNsPrefix() + key] = json[key];
                } else {
                    obj[key] = json[key];
                }
                return obj;
            }, {});
        }

        return {
            createNewBundle: function(jsonConfig, dontRedirect) {
                return remoteActions.createNewBundle(ensurePropertiesNamespaced(jsonConfig));
            }
        }
    })
    .directive('dataraptor', function($dataraptor) {
        'use strict';

        return {
            restrict: 'A',
            scope: {
                dataraptor: '=?',
                drType: '=',
                drName: '=',
                outputJson: '=?',
                inputJson: '=?',
            },
            link: function(scope, element, iAttrs) {
                angular.element(element).on('click', function(event) {
                    $dataraptor.createNewBundle({
                        Name: scope.drName,
                        DRMapName__c: scope.drName,
                        Type__c: scope.drType,
                        InputJson__c: scope.inputJson,
                        TargetOutJson__c: scope.outputJson,
                    })
                });
            }
        };
    });

},{}]},{},[1]);

})();