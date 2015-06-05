var Facade, copy,
  slice = [].slice;

require('es6-promise').polyfill();

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
  load master tables
  
  @method loadMasterTables
  @return {Promise}
   */

  Facade.prototype.loadMasterTables = function() {
    var modelName, modelNames;
    modelNames = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return Promise.all((function() {
      var base, i, len, results;
      results = [];
      for (i = 0, len = modelNames.length; i < len; i++) {
        modelName = modelNames[i];
        results.push(typeof (base = this.getRepository(modelName)).load === "function" ? base.load() : void 0);
      }
      return results;
    }).call(this));
  };


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
  get a list model class
  
  @method getListModel
  @param {String} listModelName
  @param {String} [itemModelName]
  @return {Class}
   */

  Facade.prototype.getListModel = function(listModelName, itemModelName) {
    var AnonymousListClass, BaseList, ListClass;
    BaseList = this.constructor.BaseList;
    if (this.hasClass(listModelName)) {
      ListClass = this.getModel(listModelName);
      if (!ListClass.prototype["instanceof"](BaseList)) {
        throw this.error(listModelName + " is not instance of BaseList");
      }
      return ListClass;
    }
    if (this.hasClass(itemModelName)) {
      throw this.error(itemModelName + " is not valid model name");
    }
    AnonymousListClass = BaseList.getAnonymousClass(itemModelName);
    return this.addClass(listModelName, AnonymousListClass);
  };


  /**
  get a factory class
  
  ISSUE: user will never know load failure
  
  @method getFactory
  @param {String} name
  @param {Boolean} [useAnonymousWhenFailed=false]
  @return {Function}
   */

  Facade.prototype.getFactory = function(name, useAnonymousWhenFailed) {
    var AnonymousFactory, e;
    if (useAnonymousWhenFailed == null) {
      useAnonymousWhenFailed = false;
    }
    try {
      return this.require(name + "-factory");
    } catch (_error) {
      e = _error;
      if (!useAnonymousWhenFailed) {
        throw e;
      }
      AnonymousFactory = Facade.BaseFactory.getAnonymousClass(name);
      return this.addClass(name + "-factory", AnonymousFactory);
    }
  };


  /**
  get a list factory class
  
  @method getListFactory
  @param {String} name
  @param {String} [itemModelName]
  @return {Function}
   */

  Facade.prototype.getListFactory = function(name, itemModelName) {
    var AnonymousFactory, e;
    try {
      return this.require(name + "-factory");
    } catch (_error) {
      e = _error;
      if (!itemModelName) {
        throw e;
      }
      AnonymousFactory = Facade.ListFactory.getAnonymousClass(name, itemModelName);
      return this.addClass(name + "-factory", AnonymousFactory);
    }
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
  @param {Boolean} [useAnonymousWhenFailed=false]
  @return {BaseFactory}
   */

  Facade.prototype.createFactory = function(name, useAnonymousWhenFailed) {
    var FactoryClass;
    if (useAnonymousWhenFailed == null) {
      useAnonymousWhenFailed = false;
    }
    FactoryClass = this.getFactory(name, useAnonymousWhenFailed);
    return new FactoryClass();
  };


  /**
  create a factory instance
  
  @method createFactory
  @param {String} name
  @param {String} [itemModelName]
  @return {ListFactory}
   */

  Facade.prototype.createListFactory = function(name, itemModelName) {
    var ListFactoryClass;
    ListFactoryClass = this.getListFactory(name, itemModelName);
    return new ListFactoryClass();
  };


  /**
  create a repository instance
  
  @method createRepository
  @param {String} name
  @param {Object} [options]
  @return {BaseRepository}
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
  check existence of the class of the given name
  
  @method hasClass
  @param {String} name
  @return {Function}
   */

  Facade.prototype.hasClass = function(name) {
    var e;
    try {
      this.requre(name);
      return true;
    } catch (_error) {
      e = _error;
      return false;
    }
  };


  /**
  add copied class to facade.
  the class is acquired by @require(name)
  
  attaches getFacade() method (for both class and instance)
  
  @method addClass
  @private
  @param {String} name
  @param {Function} klass
  @return {Function}
   */

  Facade.prototype.addClass = function(name, klass) {
    var Class, facade;
    facade = this;
    Class = copy(klass);
    Class.getFacade = function() {
      return facade;
    };
    Class.prototype.getFacade = function() {
      return facade;
    };
    return this.classes[name] = Class;
  };


  /**
  read a file and returns the instance of the file's class
  
  @method create
  @private
  @param {String} name
  @param {Object} [options]
  @return {BaseFactory}
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

  Facade.BaseList = require('./base-list');

  Facade.BaseFactory = require('./base-factory');

  Facade.ListFactory = require('./list-factory');

  Facade.BaseRepository = require('./base-repository');

  Facade.MasterRepository = require('./master-repository');

  Facade.DomainError = require('./domain-error');

  return Facade;

})();

module.exports = Facade;
