var Facade, copy;

copy = require('copy-class').copy;


/**
Facade class of DDD pattern.

- create instance of factories
- create instance of repositories

@class Facade
@module base-domain
 */

Facade = (function() {

  /**
  create instance of Facade
  
  @method createInstance
  @static
  @param {Object} [options]
  @return {Facade}
   */
  Facade.createInstance = function(options) {
    var Constructor;
    if (options == null) {
      options = {};
    }
    Constructor = this;
    return new Constructor(options);
  };


  /**
  constructor
  
  @constructor
  @param {String} [options]
  @param {String} [options.dirname="."] path where domain definition files are included
   */

  function Facade(options) {
    var ref;
    this.classes = {};
    this.dirname = (ref = options.dirname) != null ? ref : '.';
    this.init();
  }

  Facade.prototype.init = function() {};


  /**
  get a model class
  
  @method getModel
  @param {String} name
  @return {Class}
   */

  Facade.prototype.getModel = function(name) {
    return this.require(name);
  };


  /**
  get a factory class
  
  @method getFactory
  @param {String} name
  @return {Class}
   */

  Facade.prototype.getFactory = function(name) {
    return this.require(name + "-factory");
  };


  /**
  get a repository class
  
  @method getRepository
  @param {String} name
  @return {Class}
   */

  Facade.prototype.getRepository = function(name) {
    return this.require(name + "-repository");
  };


  /**
  create a factory instance
  
  @method createFactory
  @param {String} name
  @param {Object} [options]
  @return {DomainFactory}
   */

  Facade.prototype.createFactory = function(name, options) {
    return this.create(name + "-factory", options);
  };


  /**
  create a repository instance
  
  @method createRepository
  @param {String} name
  @param {Object} [options]
  @return {DomainRepository}
   */

  Facade.prototype.createRepository = function(name, options) {
    return this.create(name + "-repository", options);
  };


  /**
  read a file and returns class
  
  @method require
  @private
  @param {String} name
  @return {Function}
   */

  Facade.prototype.require = function(name) {
    var klass, path;
    if (this.classes[name] != null) {
      return this.classes[name];
    }
    path = this.dirname + "/" + name;
    klass = require(path);
    return this.addClass(name, klass);
  };


  /**
  set klass to dictionary
  attaches getFacade() method
  
  @method addClass
  @private
  @param {String} name
  @param {Function} klass
  @param {Boolean} skipCompare skip comparing getFacade() function
  @return {Function}
  
  FIXME: the 3rd arg "skipCompare" is set only by browserified code
  because browserified classes don't have the same getFacade() method as Base
   */

  Facade.prototype.addClass = function(name, klass, skipCompare) {
    var Class, facade;
    if (skipCompare == null) {
      skipCompare = false;
    }
    if (skipCompare || klass.prototype.getFacade === this.constructor.Base.prototype.getFacade) {
      facade = this;
      Class = copy(klass);
      Class.prototype.getFacade = function() {
        return facade;
      };
      return this.classes[name] = Class;
    } else {
      return this.classes[name] = klass;
    }
  };


  /**
  read a file and returns the instance of the file's class
  
  @method create
  @private
  @param {String} name
  @param {Object} [options]
  @return {DomainFactory}
   */

  Facade.prototype.create = function(name, options) {
    var DomainClass;
    DomainClass = this.require(name);
    return new DomainClass(options);
  };


  /**
  create instance of DomainError
  
  @method error
  @param {String} reason reason of the error
  @param {String} [message]
  @return {DomainError}
   */

  Facade.prototype.error = function(reason, message) {
    var DomainError;
    DomainError = this.constructor.DomainError;
    return new DomainError(reason, message);
  };


  /**
  check if given object is instance of DomainError
  
  @method isDomainError
  @param {Error} e
  @return {Boolean}
   */

  Facade.prototype.isDomainError = function(e) {
    var DomainError;
    DomainError = this.constructor.DomainError;
    return e instanceof DomainError;
  };


  /**
  insert fixture data
  (Node.js only)
  
  @method insertFixtures
  @param {Object} [options]
  @param {String} [options.dataDir='./data'] directory to have fixture data files
  @param {String} [options.tsvDir='./tsv'] directory to have TSV files
  @param {Array(String)} [options.models=null] model names to insert. default: all models
  @return {Promise(Object)} dataPool inserted data
   */

  Facade.prototype.insertFixtures = function(options) {
    var Fixture, fixture;
    if (options == null) {
      options = {};
    }
    Fixture = require('./fixture');
    fixture = new Fixture(this, options);
    return fixture.insert(options.models).then(function() {
      return fixture.dataPool;
    });
  };

  Facade.Base = require('./base');

  Facade.BaseModel = require('./base-model');

  Facade.Entity = require('./entity');

  Facade.BaseFactory = require('./base-factory');

  Facade.BaseRepository = require('./base-repository');

  Facade.DomainError = require('./domain-error');

  return Facade;

})();

module.exports = Facade;
