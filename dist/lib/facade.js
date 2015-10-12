var Facade, GeneralFactory, camelize, copy, getProto, ref, ref1, requireFile;

require('es6-promise').polyfill();

copy = require('copy-class').copy;

ref = require('../util'), camelize = ref.camelize, requireFile = ref.requireFile;

GeneralFactory = require('./general-factory');

getProto = (ref1 = Object.getPrototypeOf) != null ? ref1 : function(obj) {
  return obj.__proto__;
};


/**
Facade class of DDD pattern.

- create instance of factories
- create instance of repositories

@class Facade
@implements RootInterface
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
  key: modelName, value: MemoryResource
  
  @property {Object(MemoryResource)} memories
   */


  /**
  constructor
  
  @constructor
  @param {String} [options]
  @param {String} [options.dirname="."] path where domain definition files are included
   */

  function Facade(options) {
    var ref2;
    this.classes = {};
    this.memories = {};
    this.dirname = (ref2 = options.dirname) != null ? ref2 : '.';
    this.init();
  }

  Facade.prototype.init = function() {};


  /**
  get a model class
  
  @method getModel
  @param {String} modelName
  @return {Function}
   */

  Facade.prototype.getModel = function(getName) {
    return this.require(getName);
  };


  /**
  get a factory class
  
  ISSUE: user will never know load failure
  
  @method getFactory
  @param {String} name
  @return {Function}
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
  create an instance of the given modelName using obj
  if obj is null or undefined, empty object will be created.
  
  @method createModel
  @param {String} modelName
  @param {Object} obj
  @param {Object} [options]
  @return {BaseModel}
   */

  Facade.prototype.createModel = function(modelName, obj, options) {
    return this.createFactory(modelName).createFromObject(obj != null ? obj : {}, options);
  };


  /**
  create a factory instance
  
  @method createFactory
  @param {String} modelName
  @params {RootInterface} root
  @return {BaseFactory}
   */

  Facade.prototype.createFactory = function(modelName, root) {
    var Factory, e;
    if (typeof root !== 'object') {
      root = void 0;
    }
    try {
      Factory = this.getFactory(modelName);
      return new Factory(root);
    } catch (_error) {
      e = _error;
      return new GeneralFactory(modelName, root != null ? root : this);
    }
  };


  /**
  create a repository instance
  
  @method createRepository
  @param {String} modelName
  @params {RootInterface} root
  @return {BaseRepository}
   */

  Facade.prototype.createRepository = function(modelName, root) {
    var Repository;
    Repository = this.getRepository(modelName);
    return new Repository(root);
  };


  /**
  get or create a memory resource to save to @memories
  
  @method useMemoryResource
  @param {String} modelName
  @return {MemoryResource}
   */

  Facade.prototype.useMemoryResource = function(modelName) {
    var base;
    return (base = this.memories)[modelName] != null ? base[modelName] : base[modelName] = new this.constructor.MemoryResource();
  };


  /**
  read a file and returns class
  
  @method require
  @private
  @param {String} name
  @return {Function}
   */

  Facade.prototype.require = function(name) {
    var file, klass;
    if (this.classes[name] != null) {
      return this.classes[name];
    }
    file = this.dirname + "/" + name;
    klass = requireFile(file);
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
      this.require(name);
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
  @param {Boolean} skipNameValidation validate class name is compatible with the name to register
  @return {Function}
   */

  Facade.prototype.addClass = function(name, klass, skipNameValidation) {
    var Class, CopiedParentClass, ParentClass, camelCasedName, facade;
    if (skipNameValidation == null) {
      skipNameValidation = false;
    }
    if (skipNameValidation) {
      camelCasedName = camelize(name);
    } else {
      if (klass.getName() !== name) {
        throw this.error("given class should be named '" + (klass.getName()) + "',\nbut '" + name + "' given.");
      }
      camelCasedName = klass.name;
    }
    ParentClass = getProto(klass.prototype).constructor;
    if (this.constructor.isBaseClass(ParentClass)) {
      Class = copy(klass, camelCasedName);
    } else {
      CopiedParentClass = this.require(ParentClass.getName());
      Class = copy(klass, camelCasedName, CopiedParentClass);
    }
    facade = this;
    Class.getFacade = function() {
      return facade;
    };
    Class.prototype.getFacade = function() {
      return facade;
    };
    return this.classes[name] = Class;
  };


  /**
  create instance of DomainError
  
  @method error
  @param {String} reason reason of the error
  @param {String} [message]
  @return {Error}
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


  /**
  check the given class is registered in facade
  
  @method isBaseClass
  @static
  @param {Function} klass
  @return {Boolean}
   */

  Facade.isBaseClass = function(klass) {
    var ref2;
    return (klass === this[klass.name]) || (klass === this.DomainError) || (((ref2 = this[klass.name]) != null ? ref2.toString() : void 0) === klass.toString());
  };


  /**
  registers the given class as a base class
  
  @method registerBaseClass
  @static
  @param {Function} klass
   */

  Facade.registerBaseClass = function(klass) {
    return this[klass.name] = klass;
  };

  Facade.Base = require('./base');

  Facade.BaseModel = require('./base-model');

  Facade.ValueObject = require('./value-object');

  Facade.Entity = require('./entity');

  Facade.AggregateRoot = require('./aggregate-root');

  Facade.BaseList = require('./base-list');

  Facade.BaseDict = require('./base-dict');

  Facade.BaseFactory = require('./base-factory');

  Facade.BaseRepository = require('./base-repository');

  Facade.BaseSyncRepository = require('./base-sync-repository');

  Facade.BaseAsyncRepository = require('./base-async-repository');

  Facade.LocalRepository = require('./local-repository');

  Facade.DomainError = require('./domain-error');

  Facade.MemoryResource = require('./memory-resource');

  Facade.Id = require('./id');

  Facade.Ids = require('./ids');

  return Facade;

})();

module.exports = Facade;
