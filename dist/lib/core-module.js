var BaseModule, CoreModule,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseModule = require('./base-module');

CoreModule = (function(superClass) {
  extend(CoreModule, superClass);

  function CoreModule(path, facade) {
    this.path = path;
    this.facade = facade;
    this.name = 'core';
  }


  /**
  delete "core/"
   */

  CoreModule.prototype.normalizeName = function(modFullName) {
    if (modFullName.slice(0, 5) === 'core/') {
      return modFullName.slice(5);
    }
    return modFullName;
  };

  return CoreModule;

})(BaseModule);

module.exports = CoreModule;
