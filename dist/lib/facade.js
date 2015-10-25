var Facade, GeneralFactory, MasterDataResource, ModelProps, camelize, getProto, ref, ref1, requireFile,
  slice = [].slice;

require('es6-promise').polyfill();

ref = require('../util'), camelize = ref.camelize, requireFile = ref.requireFile;

GeneralFactory = require('./general-factory');

MasterDataResource = require('../master-data-resource');

ModelProps = require('./model-props');

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
  is root (to identify RootInterface)
  @property {Boolean} isRoot
  @static
   */
  Facade.isRoot = true;


  /**
  Get facade
  
  @method getFacade
  @return {Facade}
  @chainable
   */

  Facade.prototype.getFacade = function() {
    return this;
  };


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
  @param {Boolean} [options.master] if true, MasterDataResource is enabled.
   */

  function Facade(options) {
    var ref2, ref3;
    if (options == null) {
      options = {};
    }
    Object.defineProperties(this, {
      classes: {
        value: {}
      },
      modelProps: {
        value: {}
      }
    });
    this.dirname = (ref2 = options.dirname) != null ? ref2 : '.';
    if (options.master) {

      /**
      instance of MasterDataResource
      Exist only when "master" property is given to Facade's option
      
      @property {MasterDataResource} master
      @optional
      @readOnly
       */
      this.master = new MasterDataResource(this.dirname);
    }
    this.init();
    if ((ref3 = this.master) != null) {
      ref3.init();
    }
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
  create an instance of the given modelName using obj
  if obj is null or undefined, empty object will be created.
  
  @method createModel
  @param {String} modelName
  @param {Object} obj
  @param {Object} [options]
  @param {RootInterface} [root]
  @return {BaseModel}
   */

  Facade.prototype.createModel = function(modelName, obj, options, root) {
    return GeneralFactory.createModel(modelName, obj, options, root != null ? root : this);
  };


  /**
  create a factory instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createFactory
  @param {String} modelName
  @return {BaseFactory}
   */

  Facade.prototype.createFactory = function() {
    var modelName, params;
    modelName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(modelName, 'factory', params, this);
  };


  /**
  create a repository instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createRepository
  @param {String} modelName
  @return {BaseRepository}
   */

  Facade.prototype.createRepository = function() {
    var modelName, params;
    modelName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(modelName, 'repository', params, this);
  };


  /**
  create a service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service
  
  @method createService
  @param {String} name
  @return {BaseService}
   */

  Facade.prototype.createService = function() {
    var name, params;
    name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(name, 'service', params, this);
  };

  Facade.prototype.__create = function(modelName, type, params, root) {
    var Class, ClassWithConstructor;
    Class = ClassWithConstructor = this.require(modelName + "-" + type);
    while (ClassWithConstructor.length === 0 && ClassWithConstructor !== Object) {
      ClassWithConstructor = getProto(ClassWithConstructor.prototype).constructor;
    }
    while (params.length < ClassWithConstructor.length - 1) {
      params.push(void 0);
    }
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(Class, slice.call(params).concat([root != null ? root : this]), function(){});
  };


  /**
  read a file and returns class
  
  @method require
  @private
  @param {String} name
  @return {Function}
   */

  Facade.prototype.require = function(name) {
    var e, file, klass;
    if (this.classes[name] != null) {
      return this.classes[name];
    }
    file = this.dirname + "/" + name;
    try {
      klass = requireFile(file);
    } catch (_error) {
      e = _error;
      throw this.error('modelNotFound', "model '" + name + "' is not found");
    }
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
  add class to facade.
  the class is acquired by @require(name)
  
  @method addClass
  @private
  @param {String} name
  @param {Function} klass
  @param {Boolean} skipNameValidation validate class name is compatible with the name to register
  @return {Function}
   */

  Facade.prototype.addClass = function(name, klass, skipNameValidation) {
    if (skipNameValidation == null) {
      skipNameValidation = false;
    }
    if (typeof name === 'function') {
      klass = name;
      name = klass.getName();
    } else if (!skipNameValidation && klass.getName() !== name) {
      throw this.error('base-domain:classNameInvalid', "given class should be named '" + (klass.getName()) + "',\nbut '" + name + "' given.");
    }
    return this.classes[name] = klass;
  };


  /**
  Get ModelProps by modelName.
  ModelProps summarizes properties of this class
  
  @method getModelProps
  @param {String} modelName
  @return {ModelProps}
   */

  Facade.prototype.getModelProps = function(modelName) {
    var Model;
    if (this.modelProps[modelName] == null) {
      Model = this.getModel(modelName);
      this.modelProps[modelName] = new ModelProps(modelName, Model.properties, this);
    }
    return this.modelProps[modelName];
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

  Facade.Base = require('./base');

  Facade.BaseModel = require('./base-model');

  Facade.BaseService = require('./base-service');

  Facade.ValueObject = require('./value-object');

  Facade.Entity = require('./entity');

  Facade.AggregateRoot = require('./aggregate-root');

  Facade.Collection = require('./collection');

  Facade.BaseList = require('./base-list');

  Facade.BaseDict = require('./base-dict');

  Facade.BaseFactory = require('./base-factory');

  Facade.BaseRepository = require('./base-repository');

  Facade.BaseSyncRepository = require('./base-sync-repository');

  Facade.BaseAsyncRepository = require('./base-async-repository');

  Facade.LocalRepository = require('./local-repository');

  Facade.MasterRepository = require('./master-repository');

  Facade.DomainError = require('./domain-error');

  Facade.GeneralFactory = require('./general-factory');

  return Facade;

})();

module.exports = Facade;
