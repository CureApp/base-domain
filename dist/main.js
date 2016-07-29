var Facade;

Facade = require('./lib/facade');

Facade.fs = require('fs');


/**
Requires js file
in Titanium, file-not-found-like-exception occurred in require function cannot be caught.
Thus, before require function is called, check the existence of the file.
Only in iOS this check occurs.
File extension must be '.js' in Titanium.

@param {String} file name without extension
@return {any} required value
 */

Facade.requireFile = function(file) {
  var fileInfo, path, ret;
  if (typeof Ti === "undefined" || Ti === null) {
    ret = require(file);
    if (ret["default"]) {
      return ret["default"];
    } else {
      return ret;
    }
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

@param {String} path
@return {any} required value
 */

Facade.requireJSON = function(path) {
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

module.exports = Facade;
