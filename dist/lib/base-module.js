'use strict';
var BaseModule, Util,
  slice = [].slice;

Util = require('../util');


/**
Module of DDD pattern.

@class BaseModule
@implements RootInterface
@module base-domain
 */

BaseModule = (function() {
  function BaseModule(name1, path, facade) {
    this.name = name1;
    this.path = path;
    this.facade = facade;
  }


  /**
  is root (to identify RootInterface)
  @property {Boolean} isRoot
  @static
   */

  BaseModule.isRoot = true;


  /**
  Get facade
  
  @method getFacade
  @return {Facade}
  @chainable
   */

  BaseModule.prototype.getFacade = function() {
    return this.facade;
  };


  /**
  Get module
  
  @method getModule
  @return {BaseModule}
   */

  BaseModule.prototype.getModule = function() {
    return this;
  };

  BaseModule.prototype.normalizeName = function(name) {
    if (!name.match('/')) {
      return this.name + '/' + name;
    }
    return name;
  };

  BaseModule.prototype.stripName = function(name) {
    var len;
    len = this.name.length + 1;
    if (name.slice(0, len) === this.name + '/') {
      return name.slice(len);
    }
    return name;
  };


  /**
  get a model class in the module
  
  @method getModel
  @param {String} firstName
  @return {Function}
   */

  BaseModule.prototype.getModel = function(firstName) {
    return this.facade.require(this.normalizeName(firstName));
  };


  /**
  create an instance of the given modFirstName using obj
  if obj is null or undefined, empty object will be created.
  
  @method createModel
  @param {String} modFirstName
  @param {Object} obj
  @param {Object} [options]
  @param {RootInterface} [root]
  @return {BaseModel}
   */

  BaseModule.prototype.createModel = function(modFirstName, obj, options, root) {
    modFirstName = this.normalizeName(modFirstName);
    return this.facade.createModel(modFirstName, obj, options, this);
  };


  /**
  create a factory instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createFactory
  @param {String} modFirstName
  @return {BaseFactory}
   */

  BaseModule.prototype.createFactory = function() {
    var modFirstName, params, ref;
    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    modFirstName = this.normalizeName(modFirstName);
    return (ref = this.facade).createFactory.apply(ref, [modFirstName].concat(slice.call(params)));
  };


  /**
  create a repository instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createRepository
  @param {String} modFirstName
  @return {BaseRepository}
   */

  BaseModule.prototype.createRepository = function() {
    var modFirstName, params, ref;
    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    modFirstName = this.normalizeName(modFirstName);
    return (ref = this.facade).createRepository.apply(ref, [modFirstName].concat(slice.call(params)));
  };


  /**
  create a service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service
  
  @method createService
  @param {String} modFirstName
  @return {BaseService}
   */

  BaseModule.prototype.createService = function() {
    var modFirstName, params, ref;
    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    modFirstName = this.normalizeName(modFirstName);
    return (ref = this.facade).createService.apply(ref, [modFirstName].concat(slice.call(params)));
  };


  /**
  create a preferred repository instance
  3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createPreferredRepository
  @param {String} modFirstName
  @param {Object} [options]
  @param {Object} [options.noParent] if true, stop requiring parent class
  @return {BaseRepository}
   */

  BaseModule.prototype.createPreferredRepository = function() {
    var modFirstName, options, params, ref;
    modFirstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    modFirstName = this.normalizeName(modFirstName);
    return (ref = this.facade).createPreferredRepository.apply(ref, [modFirstName, options].concat(slice.call(params)));
  };


  /**
  create a preferred factory instance
  3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredFactory
  @param {String} modFirstName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseFactory}
   */

  BaseModule.prototype.createPreferredFactory = function() {
    var modFirstName, options, params, ref;
    modFirstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    modFirstName = this.normalizeName(modFirstName);
    return (ref = this.facade).createPreferredFactory.apply(ref, [modFirstName, options].concat(slice.call(params)));
  };


  /**
  create a preferred service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredService
  @param {String} modFirstName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseService}
   */

  BaseModule.prototype.createPreferredService = function() {
    var modFirstName, options, params, ref;
    modFirstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    modFirstName = this.normalizeName(modFirstName);
    return (ref = this.facade).createPreferredService.apply(ref, [modFirstName, options].concat(slice.call(params)));
  };


  /**
  read a file and returns class
  
  @method require
  @private
  @param {String} modFullName
  @return {Function}
   */

  BaseModule.prototype.requireOwn = function(fullName) {
    var e;
    try {
      return Util.requireFile(this.path + '/' + fullName);
    } catch (_error) {
      e = _error;
      return null;
    }
  };

  return BaseModule;

})();

module.exports = BaseModule;
