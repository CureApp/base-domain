'use strict';
var BaseModule, CoreModule, Facade, GeneralFactory, MasterDataResource, ModelProps, Util,
  slice = [].slice;

Util = require('../util');

GeneralFactory = require('./general-factory');

MasterDataResource = require('../master-data-resource');

ModelProps = require('./model-props');

BaseModule = require('./base-module');

CoreModule = require('./core-module');


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
  @param {Object} [options.preferred.repository] key: firstName, value: repository name used in facade.createPreferredRepository(firstName)
  @param {Object} [options.preferred.factory] key: firstName, value: factory name used in facade.createPreferredFactory(firstName)
  @param {Object} [options.preferred.service] key: firstName, value: service name used in facade.createPreferredService(firstName)
  @param {String|Array(String)} [options.preferred.module] module prefix attached to load preferred class
  @param {Boolean} [options.master] if true, MasterDataResource is enabled.
   */

  function Facade(options) {
    var moduleName, path, ref, ref1, ref10, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
    if (options == null) {
      options = {};
    }
    Object.defineProperties(this, {
      nonExistingClassNames: {
        value: {}
      },
      classes: {
        value: {}
      },
      modelProps: {
        value: {}
      },
      modules: {
        value: {}
      },
      preferred: {
        value: {
          repository: (ref = Util.clone((ref1 = options.preferred) != null ? ref1.repository : void 0)) != null ? ref : {},
          factory: (ref2 = Util.clone((ref3 = options.preferred) != null ? ref3.factory : void 0)) != null ? ref2 : {},
          service: (ref4 = Util.clone((ref5 = options.preferred) != null ? ref5.service : void 0)) != null ? ref4 : {},
          module: (ref6 = options.preferred) != null ? ref6.module : void 0
        }
      }
    });
    this.dirname = (ref7 = options.dirname) != null ? ref7 : '.';
    ref9 = Util.clone((ref8 = options.modules) != null ? ref8 : {});
    for (moduleName in ref9) {
      path = ref9[moduleName];
      this.modules[moduleName] = new BaseModule(moduleName, path, this);
    }
    if (this.modules.core) {
      throw this.error('invalidModuleName', 'Cannot use "core" as a module name');
    }
    this.modules.core = new CoreModule(this.dirname, this);
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
    if ((ref10 = this.master) != null) {
      ref10.init();
    }
  }

  Facade.prototype.init = function() {};

  Facade.prototype.initWithPacked = function(packed) {
    var core, klass, klassName, klasses, masterData, moduleName, modules, ref;
    masterData = packed.masterData, core = packed.core, modules = packed.modules;
    if (masterData && (this.master == null)) {
      this.master = new MasterDataResource(this);
    }
    if ((ref = this.master) != null) {
      ref.init = function() {
        return this.initWithData(masterData);
      };
    }
    for (klassName in core) {
      klass = core[klassName];
      this.addClass(klassName, klass);
    }
    for (moduleName in modules) {
      klasses = modules[moduleName];
      for (klassName in klasses) {
        klass = klasses[klassName];
        this.addClass(moduleName + '/' + klassName, klass);
      }
    }
    return this;
  };


  /**
  get a model class
  
  @method getModel
  @param {String} firstName
  @return {Function}
   */

  Facade.prototype.getModel = function(firstName) {
    return this.require(firstName);
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

  Facade.prototype.createModel = function(modFirstName, obj, options, root) {
    return GeneralFactory.createModel(modFirstName, obj, options, root != null ? root : this);
  };


  /**
  create a factory instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createFactory
  @param {String} modFirstName
  @return {BaseFactory}
   */

  Facade.prototype.createFactory = function() {
    var modFirstName, params;
    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(modFirstName, 'factory', params, this);
  };


  /**
  create a repository instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createRepository
  @param {String} modFirstName
  @return {BaseRepository}
   */

  Facade.prototype.createRepository = function() {
    var modFirstName, params;
    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(modFirstName, 'repository', params, this);
  };


  /**
  create a service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service
  
  @method createService
  @param {String} modFirstName
  @return {BaseService}
   */

  Facade.prototype.createService = function() {
    var modFirstName, params;
    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.__create(modFirstName, 'service', params, this);
  };

  Facade.prototype.__create = function(modFirstName, type, params, root) {
    var Class, ClassWithConstructor, modFullName;
    modFullName = type ? modFirstName + '-' + type : modFirstName;
    Class = ClassWithConstructor = this.require(modFullName);
    while (ClassWithConstructor.length === 0 && ClassWithConstructor !== Object) {
      ClassWithConstructor = Util.getProto(ClassWithConstructor.prototype).constructor;
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
  @param {String} firstName
  @param {Object} [options]
  @param {Object} [options.noParent] if true, stop requiring parent class
  @return {BaseRepository}
   */

  Facade.prototype.createPreferredRepository = function() {
    var firstName, options, params;
    firstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    return this.createPreferred(firstName, 'repository', options, params, this);
  };


  /**
  create a preferred factory instance
  3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredFactory
  @param {String} firstName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseFactory}
   */

  Facade.prototype.createPreferredFactory = function() {
    var firstName, options, params;
    firstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    if (options.noParent == null) {
      options.noParent = true;
    }
    return this.createPreferred(firstName, 'factory', options, params, this);
  };


  /**
  create a preferred service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredService
  @param {String} firstName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseService}
   */

  Facade.prototype.createPreferredService = function() {
    var firstName, options, params;
    firstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    if (options.noParent == null) {
      options.noParent = true;
    }
    return this.createPreferred(firstName, 'service', options, params, this);
  };


  /**
  create a preferred factory|repository|service instance
  
  @method createPreferred
  @private
  @param {String} modFirstName
  @param {String} type factory|repository|service
  @param {Object} [options]
  @param {Object} [params] params pass to constructor of Repository, Factory or Service
  @param {RootInterface} root
  @return {BaseFactory}
   */

  Facade.prototype.createPreferred = function(modFirstName, type, options, params, root) {
    var ParentClass, i, len, modFullName, originalFirstName, ref;
    if (options == null) {
      options = {};
    }
    originalFirstName = modFirstName;
    ref = this.getPreferredNames(modFirstName, type);
    for (i = 0, len = ref.length; i < len; i++) {
      modFullName = ref[i];
      if (this.hasClass(modFullName)) {
        return this.__create(modFullName, null, params, root);
      }
    }
    if (!options.noParent) {
      ParentClass = this.require(modFirstName).getParent();
      if (ParentClass.className) {
        return this.createPreferred(ParentClass.getName(), type, options, params, root);
      }
    }
    throw this.error("preferred" + type + "NotFound", "preferred " + type + " of '" + originalFirstName + "' is not found");
  };


  /**
  @method getPreferredNames
  @private
  @param {String} modFirstName
  @param {String} type repository|factory|service
  @return {String} modFullName
   */

  Facade.prototype.getPreferredNames = function(modFirstName, type) {
    var names, specific;
    specific = this.preferred[type][modFirstName];
    names = [this.preferred.module, this.moduleName(modFirstName), 'core'].filter(function(v) {
      return v;
    }).map((function(_this) {
      return function(moduleName) {
        return _this.getModule(moduleName).normalizeName(modFirstName + '-' + type);
      };
    })(this));
    if (specific) {
      names.unshift(specific);
    }
    return names;
  };


  /**
  read a file and returns class
  
  @method require
  @private
  @param {String} modFullName
  @return {Function}
   */

  Facade.prototype.require = function(modFullName_o) {
    var fullName, klass, mod, modFullName, moduleName;
    modFullName = this.getModule().normalizeName(modFullName_o);
    if (this.classes[modFullName] != null) {
      return this.classes[modFullName];
    }
    moduleName = this.moduleName(modFullName);
    fullName = this.fullName(modFullName);
    if (!this.nonExistingClassNames[modFullName]) {
      mod = this.getModule(moduleName);
      if (mod == null) {
        throw this.error('moduleNotFound', "module '" + moduleName + "' is not found (requiring '" + fullName + "')");
      }
      klass = mod.requireOwn(fullName);
    }
    if (klass == null) {
      this.nonExistingClassNames[modFullName] = true;
      modFullName = fullName;
      klass = this.getModule().requireOwn(fullName);
    }
    if (klass == null) {
      this.nonExistingClassNames[fullName] = true;
      throw this.error('modelNotFound', "model '" + modFullName_o + "' is not found");
    }
    this.nonExistingClassNames[modFullName] = false;
    return this.addClass(modFullName, klass);
  };


  /**
  @method getModule
  @param {String} moduleName
  @return {BaseModule}
   */

  Facade.prototype.getModule = function(moduleName) {
    if (moduleName == null) {
      moduleName = 'core';
    }
    return this.modules[moduleName];
  };


  /**
  get moduleName from modFullName
  @method moduleName
  @private
  @param {String} modFullName
  @return {String}
   */

  Facade.prototype.moduleName = function(modFullName) {
    if (modFullName.match('/')) {
      return modFullName.split('/')[0];
    } else {
      return 'core';
    }
  };


  /**
  get fullName from modFullName
  @method fullName
  @private
  @param {String} modFullName
  @return {String}
   */

  Facade.prototype.fullName = function(modFullName) {
    if (modFullName.match('/')) {
      return modFullName.split('/')[1];
    } else {
      return modFullName;
    }
  };


  /**
  Serialize the given object containing model information
  
  @method serialize
  @param {any} val
  @return {String}
   */

  Facade.prototype.serialize = function(val) {
    return Util.serialize(val);
  };


  /**
  Deserializes serialized string
  
  @method deserialize
  @param {String} str
  @return {any}
   */

  Facade.prototype.deserialize = function(str) {
    return Util.deserialize(str, this);
  };


  /**
  check existence of the class of the given name
  
  @method hasClass
  @param {String} modFullName
  @return {Function}
   */

  Facade.prototype.hasClass = function(modFullName) {
    var e, error;
    modFullName = this.getModule().normalizeName(modFullName);
    if (this.nonExistingClassNames[modFullName]) {
      return false;
    }
    try {
      this.require(modFullName);
      return true;
    } catch (error) {
      e = error;
      return false;
    }
  };


  /**
  add class to facade.
  the class is acquired by @require(modFullName)
  
  @method addClass
  @private
  @param {String} modFullName
  @param {Function} klass
  @return {Function}
   */

  Facade.prototype.addClass = function(modFullName, klass) {
    modFullName = this.getModule().normalizeName(modFullName);
    klass.className = modFullName;
    klass.moduleName = this.moduleName(modFullName);
    delete this.nonExistingClassNames[modFullName];
    return this.classes[modFullName] = klass;
  };


  /**
  Get ModelProps by firstName.
  ModelProps summarizes properties of this class
  
  @method getModelProps
  @param {String} modFullName
  @return {ModelProps}
   */

  Facade.prototype.getModelProps = function(modFullName) {
    var Model;
    if (this.modelProps[modFullName] == null) {
      Model = this.getModel(modFullName);
      this.modelProps[modFullName] = new ModelProps(modFullName, Model.properties, this.getModule(this.moduleName(modFullName)));
    }
    return this.modelProps[modFullName];
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
  @param {Array(String)} [options.models=null] model firstNames to insert. default: all models
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
