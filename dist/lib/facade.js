'use strict';
var Facade, GeneralFactory, MasterDataResource, ModelProps, Util, getProto, ref,
  slice = [].slice;

Util = require('../util');

GeneralFactory = require('./general-factory');

MasterDataResource = require('../master-data-resource');

ModelProps = require('./model-props');

getProto = (ref = Object.getPrototypeOf) != null ? ref : function(obj) {
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
  Latest instance created via @createInstance()
  This instance will be attached base instances with no @root property.
  
  @property {Facade} latestInstance
  @static
   */

  Facade.latestInstance = null;


  /**
  create instance of Facade
  
  @method createInstance
  @static
  @param {Object} [options]
  @return {Facade}
   */

  Facade.createInstance = function(options) {
    var Constructor, instance;
    if (options == null) {
      options = {};
    }
    Constructor = this;
    instance = new Constructor(options);
    Facade.latestInstance = instance;
    return instance;
  };


  /**
  constructor
  
  @constructor
  @param {String} [options]
  @param {String} [options.dirname="."] path where domain definition files are included
  @param {Object} [options.preferred={}]
  @param {Object} [options.preferred.repository] key: modelName, value: repository name used in facade.createPreferredRepository(modelName)
  @param {Object} [options.preferred.factory] key: modelName, value: factory name used in facade.createPreferredFactory(modelName)
  @param {Object} [options.preferred.service] key: modelName, value: service name used in facade.createPreferredService(modelName)
  @param {String|Array(String)} [options.preferred.prefix] prefix attached to load preferred class
  @param {Boolean} [options.master] if true, MasterDataResource is enabled.
   */

  function Facade(options) {
    var ref1, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
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
    this.dirname = (ref1 = options.dirname) != null ? ref1 : '.';
    this.preferred = {
      repository: (ref2 = Util.clone((ref3 = options.preferred) != null ? ref3.repository : void 0)) != null ? ref2 : {},
      factory: (ref4 = Util.clone((ref5 = options.preferred) != null ? ref5.factory : void 0)) != null ? ref4 : {},
      service: (ref6 = Util.clone((ref7 = options.preferred) != null ? ref7.service : void 0)) != null ? ref6 : {},
      prefix: (ref8 = options.preferred) != null ? ref8.prefix : void 0
    };
    this.nonExistingClassNames = {};
    if (options.master) {

      /**
      instance of MasterDataResource
      Exist only when "master" property is given to Facade's option
      
      @property {MasterDataResource} master
      @optional
      @readOnly
       */
      this.master = new MasterDataResource(this);
    }
    this.init();
    if ((ref9 = this.master) != null) {
      ref9.init();
    }
  }

  Facade.prototype.init = function() {};


  /**
  get a model class
  
  @method getModel
  @param {String} modelName
  @return {Function}
   */

  Facade.prototype.getModel = function(modelName) {
    return this.require(modelName);
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
  @param {String} name
  @return {BaseFactory}
   */

  Facade.prototype.createFactory = function() {
    var name, params;
    name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(name, 'factory', params, this);
  };


  /**
  create a repository instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createRepository
  @param {String} name
  @return {BaseRepository}
   */

  Facade.prototype.createRepository = function() {
    var name, params;
    name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(name, 'repository', params, this);
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

  Facade.prototype.__create = function(name, type, params, root) {
    var Class, ClassWithConstructor;
    name = type ? name + '-' + type : name;
    Class = ClassWithConstructor = this.require(name);
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
  create a preferred repository instance
  3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createPreferredRepository
  @param {String} modelName
  @param {Object} [options]
  @param {Object} [options.noParent] if true, stop requiring parent class
  @return {BaseRepository}
   */

  Facade.prototype.createPreferredRepository = function() {
    var modelName, options, params;
    modelName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    return this.createPreferred(modelName, 'repository', options, params, this);
  };


  /**
  create a preferred factory instance
  3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredFactory
  @param {String} modelName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseFactory}
   */

  Facade.prototype.createPreferredFactory = function() {
    var modelName, options, params;
    modelName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    if (options.noParent == null) {
      options.noParent = true;
    }
    return this.createPreferred(modelName, 'factory', options, params, this);
  };


  /**
  create a preferred service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredService
  @param {String} modelName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseService}
   */

  Facade.prototype.createPreferredService = function() {
    var modelName, options, params;
    modelName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    if (options.noParent == null) {
      options.noParent = true;
    }
    return this.createPreferred(modelName, 'service', options, params, this);
  };


  /**
  create a preferred factory|repository|service instance
  
  @method createPreferred
  @private
  @param {String} modelName
  @param {String} type factory|repository|service
  @param {Object} [options]
  @param {Object} [params] params pass to constructor of Repository, Factory or Service
  @param {RootInterface} root
  @return {BaseFactory}
   */

  Facade.prototype.createPreferred = function(modelName, type, options, params, root) {
    var ParentClass, name, originalModelName;
    if (options == null) {
      options = {};
    }
    originalModelName = modelName;
    while (true) {
      name = this.getPreferredName(modelName, type);
      if (this.hasClass(name, {
        cacheResult: true
      })) {
        return this.__create(name, null, params, root);
      }
      if (options.noParent) {
        throw this.error("preferred" + type + "NotFound", "preferred " + type + " of '" + originalModelName + "' is not found");
      }
      ParentClass = this.require(modelName).getParent();
      if (!ParentClass.className) {
        throw this.error("preferred" + type + "NotFound", "preferred " + type + " of '" + originalModelName + "' is not found");
      }
      modelName = ParentClass.getName();
    }
  };


  /**
  @method getPreferredName
  @private
  @param {String} modelName
  @param {String} type repository|factory|service
  @return {String}
   */

  Facade.prototype.getPreferredName = function(modelName, type) {
    var name;
    name = this.preferred[type][modelName];
    if (name && this.hasClass(name, {
      cacheResult: true
    })) {
      return name;
    }
    if (this.preferred.prefix) {
      name = this.preferred.prefix + '-' + modelName + '-' + type;
      if (name && this.hasClass(name, {
        cacheResult: true
      })) {
        return name;
      }
    }
    return modelName + '-' + type;
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
      klass = Util.requireFile(file);
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
  @param {Object} [options]
  @param {Boolean} [options.cacheResult] cache information of non-existing name
  @return {Function}
   */

  Facade.prototype.hasClass = function(name, options) {
    var e;
    if (options == null) {
      options = {};
    }
    if (this.nonExistingClassNames[name]) {
      return false;
    }
    try {
      this.require(name);
      return true;
    } catch (_error) {
      e = _error;
      if (options.cacheResult) {
        this.nonExistingClassNames[name] = true;
      }
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
    klass.className = name;
    delete this.nonExistingClassNames[name];
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
  @return {Promise(EntityPool)} inserted data
   */

  Facade.prototype.insertFixtures = function(options) {
    var Fixture, fixture;
    if (options == null) {
      options = {};
    }
    Fixture = require('../fixture');
    fixture = new Fixture(this, options);
    return fixture.insert(options.models);
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
