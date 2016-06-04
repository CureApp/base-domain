'use strict';
var Util, clone, deepEqual;

deepEqual = require('deep-eql');

clone = require('clone');


/**
@method Util
 */

Util = (function() {
  function Util() {}


  /**
  get __proto__ of the given object
  
  @method getProto
  @static
  @param {Object} obj
  @return {Object} __proto__
   */

  Util.getProto = function(obj) {
    if (Object.getPrototypeOf != null) {
      return Object.getPrototypeOf(obj);
    } else {
      return obj.__proto__;
    }
  };


  /**
  converts hyphenation to camel case
  
      'shinout-no-macbook-pro' => 'ShinoutNoMacbookPro'
      'shinout-no-macbook-pro' => 'shinoutNoMacbookPro' # if lowerFirst = true
  
  @method camelize
  @static
  @param {String} hyphened
  @param {Boolean} [lowerFirst=false] make capital char lower
  @return {String} cameled
   */

  Util.camelize = function(hyphened, lowerFirst) {
    var i, substr;
    if (lowerFirst == null) {
      lowerFirst = false;
    }
    return ((function() {
      var j, len, ref, results;
      ref = hyphened.split('-');
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        substr = ref[i];
        if (i === 0 && lowerFirst) {
          results.push(substr);
        } else {
          results.push(substr.charAt(0).toUpperCase() + substr.slice(1));
        }
      }
      return results;
    })()).join('');
  };


  /**
  converts hyphenation to camel case
  
      'ShinoutNoMacbookPro' => 'shinout-no-macbook-pro'
      'ABC' => 'a-b-c' # current implementation... FIXME ?
  
  @method hyphenize
  @static
  @param {String} hyphened
  @return {String} cameled
   */

  Util.hyphenize = function(cameled) {
    cameled = cameled.charAt(0).toUpperCase() + cameled.slice(1);
    return cameled.replace(/([A-Z])/g, function(st) {
      return '-' + st.charAt(0).toLowerCase();
    }).slice(1);
  };

  Util.serialize = function(v) {
    var attachClassName;
    return JSON.stringify((attachClassName = function(val, inModel) {
      var isModel, item, ret;
      if ((val == null) || typeof val !== 'object') {
        return val;
      }
      if (Array.isArray(val)) {
        return (function() {
          var j, len, results;
          results = [];
          for (j = 0, len = val.length; j < len; j++) {
            item = val[j];
            results.push(attachClassName(item, inModel));
          }
          return results;
        })();
      }
      ret = {};
      isModel = val.constructor.className != null;
      Object.keys(val).forEach(function(key) {
        return ret[key] = attachClassName(val[key], isModel || inModel);
      });
      if (val instanceof Error) {
        ret.stack = val.stack;
        ret.__errorMessage__ = val.message;
      } else if (isModel && !inModel) {
        ret.__className__ = val.constructor.className;
      }
      return ret;
    })(v, false));
  };

  Util.deserialize = function(str, facade) {
    var restore;
    if (str == null) {
      return str;
    }
    return (restore = function(val) {
      var className, item, key, ret, value;
      if ((val == null) || typeof val !== 'object') {
        return val;
      }
      if (Array.isArray(val)) {
        return (function() {
          var j, len, results;
          results = [];
          for (j = 0, len = val.length; j < len; j++) {
            item = val[j];
            results.push(restore(item));
          }
          return results;
        })();
      }
      if (val.__errorMessage__) {
        ret = new Error(val.__errorMessage__);
        for (key in val) {
          value = val[key];
          ret[key] = value;
        }
        delete ret.__errorMessage__;
        return ret;
      } else if (val.__className__) {
        className = val.__className__;
        delete val.__className__;
        return facade.createModel(className, val);
      } else {
        ret = {};
        for (key in val) {
          value = val[key];
          ret[key] = restore(value);
        }
        return ret;
      }
    })(JSON.parse(str));
  };


  /**
  requires js file
  in Titanium, file-not-found-like-exception occurred in require function cannot be caught.
  Thus, before require function is called, check the existence of the file.
  Only in iOS this check occurs.
  File extension must be '.js' in Titanium.
  
  @method requireFile
  @static
  @param {String} file name without extension
  @return {any} required value
   */

  Util.requireFile = function(file) {
    var fileInfo, path;
    if (typeof Ti === "undefined" || Ti === null) {
      return require(file);
    }
    path = file + '.js';
    if (Ti.Platform.name === 'android') {
      return require(file);
    }
    fileInfo = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, path);
    if (fileInfo.exists()) {
      return require(file);
    } else {
      throw new Error(path + ": no such file.");
    }
  };


  /**
  Parse a file as JSON format.
  In Titanium, requiring JSON does not work.
  
  @method requireJSON
  @static
  @param {String} path
  @return {any} required value
   */

  Util.requireJSON = function(path) {
    var fileInfo;
    if (typeof Ti === "undefined" || Ti === null) {
      return require(path);
    }
    fileInfo = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, path);
    if (fileInfo.exists()) {
      return JSON.parse(fileInfo.read().getText());
    } else {
      throw new Error(path + ": no such file.");
    }
  };


  /**
  in Titanium, "A instanceof B" sometimes fails.
  this is the alternative.
  
  @method isInstance
  @static
  @param {Object} instance
  @param {Function} class
  @return {Boolean} A is instance of B
   */

  Util.isInstance = function(instance, Class) {
    var className;
    if (typeof Ti === "undefined" || Ti === null) {
      return instance instanceof Class;
    }
    if (!(instance != null ? instance.constructor : void 0)) {
      return false;
    }
    if (Class === Object) {
      return true;
    }
    className = Class.name;
    while (instance.constructor !== Object) {
      if (instance.constructor.name === className) {
        return true;
      }
      instance = Object.getPrototypeOf(instance);
    }
    return false;
  };

  Util.deepEqual = function(a, b) {
    return deepEqual(a, b);
  };

  Util.clone = function(v) {
    return clone(v);
  };


  /**
  Check if the given value is instanceof Promise.
  
  "val instanceof Promise" fails when native Promise and its polyfill are mixed
   */

  Util.isPromise = function(val) {
    return typeof (val != null ? val.then : void 0) === 'function';
  };

  return Util;

})();

module.exports = Util;
