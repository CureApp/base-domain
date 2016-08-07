/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(1);


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(2)


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	var Facade, fsNotFound;

	Facade = __webpack_require__(3);

	fsNotFound = function() {
	  throw new Error("module 'fs' is not defined in Browsers.");
	};

	Facade.fs = {
	  existsSync: fsNotFound,
	  readFileSync: fsNotFound,
	  writeFileSync: fsNotFound
	};

	Facade.requireFile = function(file) {
	  throw new Error("requireFile is suppressed in non-node environment. file: " + file);
	};

	Facade.requireJSON = function(file) {
	  throw new Error("requireJSON is suppressed in non-node environment. file: " + file);
	};

	Facade.csvParse = null;

	module.exports = Facade;


/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseModel, BaseModule, CoreModule, Facade, GeneralFactory, MasterDataResource, ModelProps, Util,
	  slice = [].slice;

	Util = __webpack_require__(4);

	GeneralFactory = __webpack_require__(14);

	MasterDataResource = __webpack_require__(27);

	ModelProps = __webpack_require__(22);

	BaseModel = __webpack_require__(18);

	BaseModule = __webpack_require__(33);

	CoreModule = __webpack_require__(34);


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
	  
	  @deprecated just use this.facade
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
	      facade: {
	        value: this
	      },
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
	    var core, factories, factoryName, klass, klassName, klasses, masterData, modelName, moduleName, modules, ref, ref1;
	    masterData = packed.masterData, core = packed.core, modules = packed.modules, factories = packed.factories;
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
	    ref1 = factories != null ? factories : {};
	    for (modelName in ref1) {
	      factoryName = ref1[modelName];
	      if (factoryName == null) {
	        this.nonExistingClassNames[modelName + '-factory'] = true;
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
	  Create instance of given Class.
	  
	  @method create
	  @param {Function|Class} Class
	  @return {Base}
	   */

	  Facade.prototype.create = function() {
	    var Class, ClassWithConstructor, e, error, params;
	    Class = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
	    if (Class.prototype instanceof BaseModel) {
	      try {
	        return this.createModel.apply(this, [Class.className].concat(slice.call(params)));
	      } catch (error) {
	        e = error;
	        throw this.error(e.reason, e.message);
	      }
	    }
	    ClassWithConstructor = Class;
	    while (ClassWithConstructor.length === 0 && ClassWithConstructor !== Object) {
	      ClassWithConstructor = Util.getProto(ClassWithConstructor.prototype).constructor;
	    }
	    while (params.length < ClassWithConstructor.length - 1) {
	      params.push(void 0);
	    }
	    switch (params.length) {
	      case 0:
	        return new Class(this);
	      case 1:
	        return new Class(params[0], this);
	      case 2:
	        return new Class(params[0], params[1], this);
	      case 3:
	        return new Class(params[0], params[1], params[2], this);
	      case 4:
	        return new Class(params[0], params[1], params[2], params[3], this);
	      case 5:
	        return new Class(params[0], params[1], params[2], params[3], params[4], this);
	      case 6:
	        return new Class(params[0], params[1], params[2], params[3], params[4], params[5], this);
	      default:
	        return (function(func, args, ctor) {
	          ctor.prototype = func.prototype;
	          var child = new ctor, result = func.apply(child, args);
	          return Object(result) === result ? result : child;
	        })(Class, slice.call(params).concat([this]), function(){});
	    }
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
	    switch (params.length) {
	      case 0:
	        return new Class(root != null ? root : this);
	      case 1:
	        return new Class(params[0], root != null ? root : this);
	      case 2:
	        return new Class(params[0], params[1], root != null ? root : this);
	      case 3:
	        return new Class(params[0], params[1], params[2], root != null ? root : this);
	      case 4:
	        return new Class(params[0], params[1], params[2], params[3], root != null ? root : this);
	      case 5:
	        return new Class(params[0], params[1], params[2], params[3], params[4], root != null ? root : this);
	      case 6:
	        return new Class(params[0], params[1], params[2], params[3], params[4], params[5], root != null ? root : this);
	      default:
	        return (function(func, args, ctor) {
	          ctor.prototype = func.prototype;
	          var child = new ctor, result = func.apply(child, args);
	          return Object(result) === result ? result : child;
	        })(Class, slice.call(params).concat([root != null ? root : this]), function(){});
	    }
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
	    Fixture = __webpack_require__(35);
	    fixture = new Fixture(this, options);
	    return fixture.insert(options.models);
	  };

	  Facade.Base = __webpack_require__(20);

	  Facade.BaseModel = __webpack_require__(18);

	  Facade.BaseService = __webpack_require__(36);

	  Facade.ValueObject = __webpack_require__(17);

	  Facade.Entity = __webpack_require__(37);

	  Facade.AggregateRoot = __webpack_require__(38);

	  Facade.Collection = __webpack_require__(16);

	  Facade.BaseList = __webpack_require__(15);

	  Facade.BaseDict = __webpack_require__(26);

	  Facade.BaseFactory = __webpack_require__(39);

	  Facade.BaseRepository = __webpack_require__(40);

	  Facade.BaseSyncRepository = __webpack_require__(41);

	  Facade.BaseAsyncRepository = __webpack_require__(42);

	  Facade.LocalRepository = __webpack_require__(43);

	  Facade.MasterRepository = __webpack_require__(44);

	  Facade.DomainError = __webpack_require__(21);

	  Facade.GeneralFactory = __webpack_require__(14);

	  return Facade;

	})();

	module.exports = Facade;


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var Util, clone, deepEqual;

	deepEqual = __webpack_require__(5);

	clone = __webpack_require__(13);


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


/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(6);


/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	/*!
	 * deep-eql
	 * Copyright(c) 2013 Jake Luer <jake@alogicalparadox.com>
	 * MIT Licensed
	 */

	/*!
	 * Module dependencies
	 */

	var type = __webpack_require__(7);

	/*!
	 * Buffer.isBuffer browser shim
	 */

	var Buffer;
	try { Buffer = __webpack_require__(9).Buffer; }
	catch(ex) {
	  Buffer = {};
	  Buffer.isBuffer = function() { return false; }
	}

	/*!
	 * Primary Export
	 */

	module.exports = deepEqual;

	/**
	 * Assert super-strict (egal) equality between
	 * two objects of any type.
	 *
	 * @param {Mixed} a
	 * @param {Mixed} b
	 * @param {Array} memoised (optional)
	 * @return {Boolean} equal match
	 */

	function deepEqual(a, b, m) {
	  if (sameValue(a, b)) {
	    return true;
	  } else if ('date' === type(a)) {
	    return dateEqual(a, b);
	  } else if ('regexp' === type(a)) {
	    return regexpEqual(a, b);
	  } else if (Buffer.isBuffer(a)) {
	    return bufferEqual(a, b);
	  } else if ('arguments' === type(a)) {
	    return argumentsEqual(a, b, m);
	  } else if (!typeEqual(a, b)) {
	    return false;
	  } else if (('object' !== type(a) && 'object' !== type(b))
	  && ('array' !== type(a) && 'array' !== type(b))) {
	    return sameValue(a, b);
	  } else {
	    return objectEqual(a, b, m);
	  }
	}

	/*!
	 * Strict (egal) equality test. Ensures that NaN always
	 * equals NaN and `-0` does not equal `+0`.
	 *
	 * @param {Mixed} a
	 * @param {Mixed} b
	 * @return {Boolean} equal match
	 */

	function sameValue(a, b) {
	  if (a === b) return a !== 0 || 1 / a === 1 / b;
	  return a !== a && b !== b;
	}

	/*!
	 * Compare the types of two given objects and
	 * return if they are equal. Note that an Array
	 * has a type of `array` (not `object`) and arguments
	 * have a type of `arguments` (not `array`/`object`).
	 *
	 * @param {Mixed} a
	 * @param {Mixed} b
	 * @return {Boolean} result
	 */

	function typeEqual(a, b) {
	  return type(a) === type(b);
	}

	/*!
	 * Compare two Date objects by asserting that
	 * the time values are equal using `saveValue`.
	 *
	 * @param {Date} a
	 * @param {Date} b
	 * @return {Boolean} result
	 */

	function dateEqual(a, b) {
	  if ('date' !== type(b)) return false;
	  return sameValue(a.getTime(), b.getTime());
	}

	/*!
	 * Compare two regular expressions by converting them
	 * to string and checking for `sameValue`.
	 *
	 * @param {RegExp} a
	 * @param {RegExp} b
	 * @return {Boolean} result
	 */

	function regexpEqual(a, b) {
	  if ('regexp' !== type(b)) return false;
	  return sameValue(a.toString(), b.toString());
	}

	/*!
	 * Assert deep equality of two `arguments` objects.
	 * Unfortunately, these must be sliced to arrays
	 * prior to test to ensure no bad behavior.
	 *
	 * @param {Arguments} a
	 * @param {Arguments} b
	 * @param {Array} memoize (optional)
	 * @return {Boolean} result
	 */

	function argumentsEqual(a, b, m) {
	  if ('arguments' !== type(b)) return false;
	  a = [].slice.call(a);
	  b = [].slice.call(b);
	  return deepEqual(a, b, m);
	}

	/*!
	 * Get enumerable properties of a given object.
	 *
	 * @param {Object} a
	 * @return {Array} property names
	 */

	function enumerable(a) {
	  var res = [];
	  for (var key in a) res.push(key);
	  return res;
	}

	/*!
	 * Simple equality for flat iterable objects
	 * such as Arrays or Node.js buffers.
	 *
	 * @param {Iterable} a
	 * @param {Iterable} b
	 * @return {Boolean} result
	 */

	function iterableEqual(a, b) {
	  if (a.length !==  b.length) return false;

	  var i = 0;
	  var match = true;

	  for (; i < a.length; i++) {
	    if (a[i] !== b[i]) {
	      match = false;
	      break;
	    }
	  }

	  return match;
	}

	/*!
	 * Extension to `iterableEqual` specifically
	 * for Node.js Buffers.
	 *
	 * @param {Buffer} a
	 * @param {Mixed} b
	 * @return {Boolean} result
	 */

	function bufferEqual(a, b) {
	  if (!Buffer.isBuffer(b)) return false;
	  return iterableEqual(a, b);
	}

	/*!
	 * Block for `objectEqual` ensuring non-existing
	 * values don't get in.
	 *
	 * @param {Mixed} object
	 * @return {Boolean} result
	 */

	function isValue(a) {
	  return a !== null && a !== undefined;
	}

	/*!
	 * Recursively check the equality of two objects.
	 * Once basic sameness has been established it will
	 * defer to `deepEqual` for each enumerable key
	 * in the object.
	 *
	 * @param {Mixed} a
	 * @param {Mixed} b
	 * @return {Boolean} result
	 */

	function objectEqual(a, b, m) {
	  if (!isValue(a) || !isValue(b)) {
	    return false;
	  }

	  if (a.prototype !== b.prototype) {
	    return false;
	  }

	  var i;
	  if (m) {
	    for (i = 0; i < m.length; i++) {
	      if ((m[i][0] === a && m[i][1] === b)
	      ||  (m[i][0] === b && m[i][1] === a)) {
	        return true;
	      }
	    }
	  } else {
	    m = [];
	  }

	  try {
	    var ka = enumerable(a);
	    var kb = enumerable(b);
	  } catch (ex) {
	    return false;
	  }

	  ka.sort();
	  kb.sort();

	  if (!iterableEqual(ka, kb)) {
	    return false;
	  }

	  m.push([ a, b ]);

	  var key;
	  for (i = ka.length - 1; i >= 0; i--) {
	    key = ka[i];
	    if (!deepEqual(a[key], b[key], m)) {
	      return false;
	    }
	  }

	  return true;
	}


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(8);


/***/ },
/* 8 */
/***/ function(module, exports) {

	/*!
	 * type-detect
	 * Copyright(c) 2013 jake luer <jake@alogicalparadox.com>
	 * MIT Licensed
	 */

	/*!
	 * Primary Exports
	 */

	var exports = module.exports = getType;

	/*!
	 * Detectable javascript natives
	 */

	var natives = {
	    '[object Array]': 'array'
	  , '[object RegExp]': 'regexp'
	  , '[object Function]': 'function'
	  , '[object Arguments]': 'arguments'
	  , '[object Date]': 'date'
	};

	/**
	 * ### typeOf (obj)
	 *
	 * Use several different techniques to determine
	 * the type of object being tested.
	 *
	 *
	 * @param {Mixed} object
	 * @return {String} object type
	 * @api public
	 */

	function getType (obj) {
	  var str = Object.prototype.toString.call(obj);
	  if (natives[str]) return natives[str];
	  if (obj === null) return 'null';
	  if (obj === undefined) return 'undefined';
	  if (obj === Object(obj)) return 'object';
	  return typeof obj;
	}

	exports.Library = Library;

	/**
	 * ### Library
	 *
	 * Create a repository for custom type detection.
	 *
	 * ```js
	 * var lib = new type.Library;
	 * ```
	 *
	 */

	function Library () {
	  this.tests = {};
	}

	/**
	 * #### .of (obj)
	 *
	 * Expose replacement `typeof` detection to the library.
	 *
	 * ```js
	 * if ('string' === lib.of('hello world')) {
	 *   // ...
	 * }
	 * ```
	 *
	 * @param {Mixed} object to test
	 * @return {String} type
	 */

	Library.prototype.of = getType;

	/**
	 * #### .define (type, test)
	 *
	 * Add a test to for the `.test()` assertion.
	 *
	 * Can be defined as a regular expression:
	 *
	 * ```js
	 * lib.define('int', /^[0-9]+$/);
	 * ```
	 *
	 * ... or as a function:
	 *
	 * ```js
	 * lib.define('bln', function (obj) {
	 *   if ('boolean' === lib.of(obj)) return true;
	 *   var blns = [ 'yes', 'no', 'true', 'false', 1, 0 ];
	 *   if ('string' === lib.of(obj)) obj = obj.toLowerCase();
	 *   return !! ~blns.indexOf(obj);
	 * });
	 * ```
	 *
	 * @param {String} type
	 * @param {RegExp|Function} test
	 * @api public
	 */

	Library.prototype.define = function (type, test) {
	  if (arguments.length === 1) return this.tests[type];
	  this.tests[type] = test;
	  return this;
	};

	/**
	 * #### .test (obj, test)
	 *
	 * Assert that an object is of type. Will first
	 * check natives, and if that does not pass it will
	 * use the user defined custom tests.
	 *
	 * ```js
	 * assert(lib.test('1', 'int'));
	 * assert(lib.test('yes', 'bln'));
	 * ```
	 *
	 * @param {Mixed} object
	 * @param {String} type
	 * @return {Boolean} result
	 * @api public
	 */

	Library.prototype.test = function (obj, type) {
	  if (type === getType(obj)) return true;
	  var test = this.tests[type];

	  if (test && 'regexp' === getType(test)) {
	    return test.test(obj);
	  } else if (test && 'function' === getType(test)) {
	    return test(obj);
	  } else {
	    throw new ReferenceError('Type test "' + type + '" not defined or invalid.');
	  }
	};


/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(Buffer, global) {/*!
	 * The buffer module from node.js, for the browser.
	 *
	 * @author   Feross Aboukhadijeh <feross@feross.org> <http://feross.org>
	 * @license  MIT
	 */
	/* eslint-disable no-proto */

	'use strict'

	var base64 = __webpack_require__(10)
	var ieee754 = __webpack_require__(11)
	var isArray = __webpack_require__(12)

	exports.Buffer = Buffer
	exports.SlowBuffer = SlowBuffer
	exports.INSPECT_MAX_BYTES = 50
	Buffer.poolSize = 8192 // not used by this implementation

	var rootParent = {}

	/**
	 * If `Buffer.TYPED_ARRAY_SUPPORT`:
	 *   === true    Use Uint8Array implementation (fastest)
	 *   === false   Use Object implementation (most compatible, even IE6)
	 *
	 * Browsers that support typed arrays are IE 10+, Firefox 4+, Chrome 7+, Safari 5.1+,
	 * Opera 11.6+, iOS 4.2+.
	 *
	 * Due to various browser bugs, sometimes the Object implementation will be used even
	 * when the browser supports typed arrays.
	 *
	 * Note:
	 *
	 *   - Firefox 4-29 lacks support for adding new properties to `Uint8Array` instances,
	 *     See: https://bugzilla.mozilla.org/show_bug.cgi?id=695438.
	 *
	 *   - Safari 5-7 lacks support for changing the `Object.prototype.constructor` property
	 *     on objects.
	 *
	 *   - Chrome 9-10 is missing the `TypedArray.prototype.subarray` function.
	 *
	 *   - IE10 has a broken `TypedArray.prototype.subarray` function which returns arrays of
	 *     incorrect length in some situations.

	 * We detect these buggy browsers and set `Buffer.TYPED_ARRAY_SUPPORT` to `false` so they
	 * get the Object implementation, which is slower but behaves correctly.
	 */
	Buffer.TYPED_ARRAY_SUPPORT = global.TYPED_ARRAY_SUPPORT !== undefined
	  ? global.TYPED_ARRAY_SUPPORT
	  : typedArraySupport()

	function typedArraySupport () {
	  function Bar () {}
	  try {
	    var arr = new Uint8Array(1)
	    arr.foo = function () { return 42 }
	    arr.constructor = Bar
	    return arr.foo() === 42 && // typed array instances can be augmented
	        arr.constructor === Bar && // constructor can be set
	        typeof arr.subarray === 'function' && // chrome 9-10 lack `subarray`
	        arr.subarray(1, 1).byteLength === 0 // ie10 has broken `subarray`
	  } catch (e) {
	    return false
	  }
	}

	function kMaxLength () {
	  return Buffer.TYPED_ARRAY_SUPPORT
	    ? 0x7fffffff
	    : 0x3fffffff
	}

	/**
	 * Class: Buffer
	 * =============
	 *
	 * The Buffer constructor returns instances of `Uint8Array` that are augmented
	 * with function properties for all the node `Buffer` API functions. We use
	 * `Uint8Array` so that square bracket notation works as expected -- it returns
	 * a single octet.
	 *
	 * By augmenting the instances, we can avoid modifying the `Uint8Array`
	 * prototype.
	 */
	function Buffer (arg) {
	  if (!(this instanceof Buffer)) {
	    // Avoid going through an ArgumentsAdaptorTrampoline in the common case.
	    if (arguments.length > 1) return new Buffer(arg, arguments[1])
	    return new Buffer(arg)
	  }

	  if (!Buffer.TYPED_ARRAY_SUPPORT) {
	    this.length = 0
	    this.parent = undefined
	  }

	  // Common case.
	  if (typeof arg === 'number') {
	    return fromNumber(this, arg)
	  }

	  // Slightly less common case.
	  if (typeof arg === 'string') {
	    return fromString(this, arg, arguments.length > 1 ? arguments[1] : 'utf8')
	  }

	  // Unusual.
	  return fromObject(this, arg)
	}

	function fromNumber (that, length) {
	  that = allocate(that, length < 0 ? 0 : checked(length) | 0)
	  if (!Buffer.TYPED_ARRAY_SUPPORT) {
	    for (var i = 0; i < length; i++) {
	      that[i] = 0
	    }
	  }
	  return that
	}

	function fromString (that, string, encoding) {
	  if (typeof encoding !== 'string' || encoding === '') encoding = 'utf8'

	  // Assumption: byteLength() return value is always < kMaxLength.
	  var length = byteLength(string, encoding) | 0
	  that = allocate(that, length)

	  that.write(string, encoding)
	  return that
	}

	function fromObject (that, object) {
	  if (Buffer.isBuffer(object)) return fromBuffer(that, object)

	  if (isArray(object)) return fromArray(that, object)

	  if (object == null) {
	    throw new TypeError('must start with number, buffer, array or string')
	  }

	  if (typeof ArrayBuffer !== 'undefined') {
	    if (object.buffer instanceof ArrayBuffer) {
	      return fromTypedArray(that, object)
	    }
	    if (object instanceof ArrayBuffer) {
	      return fromArrayBuffer(that, object)
	    }
	  }

	  if (object.length) return fromArrayLike(that, object)

	  return fromJsonObject(that, object)
	}

	function fromBuffer (that, buffer) {
	  var length = checked(buffer.length) | 0
	  that = allocate(that, length)
	  buffer.copy(that, 0, 0, length)
	  return that
	}

	function fromArray (that, array) {
	  var length = checked(array.length) | 0
	  that = allocate(that, length)
	  for (var i = 0; i < length; i += 1) {
	    that[i] = array[i] & 255
	  }
	  return that
	}

	// Duplicate of fromArray() to keep fromArray() monomorphic.
	function fromTypedArray (that, array) {
	  var length = checked(array.length) | 0
	  that = allocate(that, length)
	  // Truncating the elements is probably not what people expect from typed
	  // arrays with BYTES_PER_ELEMENT > 1 but it's compatible with the behavior
	  // of the old Buffer constructor.
	  for (var i = 0; i < length; i += 1) {
	    that[i] = array[i] & 255
	  }
	  return that
	}

	function fromArrayBuffer (that, array) {
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    // Return an augmented `Uint8Array` instance, for best performance
	    array.byteLength
	    that = Buffer._augment(new Uint8Array(array))
	  } else {
	    // Fallback: Return an object instance of the Buffer class
	    that = fromTypedArray(that, new Uint8Array(array))
	  }
	  return that
	}

	function fromArrayLike (that, array) {
	  var length = checked(array.length) | 0
	  that = allocate(that, length)
	  for (var i = 0; i < length; i += 1) {
	    that[i] = array[i] & 255
	  }
	  return that
	}

	// Deserialize { type: 'Buffer', data: [1,2,3,...] } into a Buffer object.
	// Returns a zero-length buffer for inputs that don't conform to the spec.
	function fromJsonObject (that, object) {
	  var array
	  var length = 0

	  if (object.type === 'Buffer' && isArray(object.data)) {
	    array = object.data
	    length = checked(array.length) | 0
	  }
	  that = allocate(that, length)

	  for (var i = 0; i < length; i += 1) {
	    that[i] = array[i] & 255
	  }
	  return that
	}

	if (Buffer.TYPED_ARRAY_SUPPORT) {
	  Buffer.prototype.__proto__ = Uint8Array.prototype
	  Buffer.__proto__ = Uint8Array
	} else {
	  // pre-set for values that may exist in the future
	  Buffer.prototype.length = undefined
	  Buffer.prototype.parent = undefined
	}

	function allocate (that, length) {
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    // Return an augmented `Uint8Array` instance, for best performance
	    that = Buffer._augment(new Uint8Array(length))
	    that.__proto__ = Buffer.prototype
	  } else {
	    // Fallback: Return an object instance of the Buffer class
	    that.length = length
	    that._isBuffer = true
	  }

	  var fromPool = length !== 0 && length <= Buffer.poolSize >>> 1
	  if (fromPool) that.parent = rootParent

	  return that
	}

	function checked (length) {
	  // Note: cannot use `length < kMaxLength` here because that fails when
	  // length is NaN (which is otherwise coerced to zero.)
	  if (length >= kMaxLength()) {
	    throw new RangeError('Attempt to allocate Buffer larger than maximum ' +
	                         'size: 0x' + kMaxLength().toString(16) + ' bytes')
	  }
	  return length | 0
	}

	function SlowBuffer (subject, encoding) {
	  if (!(this instanceof SlowBuffer)) return new SlowBuffer(subject, encoding)

	  var buf = new Buffer(subject, encoding)
	  delete buf.parent
	  return buf
	}

	Buffer.isBuffer = function isBuffer (b) {
	  return !!(b != null && b._isBuffer)
	}

	Buffer.compare = function compare (a, b) {
	  if (!Buffer.isBuffer(a) || !Buffer.isBuffer(b)) {
	    throw new TypeError('Arguments must be Buffers')
	  }

	  if (a === b) return 0

	  var x = a.length
	  var y = b.length

	  var i = 0
	  var len = Math.min(x, y)
	  while (i < len) {
	    if (a[i] !== b[i]) break

	    ++i
	  }

	  if (i !== len) {
	    x = a[i]
	    y = b[i]
	  }

	  if (x < y) return -1
	  if (y < x) return 1
	  return 0
	}

	Buffer.isEncoding = function isEncoding (encoding) {
	  switch (String(encoding).toLowerCase()) {
	    case 'hex':
	    case 'utf8':
	    case 'utf-8':
	    case 'ascii':
	    case 'binary':
	    case 'base64':
	    case 'raw':
	    case 'ucs2':
	    case 'ucs-2':
	    case 'utf16le':
	    case 'utf-16le':
	      return true
	    default:
	      return false
	  }
	}

	Buffer.concat = function concat (list, length) {
	  if (!isArray(list)) throw new TypeError('list argument must be an Array of Buffers.')

	  if (list.length === 0) {
	    return new Buffer(0)
	  }

	  var i
	  if (length === undefined) {
	    length = 0
	    for (i = 0; i < list.length; i++) {
	      length += list[i].length
	    }
	  }

	  var buf = new Buffer(length)
	  var pos = 0
	  for (i = 0; i < list.length; i++) {
	    var item = list[i]
	    item.copy(buf, pos)
	    pos += item.length
	  }
	  return buf
	}

	function byteLength (string, encoding) {
	  if (typeof string !== 'string') string = '' + string

	  var len = string.length
	  if (len === 0) return 0

	  // Use a for loop to avoid recursion
	  var loweredCase = false
	  for (;;) {
	    switch (encoding) {
	      case 'ascii':
	      case 'binary':
	      // Deprecated
	      case 'raw':
	      case 'raws':
	        return len
	      case 'utf8':
	      case 'utf-8':
	        return utf8ToBytes(string).length
	      case 'ucs2':
	      case 'ucs-2':
	      case 'utf16le':
	      case 'utf-16le':
	        return len * 2
	      case 'hex':
	        return len >>> 1
	      case 'base64':
	        return base64ToBytes(string).length
	      default:
	        if (loweredCase) return utf8ToBytes(string).length // assume utf8
	        encoding = ('' + encoding).toLowerCase()
	        loweredCase = true
	    }
	  }
	}
	Buffer.byteLength = byteLength

	function slowToString (encoding, start, end) {
	  var loweredCase = false

	  start = start | 0
	  end = end === undefined || end === Infinity ? this.length : end | 0

	  if (!encoding) encoding = 'utf8'
	  if (start < 0) start = 0
	  if (end > this.length) end = this.length
	  if (end <= start) return ''

	  while (true) {
	    switch (encoding) {
	      case 'hex':
	        return hexSlice(this, start, end)

	      case 'utf8':
	      case 'utf-8':
	        return utf8Slice(this, start, end)

	      case 'ascii':
	        return asciiSlice(this, start, end)

	      case 'binary':
	        return binarySlice(this, start, end)

	      case 'base64':
	        return base64Slice(this, start, end)

	      case 'ucs2':
	      case 'ucs-2':
	      case 'utf16le':
	      case 'utf-16le':
	        return utf16leSlice(this, start, end)

	      default:
	        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
	        encoding = (encoding + '').toLowerCase()
	        loweredCase = true
	    }
	  }
	}

	Buffer.prototype.toString = function toString () {
	  var length = this.length | 0
	  if (length === 0) return ''
	  if (arguments.length === 0) return utf8Slice(this, 0, length)
	  return slowToString.apply(this, arguments)
	}

	Buffer.prototype.equals = function equals (b) {
	  if (!Buffer.isBuffer(b)) throw new TypeError('Argument must be a Buffer')
	  if (this === b) return true
	  return Buffer.compare(this, b) === 0
	}

	Buffer.prototype.inspect = function inspect () {
	  var str = ''
	  var max = exports.INSPECT_MAX_BYTES
	  if (this.length > 0) {
	    str = this.toString('hex', 0, max).match(/.{2}/g).join(' ')
	    if (this.length > max) str += ' ... '
	  }
	  return '<Buffer ' + str + '>'
	}

	Buffer.prototype.compare = function compare (b) {
	  if (!Buffer.isBuffer(b)) throw new TypeError('Argument must be a Buffer')
	  if (this === b) return 0
	  return Buffer.compare(this, b)
	}

	Buffer.prototype.indexOf = function indexOf (val, byteOffset) {
	  if (byteOffset > 0x7fffffff) byteOffset = 0x7fffffff
	  else if (byteOffset < -0x80000000) byteOffset = -0x80000000
	  byteOffset >>= 0

	  if (this.length === 0) return -1
	  if (byteOffset >= this.length) return -1

	  // Negative offsets start from the end of the buffer
	  if (byteOffset < 0) byteOffset = Math.max(this.length + byteOffset, 0)

	  if (typeof val === 'string') {
	    if (val.length === 0) return -1 // special case: looking for empty string always fails
	    return String.prototype.indexOf.call(this, val, byteOffset)
	  }
	  if (Buffer.isBuffer(val)) {
	    return arrayIndexOf(this, val, byteOffset)
	  }
	  if (typeof val === 'number') {
	    if (Buffer.TYPED_ARRAY_SUPPORT && Uint8Array.prototype.indexOf === 'function') {
	      return Uint8Array.prototype.indexOf.call(this, val, byteOffset)
	    }
	    return arrayIndexOf(this, [ val ], byteOffset)
	  }

	  function arrayIndexOf (arr, val, byteOffset) {
	    var foundIndex = -1
	    for (var i = 0; byteOffset + i < arr.length; i++) {
	      if (arr[byteOffset + i] === val[foundIndex === -1 ? 0 : i - foundIndex]) {
	        if (foundIndex === -1) foundIndex = i
	        if (i - foundIndex + 1 === val.length) return byteOffset + foundIndex
	      } else {
	        foundIndex = -1
	      }
	    }
	    return -1
	  }

	  throw new TypeError('val must be string, number or Buffer')
	}

	// `get` is deprecated
	Buffer.prototype.get = function get (offset) {
	  console.log('.get() is deprecated. Access using array indexes instead.')
	  return this.readUInt8(offset)
	}

	// `set` is deprecated
	Buffer.prototype.set = function set (v, offset) {
	  console.log('.set() is deprecated. Access using array indexes instead.')
	  return this.writeUInt8(v, offset)
	}

	function hexWrite (buf, string, offset, length) {
	  offset = Number(offset) || 0
	  var remaining = buf.length - offset
	  if (!length) {
	    length = remaining
	  } else {
	    length = Number(length)
	    if (length > remaining) {
	      length = remaining
	    }
	  }

	  // must be an even number of digits
	  var strLen = string.length
	  if (strLen % 2 !== 0) throw new Error('Invalid hex string')

	  if (length > strLen / 2) {
	    length = strLen / 2
	  }
	  for (var i = 0; i < length; i++) {
	    var parsed = parseInt(string.substr(i * 2, 2), 16)
	    if (isNaN(parsed)) throw new Error('Invalid hex string')
	    buf[offset + i] = parsed
	  }
	  return i
	}

	function utf8Write (buf, string, offset, length) {
	  return blitBuffer(utf8ToBytes(string, buf.length - offset), buf, offset, length)
	}

	function asciiWrite (buf, string, offset, length) {
	  return blitBuffer(asciiToBytes(string), buf, offset, length)
	}

	function binaryWrite (buf, string, offset, length) {
	  return asciiWrite(buf, string, offset, length)
	}

	function base64Write (buf, string, offset, length) {
	  return blitBuffer(base64ToBytes(string), buf, offset, length)
	}

	function ucs2Write (buf, string, offset, length) {
	  return blitBuffer(utf16leToBytes(string, buf.length - offset), buf, offset, length)
	}

	Buffer.prototype.write = function write (string, offset, length, encoding) {
	  // Buffer#write(string)
	  if (offset === undefined) {
	    encoding = 'utf8'
	    length = this.length
	    offset = 0
	  // Buffer#write(string, encoding)
	  } else if (length === undefined && typeof offset === 'string') {
	    encoding = offset
	    length = this.length
	    offset = 0
	  // Buffer#write(string, offset[, length][, encoding])
	  } else if (isFinite(offset)) {
	    offset = offset | 0
	    if (isFinite(length)) {
	      length = length | 0
	      if (encoding === undefined) encoding = 'utf8'
	    } else {
	      encoding = length
	      length = undefined
	    }
	  // legacy write(string, encoding, offset, length) - remove in v0.13
	  } else {
	    var swap = encoding
	    encoding = offset
	    offset = length | 0
	    length = swap
	  }

	  var remaining = this.length - offset
	  if (length === undefined || length > remaining) length = remaining

	  if ((string.length > 0 && (length < 0 || offset < 0)) || offset > this.length) {
	    throw new RangeError('attempt to write outside buffer bounds')
	  }

	  if (!encoding) encoding = 'utf8'

	  var loweredCase = false
	  for (;;) {
	    switch (encoding) {
	      case 'hex':
	        return hexWrite(this, string, offset, length)

	      case 'utf8':
	      case 'utf-8':
	        return utf8Write(this, string, offset, length)

	      case 'ascii':
	        return asciiWrite(this, string, offset, length)

	      case 'binary':
	        return binaryWrite(this, string, offset, length)

	      case 'base64':
	        // Warning: maxLength not taken into account in base64Write
	        return base64Write(this, string, offset, length)

	      case 'ucs2':
	      case 'ucs-2':
	      case 'utf16le':
	      case 'utf-16le':
	        return ucs2Write(this, string, offset, length)

	      default:
	        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
	        encoding = ('' + encoding).toLowerCase()
	        loweredCase = true
	    }
	  }
	}

	Buffer.prototype.toJSON = function toJSON () {
	  return {
	    type: 'Buffer',
	    data: Array.prototype.slice.call(this._arr || this, 0)
	  }
	}

	function base64Slice (buf, start, end) {
	  if (start === 0 && end === buf.length) {
	    return base64.fromByteArray(buf)
	  } else {
	    return base64.fromByteArray(buf.slice(start, end))
	  }
	}

	function utf8Slice (buf, start, end) {
	  end = Math.min(buf.length, end)
	  var res = []

	  var i = start
	  while (i < end) {
	    var firstByte = buf[i]
	    var codePoint = null
	    var bytesPerSequence = (firstByte > 0xEF) ? 4
	      : (firstByte > 0xDF) ? 3
	      : (firstByte > 0xBF) ? 2
	      : 1

	    if (i + bytesPerSequence <= end) {
	      var secondByte, thirdByte, fourthByte, tempCodePoint

	      switch (bytesPerSequence) {
	        case 1:
	          if (firstByte < 0x80) {
	            codePoint = firstByte
	          }
	          break
	        case 2:
	          secondByte = buf[i + 1]
	          if ((secondByte & 0xC0) === 0x80) {
	            tempCodePoint = (firstByte & 0x1F) << 0x6 | (secondByte & 0x3F)
	            if (tempCodePoint > 0x7F) {
	              codePoint = tempCodePoint
	            }
	          }
	          break
	        case 3:
	          secondByte = buf[i + 1]
	          thirdByte = buf[i + 2]
	          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80) {
	            tempCodePoint = (firstByte & 0xF) << 0xC | (secondByte & 0x3F) << 0x6 | (thirdByte & 0x3F)
	            if (tempCodePoint > 0x7FF && (tempCodePoint < 0xD800 || tempCodePoint > 0xDFFF)) {
	              codePoint = tempCodePoint
	            }
	          }
	          break
	        case 4:
	          secondByte = buf[i + 1]
	          thirdByte = buf[i + 2]
	          fourthByte = buf[i + 3]
	          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80 && (fourthByte & 0xC0) === 0x80) {
	            tempCodePoint = (firstByte & 0xF) << 0x12 | (secondByte & 0x3F) << 0xC | (thirdByte & 0x3F) << 0x6 | (fourthByte & 0x3F)
	            if (tempCodePoint > 0xFFFF && tempCodePoint < 0x110000) {
	              codePoint = tempCodePoint
	            }
	          }
	      }
	    }

	    if (codePoint === null) {
	      // we did not generate a valid codePoint so insert a
	      // replacement char (U+FFFD) and advance only 1 byte
	      codePoint = 0xFFFD
	      bytesPerSequence = 1
	    } else if (codePoint > 0xFFFF) {
	      // encode to utf16 (surrogate pair dance)
	      codePoint -= 0x10000
	      res.push(codePoint >>> 10 & 0x3FF | 0xD800)
	      codePoint = 0xDC00 | codePoint & 0x3FF
	    }

	    res.push(codePoint)
	    i += bytesPerSequence
	  }

	  return decodeCodePointsArray(res)
	}

	// Based on http://stackoverflow.com/a/22747272/680742, the browser with
	// the lowest limit is Chrome, with 0x10000 args.
	// We go 1 magnitude less, for safety
	var MAX_ARGUMENTS_LENGTH = 0x1000

	function decodeCodePointsArray (codePoints) {
	  var len = codePoints.length
	  if (len <= MAX_ARGUMENTS_LENGTH) {
	    return String.fromCharCode.apply(String, codePoints) // avoid extra slice()
	  }

	  // Decode in chunks to avoid "call stack size exceeded".
	  var res = ''
	  var i = 0
	  while (i < len) {
	    res += String.fromCharCode.apply(
	      String,
	      codePoints.slice(i, i += MAX_ARGUMENTS_LENGTH)
	    )
	  }
	  return res
	}

	function asciiSlice (buf, start, end) {
	  var ret = ''
	  end = Math.min(buf.length, end)

	  for (var i = start; i < end; i++) {
	    ret += String.fromCharCode(buf[i] & 0x7F)
	  }
	  return ret
	}

	function binarySlice (buf, start, end) {
	  var ret = ''
	  end = Math.min(buf.length, end)

	  for (var i = start; i < end; i++) {
	    ret += String.fromCharCode(buf[i])
	  }
	  return ret
	}

	function hexSlice (buf, start, end) {
	  var len = buf.length

	  if (!start || start < 0) start = 0
	  if (!end || end < 0 || end > len) end = len

	  var out = ''
	  for (var i = start; i < end; i++) {
	    out += toHex(buf[i])
	  }
	  return out
	}

	function utf16leSlice (buf, start, end) {
	  var bytes = buf.slice(start, end)
	  var res = ''
	  for (var i = 0; i < bytes.length; i += 2) {
	    res += String.fromCharCode(bytes[i] + bytes[i + 1] * 256)
	  }
	  return res
	}

	Buffer.prototype.slice = function slice (start, end) {
	  var len = this.length
	  start = ~~start
	  end = end === undefined ? len : ~~end

	  if (start < 0) {
	    start += len
	    if (start < 0) start = 0
	  } else if (start > len) {
	    start = len
	  }

	  if (end < 0) {
	    end += len
	    if (end < 0) end = 0
	  } else if (end > len) {
	    end = len
	  }

	  if (end < start) end = start

	  var newBuf
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    newBuf = Buffer._augment(this.subarray(start, end))
	  } else {
	    var sliceLen = end - start
	    newBuf = new Buffer(sliceLen, undefined)
	    for (var i = 0; i < sliceLen; i++) {
	      newBuf[i] = this[i + start]
	    }
	  }

	  if (newBuf.length) newBuf.parent = this.parent || this

	  return newBuf
	}

	/*
	 * Need to make sure that buffer isn't trying to write out of bounds.
	 */
	function checkOffset (offset, ext, length) {
	  if ((offset % 1) !== 0 || offset < 0) throw new RangeError('offset is not uint')
	  if (offset + ext > length) throw new RangeError('Trying to access beyond buffer length')
	}

	Buffer.prototype.readUIntLE = function readUIntLE (offset, byteLength, noAssert) {
	  offset = offset | 0
	  byteLength = byteLength | 0
	  if (!noAssert) checkOffset(offset, byteLength, this.length)

	  var val = this[offset]
	  var mul = 1
	  var i = 0
	  while (++i < byteLength && (mul *= 0x100)) {
	    val += this[offset + i] * mul
	  }

	  return val
	}

	Buffer.prototype.readUIntBE = function readUIntBE (offset, byteLength, noAssert) {
	  offset = offset | 0
	  byteLength = byteLength | 0
	  if (!noAssert) {
	    checkOffset(offset, byteLength, this.length)
	  }

	  var val = this[offset + --byteLength]
	  var mul = 1
	  while (byteLength > 0 && (mul *= 0x100)) {
	    val += this[offset + --byteLength] * mul
	  }

	  return val
	}

	Buffer.prototype.readUInt8 = function readUInt8 (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 1, this.length)
	  return this[offset]
	}

	Buffer.prototype.readUInt16LE = function readUInt16LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length)
	  return this[offset] | (this[offset + 1] << 8)
	}

	Buffer.prototype.readUInt16BE = function readUInt16BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length)
	  return (this[offset] << 8) | this[offset + 1]
	}

	Buffer.prototype.readUInt32LE = function readUInt32LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length)

	  return ((this[offset]) |
	      (this[offset + 1] << 8) |
	      (this[offset + 2] << 16)) +
	      (this[offset + 3] * 0x1000000)
	}

	Buffer.prototype.readUInt32BE = function readUInt32BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length)

	  return (this[offset] * 0x1000000) +
	    ((this[offset + 1] << 16) |
	    (this[offset + 2] << 8) |
	    this[offset + 3])
	}

	Buffer.prototype.readIntLE = function readIntLE (offset, byteLength, noAssert) {
	  offset = offset | 0
	  byteLength = byteLength | 0
	  if (!noAssert) checkOffset(offset, byteLength, this.length)

	  var val = this[offset]
	  var mul = 1
	  var i = 0
	  while (++i < byteLength && (mul *= 0x100)) {
	    val += this[offset + i] * mul
	  }
	  mul *= 0x80

	  if (val >= mul) val -= Math.pow(2, 8 * byteLength)

	  return val
	}

	Buffer.prototype.readIntBE = function readIntBE (offset, byteLength, noAssert) {
	  offset = offset | 0
	  byteLength = byteLength | 0
	  if (!noAssert) checkOffset(offset, byteLength, this.length)

	  var i = byteLength
	  var mul = 1
	  var val = this[offset + --i]
	  while (i > 0 && (mul *= 0x100)) {
	    val += this[offset + --i] * mul
	  }
	  mul *= 0x80

	  if (val >= mul) val -= Math.pow(2, 8 * byteLength)

	  return val
	}

	Buffer.prototype.readInt8 = function readInt8 (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 1, this.length)
	  if (!(this[offset] & 0x80)) return (this[offset])
	  return ((0xff - this[offset] + 1) * -1)
	}

	Buffer.prototype.readInt16LE = function readInt16LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length)
	  var val = this[offset] | (this[offset + 1] << 8)
	  return (val & 0x8000) ? val | 0xFFFF0000 : val
	}

	Buffer.prototype.readInt16BE = function readInt16BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length)
	  var val = this[offset + 1] | (this[offset] << 8)
	  return (val & 0x8000) ? val | 0xFFFF0000 : val
	}

	Buffer.prototype.readInt32LE = function readInt32LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length)

	  return (this[offset]) |
	    (this[offset + 1] << 8) |
	    (this[offset + 2] << 16) |
	    (this[offset + 3] << 24)
	}

	Buffer.prototype.readInt32BE = function readInt32BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length)

	  return (this[offset] << 24) |
	    (this[offset + 1] << 16) |
	    (this[offset + 2] << 8) |
	    (this[offset + 3])
	}

	Buffer.prototype.readFloatLE = function readFloatLE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length)
	  return ieee754.read(this, offset, true, 23, 4)
	}

	Buffer.prototype.readFloatBE = function readFloatBE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length)
	  return ieee754.read(this, offset, false, 23, 4)
	}

	Buffer.prototype.readDoubleLE = function readDoubleLE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 8, this.length)
	  return ieee754.read(this, offset, true, 52, 8)
	}

	Buffer.prototype.readDoubleBE = function readDoubleBE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 8, this.length)
	  return ieee754.read(this, offset, false, 52, 8)
	}

	function checkInt (buf, value, offset, ext, max, min) {
	  if (!Buffer.isBuffer(buf)) throw new TypeError('buffer must be a Buffer instance')
	  if (value > max || value < min) throw new RangeError('value is out of bounds')
	  if (offset + ext > buf.length) throw new RangeError('index out of range')
	}

	Buffer.prototype.writeUIntLE = function writeUIntLE (value, offset, byteLength, noAssert) {
	  value = +value
	  offset = offset | 0
	  byteLength = byteLength | 0
	  if (!noAssert) checkInt(this, value, offset, byteLength, Math.pow(2, 8 * byteLength), 0)

	  var mul = 1
	  var i = 0
	  this[offset] = value & 0xFF
	  while (++i < byteLength && (mul *= 0x100)) {
	    this[offset + i] = (value / mul) & 0xFF
	  }

	  return offset + byteLength
	}

	Buffer.prototype.writeUIntBE = function writeUIntBE (value, offset, byteLength, noAssert) {
	  value = +value
	  offset = offset | 0
	  byteLength = byteLength | 0
	  if (!noAssert) checkInt(this, value, offset, byteLength, Math.pow(2, 8 * byteLength), 0)

	  var i = byteLength - 1
	  var mul = 1
	  this[offset + i] = value & 0xFF
	  while (--i >= 0 && (mul *= 0x100)) {
	    this[offset + i] = (value / mul) & 0xFF
	  }

	  return offset + byteLength
	}

	Buffer.prototype.writeUInt8 = function writeUInt8 (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 1, 0xff, 0)
	  if (!Buffer.TYPED_ARRAY_SUPPORT) value = Math.floor(value)
	  this[offset] = (value & 0xff)
	  return offset + 1
	}

	function objectWriteUInt16 (buf, value, offset, littleEndian) {
	  if (value < 0) value = 0xffff + value + 1
	  for (var i = 0, j = Math.min(buf.length - offset, 2); i < j; i++) {
	    buf[offset + i] = (value & (0xff << (8 * (littleEndian ? i : 1 - i)))) >>>
	      (littleEndian ? i : 1 - i) * 8
	  }
	}

	Buffer.prototype.writeUInt16LE = function writeUInt16LE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value & 0xff)
	    this[offset + 1] = (value >>> 8)
	  } else {
	    objectWriteUInt16(this, value, offset, true)
	  }
	  return offset + 2
	}

	Buffer.prototype.writeUInt16BE = function writeUInt16BE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 8)
	    this[offset + 1] = (value & 0xff)
	  } else {
	    objectWriteUInt16(this, value, offset, false)
	  }
	  return offset + 2
	}

	function objectWriteUInt32 (buf, value, offset, littleEndian) {
	  if (value < 0) value = 0xffffffff + value + 1
	  for (var i = 0, j = Math.min(buf.length - offset, 4); i < j; i++) {
	    buf[offset + i] = (value >>> (littleEndian ? i : 3 - i) * 8) & 0xff
	  }
	}

	Buffer.prototype.writeUInt32LE = function writeUInt32LE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset + 3] = (value >>> 24)
	    this[offset + 2] = (value >>> 16)
	    this[offset + 1] = (value >>> 8)
	    this[offset] = (value & 0xff)
	  } else {
	    objectWriteUInt32(this, value, offset, true)
	  }
	  return offset + 4
	}

	Buffer.prototype.writeUInt32BE = function writeUInt32BE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 24)
	    this[offset + 1] = (value >>> 16)
	    this[offset + 2] = (value >>> 8)
	    this[offset + 3] = (value & 0xff)
	  } else {
	    objectWriteUInt32(this, value, offset, false)
	  }
	  return offset + 4
	}

	Buffer.prototype.writeIntLE = function writeIntLE (value, offset, byteLength, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) {
	    var limit = Math.pow(2, 8 * byteLength - 1)

	    checkInt(this, value, offset, byteLength, limit - 1, -limit)
	  }

	  var i = 0
	  var mul = 1
	  var sub = value < 0 ? 1 : 0
	  this[offset] = value & 0xFF
	  while (++i < byteLength && (mul *= 0x100)) {
	    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
	  }

	  return offset + byteLength
	}

	Buffer.prototype.writeIntBE = function writeIntBE (value, offset, byteLength, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) {
	    var limit = Math.pow(2, 8 * byteLength - 1)

	    checkInt(this, value, offset, byteLength, limit - 1, -limit)
	  }

	  var i = byteLength - 1
	  var mul = 1
	  var sub = value < 0 ? 1 : 0
	  this[offset + i] = value & 0xFF
	  while (--i >= 0 && (mul *= 0x100)) {
	    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF
	  }

	  return offset + byteLength
	}

	Buffer.prototype.writeInt8 = function writeInt8 (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 1, 0x7f, -0x80)
	  if (!Buffer.TYPED_ARRAY_SUPPORT) value = Math.floor(value)
	  if (value < 0) value = 0xff + value + 1
	  this[offset] = (value & 0xff)
	  return offset + 1
	}

	Buffer.prototype.writeInt16LE = function writeInt16LE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value & 0xff)
	    this[offset + 1] = (value >>> 8)
	  } else {
	    objectWriteUInt16(this, value, offset, true)
	  }
	  return offset + 2
	}

	Buffer.prototype.writeInt16BE = function writeInt16BE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -0x8000)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 8)
	    this[offset + 1] = (value & 0xff)
	  } else {
	    objectWriteUInt16(this, value, offset, false)
	  }
	  return offset + 2
	}

	Buffer.prototype.writeInt32LE = function writeInt32LE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value & 0xff)
	    this[offset + 1] = (value >>> 8)
	    this[offset + 2] = (value >>> 16)
	    this[offset + 3] = (value >>> 24)
	  } else {
	    objectWriteUInt32(this, value, offset, true)
	  }
	  return offset + 4
	}

	Buffer.prototype.writeInt32BE = function writeInt32BE (value, offset, noAssert) {
	  value = +value
	  offset = offset | 0
	  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -0x80000000)
	  if (value < 0) value = 0xffffffff + value + 1
	  if (Buffer.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 24)
	    this[offset + 1] = (value >>> 16)
	    this[offset + 2] = (value >>> 8)
	    this[offset + 3] = (value & 0xff)
	  } else {
	    objectWriteUInt32(this, value, offset, false)
	  }
	  return offset + 4
	}

	function checkIEEE754 (buf, value, offset, ext, max, min) {
	  if (value > max || value < min) throw new RangeError('value is out of bounds')
	  if (offset + ext > buf.length) throw new RangeError('index out of range')
	  if (offset < 0) throw new RangeError('index out of range')
	}

	function writeFloat (buf, value, offset, littleEndian, noAssert) {
	  if (!noAssert) {
	    checkIEEE754(buf, value, offset, 4, 3.4028234663852886e+38, -3.4028234663852886e+38)
	  }
	  ieee754.write(buf, value, offset, littleEndian, 23, 4)
	  return offset + 4
	}

	Buffer.prototype.writeFloatLE = function writeFloatLE (value, offset, noAssert) {
	  return writeFloat(this, value, offset, true, noAssert)
	}

	Buffer.prototype.writeFloatBE = function writeFloatBE (value, offset, noAssert) {
	  return writeFloat(this, value, offset, false, noAssert)
	}

	function writeDouble (buf, value, offset, littleEndian, noAssert) {
	  if (!noAssert) {
	    checkIEEE754(buf, value, offset, 8, 1.7976931348623157E+308, -1.7976931348623157E+308)
	  }
	  ieee754.write(buf, value, offset, littleEndian, 52, 8)
	  return offset + 8
	}

	Buffer.prototype.writeDoubleLE = function writeDoubleLE (value, offset, noAssert) {
	  return writeDouble(this, value, offset, true, noAssert)
	}

	Buffer.prototype.writeDoubleBE = function writeDoubleBE (value, offset, noAssert) {
	  return writeDouble(this, value, offset, false, noAssert)
	}

	// copy(targetBuffer, targetStart=0, sourceStart=0, sourceEnd=buffer.length)
	Buffer.prototype.copy = function copy (target, targetStart, start, end) {
	  if (!start) start = 0
	  if (!end && end !== 0) end = this.length
	  if (targetStart >= target.length) targetStart = target.length
	  if (!targetStart) targetStart = 0
	  if (end > 0 && end < start) end = start

	  // Copy 0 bytes; we're done
	  if (end === start) return 0
	  if (target.length === 0 || this.length === 0) return 0

	  // Fatal error conditions
	  if (targetStart < 0) {
	    throw new RangeError('targetStart out of bounds')
	  }
	  if (start < 0 || start >= this.length) throw new RangeError('sourceStart out of bounds')
	  if (end < 0) throw new RangeError('sourceEnd out of bounds')

	  // Are we oob?
	  if (end > this.length) end = this.length
	  if (target.length - targetStart < end - start) {
	    end = target.length - targetStart + start
	  }

	  var len = end - start
	  var i

	  if (this === target && start < targetStart && targetStart < end) {
	    // descending copy from end
	    for (i = len - 1; i >= 0; i--) {
	      target[i + targetStart] = this[i + start]
	    }
	  } else if (len < 1000 || !Buffer.TYPED_ARRAY_SUPPORT) {
	    // ascending copy from start
	    for (i = 0; i < len; i++) {
	      target[i + targetStart] = this[i + start]
	    }
	  } else {
	    target._set(this.subarray(start, start + len), targetStart)
	  }

	  return len
	}

	// fill(value, start=0, end=buffer.length)
	Buffer.prototype.fill = function fill (value, start, end) {
	  if (!value) value = 0
	  if (!start) start = 0
	  if (!end) end = this.length

	  if (end < start) throw new RangeError('end < start')

	  // Fill 0 bytes; we're done
	  if (end === start) return
	  if (this.length === 0) return

	  if (start < 0 || start >= this.length) throw new RangeError('start out of bounds')
	  if (end < 0 || end > this.length) throw new RangeError('end out of bounds')

	  var i
	  if (typeof value === 'number') {
	    for (i = start; i < end; i++) {
	      this[i] = value
	    }
	  } else {
	    var bytes = utf8ToBytes(value.toString())
	    var len = bytes.length
	    for (i = start; i < end; i++) {
	      this[i] = bytes[i % len]
	    }
	  }

	  return this
	}

	/**
	 * Creates a new `ArrayBuffer` with the *copied* memory of the buffer instance.
	 * Added in Node 0.12. Only available in browsers that support ArrayBuffer.
	 */
	Buffer.prototype.toArrayBuffer = function toArrayBuffer () {
	  if (typeof Uint8Array !== 'undefined') {
	    if (Buffer.TYPED_ARRAY_SUPPORT) {
	      return (new Buffer(this)).buffer
	    } else {
	      var buf = new Uint8Array(this.length)
	      for (var i = 0, len = buf.length; i < len; i += 1) {
	        buf[i] = this[i]
	      }
	      return buf.buffer
	    }
	  } else {
	    throw new TypeError('Buffer.toArrayBuffer not supported in this browser')
	  }
	}

	// HELPER FUNCTIONS
	// ================

	var BP = Buffer.prototype

	/**
	 * Augment a Uint8Array *instance* (not the Uint8Array class!) with Buffer methods
	 */
	Buffer._augment = function _augment (arr) {
	  arr.constructor = Buffer
	  arr._isBuffer = true

	  // save reference to original Uint8Array set method before overwriting
	  arr._set = arr.set

	  // deprecated
	  arr.get = BP.get
	  arr.set = BP.set

	  arr.write = BP.write
	  arr.toString = BP.toString
	  arr.toLocaleString = BP.toString
	  arr.toJSON = BP.toJSON
	  arr.equals = BP.equals
	  arr.compare = BP.compare
	  arr.indexOf = BP.indexOf
	  arr.copy = BP.copy
	  arr.slice = BP.slice
	  arr.readUIntLE = BP.readUIntLE
	  arr.readUIntBE = BP.readUIntBE
	  arr.readUInt8 = BP.readUInt8
	  arr.readUInt16LE = BP.readUInt16LE
	  arr.readUInt16BE = BP.readUInt16BE
	  arr.readUInt32LE = BP.readUInt32LE
	  arr.readUInt32BE = BP.readUInt32BE
	  arr.readIntLE = BP.readIntLE
	  arr.readIntBE = BP.readIntBE
	  arr.readInt8 = BP.readInt8
	  arr.readInt16LE = BP.readInt16LE
	  arr.readInt16BE = BP.readInt16BE
	  arr.readInt32LE = BP.readInt32LE
	  arr.readInt32BE = BP.readInt32BE
	  arr.readFloatLE = BP.readFloatLE
	  arr.readFloatBE = BP.readFloatBE
	  arr.readDoubleLE = BP.readDoubleLE
	  arr.readDoubleBE = BP.readDoubleBE
	  arr.writeUInt8 = BP.writeUInt8
	  arr.writeUIntLE = BP.writeUIntLE
	  arr.writeUIntBE = BP.writeUIntBE
	  arr.writeUInt16LE = BP.writeUInt16LE
	  arr.writeUInt16BE = BP.writeUInt16BE
	  arr.writeUInt32LE = BP.writeUInt32LE
	  arr.writeUInt32BE = BP.writeUInt32BE
	  arr.writeIntLE = BP.writeIntLE
	  arr.writeIntBE = BP.writeIntBE
	  arr.writeInt8 = BP.writeInt8
	  arr.writeInt16LE = BP.writeInt16LE
	  arr.writeInt16BE = BP.writeInt16BE
	  arr.writeInt32LE = BP.writeInt32LE
	  arr.writeInt32BE = BP.writeInt32BE
	  arr.writeFloatLE = BP.writeFloatLE
	  arr.writeFloatBE = BP.writeFloatBE
	  arr.writeDoubleLE = BP.writeDoubleLE
	  arr.writeDoubleBE = BP.writeDoubleBE
	  arr.fill = BP.fill
	  arr.inspect = BP.inspect
	  arr.toArrayBuffer = BP.toArrayBuffer

	  return arr
	}

	var INVALID_BASE64_RE = /[^+\/0-9A-Za-z-_]/g

	function base64clean (str) {
	  // Node strips out invalid characters like \n and \t from the string, base64-js does not
	  str = stringtrim(str).replace(INVALID_BASE64_RE, '')
	  // Node converts strings with length < 2 to ''
	  if (str.length < 2) return ''
	  // Node allows for non-padded base64 strings (missing trailing ===), base64-js does not
	  while (str.length % 4 !== 0) {
	    str = str + '='
	  }
	  return str
	}

	function stringtrim (str) {
	  if (str.trim) return str.trim()
	  return str.replace(/^\s+|\s+$/g, '')
	}

	function toHex (n) {
	  if (n < 16) return '0' + n.toString(16)
	  return n.toString(16)
	}

	function utf8ToBytes (string, units) {
	  units = units || Infinity
	  var codePoint
	  var length = string.length
	  var leadSurrogate = null
	  var bytes = []

	  for (var i = 0; i < length; i++) {
	    codePoint = string.charCodeAt(i)

	    // is surrogate component
	    if (codePoint > 0xD7FF && codePoint < 0xE000) {
	      // last char was a lead
	      if (!leadSurrogate) {
	        // no lead yet
	        if (codePoint > 0xDBFF) {
	          // unexpected trail
	          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
	          continue
	        } else if (i + 1 === length) {
	          // unpaired lead
	          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
	          continue
	        }

	        // valid lead
	        leadSurrogate = codePoint

	        continue
	      }

	      // 2 leads in a row
	      if (codePoint < 0xDC00) {
	        if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
	        leadSurrogate = codePoint
	        continue
	      }

	      // valid surrogate pair
	      codePoint = (leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00) + 0x10000
	    } else if (leadSurrogate) {
	      // valid bmp char, but last char was a lead
	      if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD)
	    }

	    leadSurrogate = null

	    // encode utf8
	    if (codePoint < 0x80) {
	      if ((units -= 1) < 0) break
	      bytes.push(codePoint)
	    } else if (codePoint < 0x800) {
	      if ((units -= 2) < 0) break
	      bytes.push(
	        codePoint >> 0x6 | 0xC0,
	        codePoint & 0x3F | 0x80
	      )
	    } else if (codePoint < 0x10000) {
	      if ((units -= 3) < 0) break
	      bytes.push(
	        codePoint >> 0xC | 0xE0,
	        codePoint >> 0x6 & 0x3F | 0x80,
	        codePoint & 0x3F | 0x80
	      )
	    } else if (codePoint < 0x110000) {
	      if ((units -= 4) < 0) break
	      bytes.push(
	        codePoint >> 0x12 | 0xF0,
	        codePoint >> 0xC & 0x3F | 0x80,
	        codePoint >> 0x6 & 0x3F | 0x80,
	        codePoint & 0x3F | 0x80
	      )
	    } else {
	      throw new Error('Invalid code point')
	    }
	  }

	  return bytes
	}

	function asciiToBytes (str) {
	  var byteArray = []
	  for (var i = 0; i < str.length; i++) {
	    // Node's code seems to be doing this and not & 0x7F..
	    byteArray.push(str.charCodeAt(i) & 0xFF)
	  }
	  return byteArray
	}

	function utf16leToBytes (str, units) {
	  var c, hi, lo
	  var byteArray = []
	  for (var i = 0; i < str.length; i++) {
	    if ((units -= 2) < 0) break

	    c = str.charCodeAt(i)
	    hi = c >> 8
	    lo = c % 256
	    byteArray.push(lo)
	    byteArray.push(hi)
	  }

	  return byteArray
	}

	function base64ToBytes (str) {
	  return base64.toByteArray(base64clean(str))
	}

	function blitBuffer (src, dst, offset, length) {
	  for (var i = 0; i < length; i++) {
	    if ((i + offset >= dst.length) || (i >= src.length)) break
	    dst[i + offset] = src[i]
	  }
	  return i
	}

	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(9).Buffer, (function() { return this; }())))

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	var lookup = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

	;(function (exports) {
		'use strict';

	  var Arr = (typeof Uint8Array !== 'undefined')
	    ? Uint8Array
	    : Array

		var PLUS   = '+'.charCodeAt(0)
		var SLASH  = '/'.charCodeAt(0)
		var NUMBER = '0'.charCodeAt(0)
		var LOWER  = 'a'.charCodeAt(0)
		var UPPER  = 'A'.charCodeAt(0)
		var PLUS_URL_SAFE = '-'.charCodeAt(0)
		var SLASH_URL_SAFE = '_'.charCodeAt(0)

		function decode (elt) {
			var code = elt.charCodeAt(0)
			if (code === PLUS ||
			    code === PLUS_URL_SAFE)
				return 62 // '+'
			if (code === SLASH ||
			    code === SLASH_URL_SAFE)
				return 63 // '/'
			if (code < NUMBER)
				return -1 //no match
			if (code < NUMBER + 10)
				return code - NUMBER + 26 + 26
			if (code < UPPER + 26)
				return code - UPPER
			if (code < LOWER + 26)
				return code - LOWER + 26
		}

		function b64ToByteArray (b64) {
			var i, j, l, tmp, placeHolders, arr

			if (b64.length % 4 > 0) {
				throw new Error('Invalid string. Length must be a multiple of 4')
			}

			// the number of equal signs (place holders)
			// if there are two placeholders, than the two characters before it
			// represent one byte
			// if there is only one, then the three characters before it represent 2 bytes
			// this is just a cheap hack to not do indexOf twice
			var len = b64.length
			placeHolders = '=' === b64.charAt(len - 2) ? 2 : '=' === b64.charAt(len - 1) ? 1 : 0

			// base64 is 4/3 + up to two characters of the original data
			arr = new Arr(b64.length * 3 / 4 - placeHolders)

			// if there are placeholders, only get up to the last complete 4 chars
			l = placeHolders > 0 ? b64.length - 4 : b64.length

			var L = 0

			function push (v) {
				arr[L++] = v
			}

			for (i = 0, j = 0; i < l; i += 4, j += 3) {
				tmp = (decode(b64.charAt(i)) << 18) | (decode(b64.charAt(i + 1)) << 12) | (decode(b64.charAt(i + 2)) << 6) | decode(b64.charAt(i + 3))
				push((tmp & 0xFF0000) >> 16)
				push((tmp & 0xFF00) >> 8)
				push(tmp & 0xFF)
			}

			if (placeHolders === 2) {
				tmp = (decode(b64.charAt(i)) << 2) | (decode(b64.charAt(i + 1)) >> 4)
				push(tmp & 0xFF)
			} else if (placeHolders === 1) {
				tmp = (decode(b64.charAt(i)) << 10) | (decode(b64.charAt(i + 1)) << 4) | (decode(b64.charAt(i + 2)) >> 2)
				push((tmp >> 8) & 0xFF)
				push(tmp & 0xFF)
			}

			return arr
		}

		function uint8ToBase64 (uint8) {
			var i,
				extraBytes = uint8.length % 3, // if we have 1 byte left, pad 2 bytes
				output = "",
				temp, length

			function encode (num) {
				return lookup.charAt(num)
			}

			function tripletToBase64 (num) {
				return encode(num >> 18 & 0x3F) + encode(num >> 12 & 0x3F) + encode(num >> 6 & 0x3F) + encode(num & 0x3F)
			}

			// go through the array every three bytes, we'll deal with trailing stuff later
			for (i = 0, length = uint8.length - extraBytes; i < length; i += 3) {
				temp = (uint8[i] << 16) + (uint8[i + 1] << 8) + (uint8[i + 2])
				output += tripletToBase64(temp)
			}

			// pad the end with zeros, but make sure to not forget the extra bytes
			switch (extraBytes) {
				case 1:
					temp = uint8[uint8.length - 1]
					output += encode(temp >> 2)
					output += encode((temp << 4) & 0x3F)
					output += '=='
					break
				case 2:
					temp = (uint8[uint8.length - 2] << 8) + (uint8[uint8.length - 1])
					output += encode(temp >> 10)
					output += encode((temp >> 4) & 0x3F)
					output += encode((temp << 2) & 0x3F)
					output += '='
					break
			}

			return output
		}

		exports.toByteArray = b64ToByteArray
		exports.fromByteArray = uint8ToBase64
	}( false ? (this.base64js = {}) : exports))


/***/ },
/* 11 */
/***/ function(module, exports) {

	exports.read = function (buffer, offset, isLE, mLen, nBytes) {
	  var e, m
	  var eLen = nBytes * 8 - mLen - 1
	  var eMax = (1 << eLen) - 1
	  var eBias = eMax >> 1
	  var nBits = -7
	  var i = isLE ? (nBytes - 1) : 0
	  var d = isLE ? -1 : 1
	  var s = buffer[offset + i]

	  i += d

	  e = s & ((1 << (-nBits)) - 1)
	  s >>= (-nBits)
	  nBits += eLen
	  for (; nBits > 0; e = e * 256 + buffer[offset + i], i += d, nBits -= 8) {}

	  m = e & ((1 << (-nBits)) - 1)
	  e >>= (-nBits)
	  nBits += mLen
	  for (; nBits > 0; m = m * 256 + buffer[offset + i], i += d, nBits -= 8) {}

	  if (e === 0) {
	    e = 1 - eBias
	  } else if (e === eMax) {
	    return m ? NaN : ((s ? -1 : 1) * Infinity)
	  } else {
	    m = m + Math.pow(2, mLen)
	    e = e - eBias
	  }
	  return (s ? -1 : 1) * m * Math.pow(2, e - mLen)
	}

	exports.write = function (buffer, value, offset, isLE, mLen, nBytes) {
	  var e, m, c
	  var eLen = nBytes * 8 - mLen - 1
	  var eMax = (1 << eLen) - 1
	  var eBias = eMax >> 1
	  var rt = (mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0)
	  var i = isLE ? 0 : (nBytes - 1)
	  var d = isLE ? 1 : -1
	  var s = value < 0 || (value === 0 && 1 / value < 0) ? 1 : 0

	  value = Math.abs(value)

	  if (isNaN(value) || value === Infinity) {
	    m = isNaN(value) ? 1 : 0
	    e = eMax
	  } else {
	    e = Math.floor(Math.log(value) / Math.LN2)
	    if (value * (c = Math.pow(2, -e)) < 1) {
	      e--
	      c *= 2
	    }
	    if (e + eBias >= 1) {
	      value += rt / c
	    } else {
	      value += rt * Math.pow(2, 1 - eBias)
	    }
	    if (value * c >= 2) {
	      e++
	      c /= 2
	    }

	    if (e + eBias >= eMax) {
	      m = 0
	      e = eMax
	    } else if (e + eBias >= 1) {
	      m = (value * c - 1) * Math.pow(2, mLen)
	      e = e + eBias
	    } else {
	      m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen)
	      e = 0
	    }
	  }

	  for (; mLen >= 8; buffer[offset + i] = m & 0xff, i += d, m /= 256, mLen -= 8) {}

	  e = (e << mLen) | m
	  eLen += mLen
	  for (; eLen > 0; buffer[offset + i] = e & 0xff, i += d, e /= 256, eLen -= 8) {}

	  buffer[offset + i - d] |= s * 128
	}


/***/ },
/* 12 */
/***/ function(module, exports) {

	var toString = {}.toString;

	module.exports = Array.isArray || function (arr) {
	  return toString.call(arr) == '[object Array]';
	};


/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(Buffer) {var clone = (function() {
	'use strict';

	/**
	 * Clones (copies) an Object using deep copying.
	 *
	 * This function supports circular references by default, but if you are certain
	 * there are no circular references in your object, you can save some CPU time
	 * by calling clone(obj, false).
	 *
	 * Caution: if `circular` is false and `parent` contains circular references,
	 * your program may enter an infinite loop and crash.
	 *
	 * @param `parent` - the object to be cloned
	 * @param `circular` - set to true if the object to be cloned may contain
	 *    circular references. (optional - true by default)
	 * @param `depth` - set to a number if the object is only to be cloned to
	 *    a particular depth. (optional - defaults to Infinity)
	 * @param `prototype` - sets the prototype to be used when cloning an object.
	 *    (optional - defaults to parent prototype).
	*/
	function clone(parent, circular, depth, prototype) {
	  var filter;
	  if (typeof circular === 'object') {
	    depth = circular.depth;
	    prototype = circular.prototype;
	    filter = circular.filter;
	    circular = circular.circular
	  }
	  // maintain two arrays for circular references, where corresponding parents
	  // and children have the same index
	  var allParents = [];
	  var allChildren = [];

	  var useBuffer = typeof Buffer != 'undefined';

	  if (typeof circular == 'undefined')
	    circular = true;

	  if (typeof depth == 'undefined')
	    depth = Infinity;

	  // recurse this function so we don't reset allParents and allChildren
	  function _clone(parent, depth) {
	    // cloning null always returns null
	    if (parent === null)
	      return null;

	    if (depth == 0)
	      return parent;

	    var child;
	    var proto;
	    if (typeof parent != 'object') {
	      return parent;
	    }

	    if (clone.__isArray(parent)) {
	      child = [];
	    } else if (clone.__isRegExp(parent)) {
	      child = new RegExp(parent.source, __getRegExpFlags(parent));
	      if (parent.lastIndex) child.lastIndex = parent.lastIndex;
	    } else if (clone.__isDate(parent)) {
	      child = new Date(parent.getTime());
	    } else if (useBuffer && Buffer.isBuffer(parent)) {
	      child = new Buffer(parent.length);
	      parent.copy(child);
	      return child;
	    } else {
	      if (typeof prototype == 'undefined') {
	        proto = Object.getPrototypeOf(parent);
	        child = Object.create(proto);
	      }
	      else {
	        child = Object.create(prototype);
	        proto = prototype;
	      }
	    }

	    if (circular) {
	      var index = allParents.indexOf(parent);

	      if (index != -1) {
	        return allChildren[index];
	      }
	      allParents.push(parent);
	      allChildren.push(child);
	    }

	    for (var i in parent) {
	      var attrs;
	      if (proto) {
	        attrs = Object.getOwnPropertyDescriptor(proto, i);
	      }

	      if (attrs && attrs.set == null) {
	        continue;
	      }
	      child[i] = _clone(parent[i], depth - 1);
	    }

	    return child;
	  }

	  return _clone(parent, depth);
	}

	/**
	 * Simple flat clone using prototype, accepts only objects, usefull for property
	 * override on FLAT configuration object (no nested props).
	 *
	 * USE WITH CAUTION! This may not behave as you wish if you do not know how this
	 * works.
	 */
	clone.clonePrototype = function clonePrototype(parent) {
	  if (parent === null)
	    return null;

	  var c = function () {};
	  c.prototype = parent;
	  return new c();
	};

	// private utility functions

	function __objToStr(o) {
	  return Object.prototype.toString.call(o);
	};
	clone.__objToStr = __objToStr;

	function __isDate(o) {
	  return typeof o === 'object' && __objToStr(o) === '[object Date]';
	};
	clone.__isDate = __isDate;

	function __isArray(o) {
	  return typeof o === 'object' && __objToStr(o) === '[object Array]';
	};
	clone.__isArray = __isArray;

	function __isRegExp(o) {
	  return typeof o === 'object' && __objToStr(o) === '[object RegExp]';
	};
	clone.__isRegExp = __isRegExp;

	function __getRegExpFlags(re) {
	  var flags = '';
	  if (re.global) flags += 'g';
	  if (re.ignoreCase) flags += 'i';
	  if (re.multiline) flags += 'm';
	  return flags;
	};
	clone.__getRegExpFlags = __getRegExpFlags;

	return clone;
	})();

	if (typeof module === 'object' && module.exports) {
	  module.exports = clone;
	}

	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(9).Buffer))

/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseDict, BaseList, GeneralFactory, Util,
	  hasProp = {}.hasOwnProperty;

	BaseList = __webpack_require__(15);

	BaseDict = __webpack_require__(26);

	Util = __webpack_require__(4);


	/**
	general factory class

	create instance of model

	@class GeneralFactory
	@implements FactoryInterface
	@module base-domain
	 */

	GeneralFactory = (function() {

	  /**
	  create a factory.
	  If specific factory is defined, return the instance.
	  Otherwise, return instance of GeneralFactory.
	  This method is not suitable for creating collections, thus only called by Repository, which handles Entity (= non-collection).
	  
	  @method create
	  @static
	  @param {String} modelName
	  @param {RootInterface} root
	  @return {FactoryInterface}
	   */
	  GeneralFactory.create = function(modelName, root) {
	    var e, error;
	    try {
	      return root.createPreferredFactory(modelName);
	    } catch (error) {
	      e = error;
	      return new GeneralFactory(modelName, root);
	    }
	  };


	  /**
	  create an instance of the given modelName using obj
	  if obj is null, return null
	  if obj is undefined, empty object is created.
	  
	  @method createModel
	  @param {String} modelName
	  @param {Object} obj
	  @param {Object} [options]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include sub-entities asynchronously if true.
	  @param {Array(String)} [options.include.props] include sub-entities of given props
	  @param {RootInterface} root
	  @return {BaseModel}
	   */

	  GeneralFactory.createModel = function(modelName, obj, options, root) {
	    var Model;
	    if (obj === null) {
	      return null;
	    }
	    Model = root.getModule().getModel(modelName);
	    if (Model.prototype instanceof BaseList) {
	      return this.create(Model.itemModelName, root).createList(modelName, obj, options);
	    } else if (Model.prototype instanceof BaseDict) {
	      return this.create(Model.itemModelName, root).createDict(modelName, obj, options);
	    } else {
	      return this.create(modelName, root).createFromObject(obj != null ? obj : {}, options);
	    }
	  };


	  /**
	  constructor
	  
	  @constructor
	  @param {String} modelName
	  @param {RootInterface} root
	   */

	  function GeneralFactory(modelName1, root1) {
	    this.modelName = modelName1;
	    this.root = root1;
	    this.facade = this.root.facade;
	    this.modelProps = this.facade.getModelProps(this.root.getModule().normalizeName(this.modelName));
	  }


	  /**
	  get model class this factory handles
	  
	  @method getModelClass
	  @return {Function}
	   */

	  GeneralFactory.prototype.getModelClass = function() {
	    return this.root.getModule().getModel(this.modelName);
	  };


	  /**
	  create empty model instance
	  
	  @method createEmpty
	  @public
	  @return {BaseModel}
	   */

	  GeneralFactory.prototype.createEmpty = function() {
	    return this.createFromObject({});
	  };


	  /**
	  create instance of model class by plain object
	  
	  for each prop, values are set by Model#set(prop, value)
	  
	  @method createFromObject
	  @public
	  @param {Object} obj
	  @param {Object} [options={}]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include sub-entities asynchronously if true.
	  @param {Array(String)} [options.include.props] include sub-entities of given props
	  @return {BaseModel} model
	   */

	  GeneralFactory.prototype.createFromObject = function(obj, options) {
	    var ModelClass, defaultValue, i, len, model, prop, ref, subModelName, value;
	    if (options == null) {
	      options = {};
	    }
	    ModelClass = this.getModelClass();
	    if (obj instanceof ModelClass) {
	      return obj;
	    }
	    if ((obj == null) || typeof obj !== 'object') {
	      return null;
	    }
	    model = this.create();
	    for (prop in obj) {
	      if (!hasProp.call(obj, prop)) continue;
	      value = obj[prop];
	      if ((value == null) && this.modelProps.isOptional(prop)) {
	        continue;
	      }
	      if (subModelName = this.modelProps.getSubModelName(prop)) {
	        value = this.constructor.createModel(subModelName, value, options, this.root);
	      }
	      model.set(prop, value);
	    }
	    ref = this.modelProps.getAllProps();
	    for (i = 0, len = ref.length; i < len; i++) {
	      prop = ref[i];
	      if ((model[prop] != null) || obj.hasOwnProperty(prop)) {
	        continue;
	      }
	      if (this.modelProps.isId(prop)) {
	        continue;
	      }
	      if (this.modelProps.isOptional(prop)) {
	        continue;
	      }
	      defaultValue = this.modelProps.getDefaultValue(prop);
	      if (subModelName = this.modelProps.getSubModelName(prop)) {
	        if (this.modelProps.isEntity(prop)) {
	          continue;
	        }
	        model.set(prop, this.constructor.createModel(subModelName, defaultValue, options, this.root));
	      } else if (defaultValue != null) {
	        switch (typeof defaultValue) {
	          case 'object':
	            defaultValue = Util.clone(defaultValue);
	            break;
	          case 'function':
	            defaultValue = defaultValue();
	        }
	        model.set(prop, defaultValue);
	      } else {
	        model.set(prop, void 0);
	      }
	    }
	    if (options.include !== null) {
	      this.include(model, options.include).then((function(_this) {
	        return function(model) {
	          if (model.constructor.isImmutable) {
	            return model.freeze();
	          } else {
	            return model;
	          }
	        };
	      })(this));
	    } else if (model.constructor.isImmutable) {
	      return model.freeze();
	    }
	    return model;
	  };


	  /**
	  include submodels
	  
	  @method include
	  @private
	  @param {BaseModel} model
	  @param {Object} [includeOptions]
	  @param {Object} [includeOptions.async=false] include submodels asynchronously
	  @param {Array(String)} [includeOptions.props] include submodels of given props
	   */

	  GeneralFactory.prototype.include = function(model, includeOptions) {
	    if (includeOptions == null) {
	      includeOptions = {};
	    }
	    if (includeOptions.async == null) {
	      includeOptions.async = false;
	    }
	    if (!includeOptions) {
	      return Promise.resolve(model);
	    }
	    return model.include(includeOptions);
	  };


	  /**
	  create model list
	  
	  @method createList
	  @public
	  @param {String} listModelName model name of list
	  @param {any} val
	  @param {Object} [options]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include sub-entities asynchronously if true.
	  @param {Array(String)} [options.include.props] include sub-entities of given props
	  @return {BaseList} list
	   */

	  GeneralFactory.prototype.createList = function(listModelName, val, options) {
	    return this.createCollection(listModelName, val, options);
	  };


	  /**
	  create model dict
	  
	  @method createDict
	  @public
	  @param {String} dictModelName model name of dict
	  @param {any} val
	  @param {Object} [options]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include sub-entities asynchronously if true.
	  @param {Array(String)} [options.include.props] include sub-entities of given props
	  @return {BaseDict} dict
	   */

	  GeneralFactory.prototype.createDict = function(dictModelName, val, options) {
	    return this.createCollection(dictModelName, val, options);
	  };


	  /**
	  create collection
	  
	  @method createCollection
	  @private
	  @param {String} collModelName model name of collection
	  @param {any} val
	  @param {Object} [options]
	  @return {BaseDict} dict
	   */

	  GeneralFactory.prototype.createCollection = function(collModelName, val, options) {
	    if (val === null) {
	      return null;
	    }
	    if (val == null) {
	      val = [];
	    }
	    if (Array.isArray(val)) {
	      if (typeof val[0] === 'object') {
	        val = {
	          items: val
	        };
	      } else {
	        val = {
	          ids: val
	        };
	      }
	    }
	    return new GeneralFactory(collModelName, this.root).createFromObject(val, options);
	  };


	  /**
	  create an empty model
	  
	  @protected
	  @return {BaseModel}
	   */

	  GeneralFactory.prototype.create = function() {
	    var Model;
	    Model = this.getModelClass();
	    return new Model(null, this.root);
	  };

	  return GeneralFactory;

	})();

	module.exports = GeneralFactory;


/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseList, Collection,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	Collection = __webpack_require__(16);


	/**
	list class of DDD pattern.

	@class BaseList
	@extends Collection
	@module base-domain
	 */

	BaseList = (function(superClass) {

	  /**
	  the number of items
	  
	  @property itemLength
	  @type number
	  @public
	   */
	  extend(BaseList, superClass);

	  Object.defineProperty(BaseList.prototype, 'itemLength', {
	    get: function() {
	      if (!this.loaded()) {
	        return 0;
	      }
	      return this.items.length;
	    }
	  });


	  /**
	  items: array of models
	  
	  @property {Array} items
	   */


	  /**
	  @constructor
	  @params {any} props
	  @params {RootInterface} root
	   */

	  function BaseList(props, root) {
	    if (props == null) {
	      props = {};
	    }
	    BaseList.__super__.constructor.call(this, props, root);
	  }


	  /**
	  @method initItems
	  @protected
	   */

	  BaseList.prototype.initItems = function() {
	    return this.items = [];
	  };


	  /**
	  @method addItems
	  @param {Array(BaseModel|Object)} items
	  @protected
	   */

	  BaseList.prototype.addItems = function(items) {
	    var item;
	    BaseList.__super__.addItems.apply(this, arguments);
	    if (this.sort) {
	      this.items.sort(this.sort);
	      if (this.isItemEntity) {
	        return this.ids = (function() {
	          var i, len, ref, results;
	          ref = this.items;
	          results = [];
	          for (i = 0, len = ref.length; i < len; i++) {
	            item = ref[i];
	            results.push(item.id);
	          }
	          return results;
	        }).call(this);
	      }
	    }
	  };


	  /**
	  add item to @items
	  
	  @method addItem
	  @protected
	  @param {BaseModel} item
	   */

	  BaseList.prototype.addItem = function(item) {
	    return this.items.push(item);
	  };


	  /**
	  remove item by index
	  
	  @method remove
	  @param {Number} index
	   */

	  BaseList.prototype.remove = function(index) {
	    if (!this.loaded()) {
	      return;
	    }
	    this.items.splice(index, 1);
	    if (this.isItemEntity) {
	      return this.ids.splice(index, 1);
	    }
	  };


	  /**
	  remove item by index and create a new model
	  
	  @method $remove
	  @param {Number} index
	  @return {Baselist} newList
	   */

	  BaseList.prototype.$remove = function(index) {
	    var newItems;
	    if (!this.loaded()) {
	      throw this.error('NotLoaded');
	    }
	    newItems = this.toArray();
	    newItems.splice(index, 1);
	    return this.copyWith({
	      items: newItems
	    });
	  };


	  /**
	  sort items in constructor
	  
	  @method sort
	  @protected
	  @abstract
	  @param modelA
	  @param modelB
	  @return {Number}
	   */


	  /**
	  first item
	  
	  @method first
	  @public
	   */

	  BaseList.prototype.first = function() {
	    if (!this.loaded()) {
	      return void 0;
	    }
	    return this.items[0];
	  };


	  /**
	  last item
	  
	  @method last
	  @public
	   */

	  BaseList.prototype.last = function() {
	    if (!this.loaded()) {
	      return void 0;
	    }
	    return this.items[this.length - 1];
	  };


	  /**
	  get item by index
	  
	  @method getByIndex
	  @public
	   */

	  BaseList.prototype.getByIndex = function(idx) {
	    if (!this.loaded()) {
	      return void 0;
	    }
	    return this.items[idx];
	  };


	  /**
	  get item by index
	  
	  @method getItem
	  @public
	   */

	  BaseList.prototype.getItem = function(idx) {
	    return this.items[idx] || (function() {
	      throw this.error('IndexNotFound');
	    }).call(this);
	  };


	  /**
	  export models to Array
	  
	  @method toArray
	  @public
	   */

	  BaseList.prototype.toArray = function() {
	    if (!this.loaded()) {
	      return [];
	    }
	    return this.items.slice();
	  };

	  return BaseList;

	})(Collection);

	module.exports = BaseList;


/***/ },
/* 16 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseModel, Collection, EntityPool, Util, ValueObject,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty,
	  slice = [].slice;

	ValueObject = __webpack_require__(17);

	EntityPool = __webpack_require__(24);

	BaseModel = __webpack_require__(18);

	Util = __webpack_require__(4);


	/**
	collection model of one model

	@class Collection
	@extends ValueObject
	@module base-domain
	 */

	Collection = (function(superClass) {
	  extend(Collection, superClass);


	  /**
	  model name of the item
	  
	  @property itemModelName
	  @static
	  @protected
	  @type String
	   */

	  Collection.itemModelName = null;


	  /**
	  the number of items (or ids when @isItemEntity is true)
	  
	  @property {Number} length
	  @public
	   */

	  Object.defineProperty(Collection.prototype, 'length', {
	    get: function() {
	      if (this.isItemEntity) {
	        return this.ids.length;
	      } else {
	        return this.itemLength;
	      }
	    }
	  });


	  /**
	  items (submodel collection)
	  
	  @property {Object} items
	  @abstract
	   */


	  /**
	  @constructor
	  @params {any} props
	  @params {RootInterface} root
	   */

	  function Collection(props, root) {
	    var _itemFactory, ids, isItemEntity;
	    if (props == null) {
	      props = {};
	    }
	    this.setRoot(root);
	    if (this.constructor.itemModelName == null) {
	      throw this.error('base-domain:itemModelNameRequired', "@itemModelName is not set, in class " + this.constructor.name);
	    }
	    _itemFactory = null;
	    isItemEntity = this.facade.getModel(this.constructor.itemModelName).isEntity;
	    Object.defineProperties(this, {

	      /**
	      item factory
	      Created only one time. Be careful that @root is not changed even the collection's root is changed.
	      
	      @property {FactoryInterface} itemFactory
	       */
	      itemFactory: {
	        get: function() {
	          return _itemFactory != null ? _itemFactory : _itemFactory = __webpack_require__(14).create(this.constructor.itemModelName, this.root);
	        }
	      },
	      isItemEntity: {
	        value: isItemEntity,
	        writable: false
	      }
	    });
	    this.clear();
	    if ((props.ids != null) && props.items) {
	      ids = props.ids;
	      delete props.ids;
	      Collection.__super__.constructor.call(this, props, root);
	      props.ids = ids;
	    } else {
	      Collection.__super__.constructor.call(this, props, root);
	    }
	  }


	  /**
	  Get the copy of ids
	  @return {Array(String)} ids
	   */

	  Collection.prototype.getIds = function() {
	    var ref;
	    if (!this.isItemEntity) {
	      return void 0;
	    }
	    return (ref = this.ids) != null ? ref.slice() : void 0;
	  };


	  /**
	  set value to prop
	  @return {BaseModel} this
	   */

	  Collection.prototype.set = function(k, v) {
	    switch (k) {
	      case 'items':
	        this.setItems(v);
	        break;
	      case 'ids':
	        this.setIds(v);
	        break;
	      default:
	        Collection.__super__.set.apply(this, arguments);
	    }
	    return this;
	  };


	  /**
	  add new submodel to item(s)
	  
	  @method add
	  @public
	  @param {BaseModel|Object} ...items
	   */

	  Collection.prototype.add = function() {
	    var items;
	    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    return this.addItems(items);
	  };


	  /**
	  add submodels and create new collection
	  
	  @method add
	  @public
	  @param {BaseModel|Object} ...items
	  @return {Collection}
	   */

	  Collection.prototype.$add = function() {
	    var items, newItems;
	    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    newItems = this.toArray().concat(items);
	    return this.copyWith({
	      items: newItems
	    });
	  };


	  /**
	  @method addItems
	  @param {Object|Array(BaseModel|Object)} items
	  @protected
	   */

	  Collection.prototype.addItems = function(items) {
	    var factory, item, key;
	    if (items == null) {
	      items = [];
	    }
	    if (!this.loaded()) {
	      this.initItems();
	    }
	    factory = this.itemFactory;
	    for (key in items) {
	      item = items[key];
	      this.addItem(factory.createFromObject(item));
	    }
	    if (this.isItemEntity) {
	      return this.ids = (function() {
	        var j, len, ref, results;
	        ref = this.toArray();
	        results = [];
	        for (j = 0, len = ref.length; j < len; j++) {
	          item = ref[j];
	          results.push(item.id);
	        }
	        return results;
	      }).call(this);
	    }
	  };


	  /**
	  add item to @items
	  
	  @method addItem
	  @protected
	  @abstract
	  @param {BaseModel} item
	   */

	  Collection.prototype.addItem = function(item) {};


	  /**
	  clear and set ids.
	  
	  @method setIds
	  @param {Array(String|Number)} ids
	  @chainable
	   */

	  Collection.prototype.setIds = function(ids) {
	    if (ids == null) {
	      ids = [];
	    }
	    if (!this.isItemEntity) {
	      return;
	    }
	    if (!Array.isArray(ids)) {
	      return;
	    }
	    this.clear();
	    return this.ids = ids;
	  };


	  /**
	  clear and add items
	  
	  @method setItems
	  @param {Object|Array(BaseModel|Object)} items
	   */

	  Collection.prototype.setItems = function(items) {
	    if (items == null) {
	      items = [];
	    }
	    this.clear();
	    this.addItems(items);
	    return this;
	  };


	  /**
	  removes all items and ids
	  
	  @method clear
	   */

	  Collection.prototype.clear = function() {
	    delete this.items;
	    if (this.isItemEntity) {
	      return this.ids = [];
	    }
	  };


	  /**
	  removes all items and create a new collection
	  
	  @method clear
	   */

	  Collection.prototype.$clear = function() {
	    return this.copyWith({
	      items: []
	    });
	  };


	  /**
	  export items to Array
	  
	  @method toArray
	  @public
	  @abstract
	  @return {Array}
	   */

	  Collection.prototype.toArray = function() {};


	  /**
	  Execute given function for each item
	  
	  @method forEach
	  @public
	  @param {Function} fn
	  @param {Object} _this
	   */

	  Collection.prototype.forEach = function(fn, _this) {
	    this.map(fn, _this);
	  };


	  /**
	  Execute given function for each item
	  returns an array of the result
	  
	  @method map
	  @public
	  @param {Function} fn
	  @param {Object} _this
	  @return {Array}
	   */

	  Collection.prototype.map = function(fn, _this) {
	    var item, j, len, ref, results;
	    if (_this == null) {
	      _this = this;
	    }
	    if (typeof fn !== 'function') {
	      return [];
	    }
	    ref = this.toArray();
	    results = [];
	    for (j = 0, len = ref.length; j < len; j++) {
	      item = ref[j];
	      results.push(fn.call(_this, item));
	    }
	    return results;
	  };


	  /**
	  Filter items with given function
	  
	  @method filter
	  @public
	  @param {Function} fn
	  @param {Object} _this
	  @return {Array}
	   */

	  Collection.prototype.filter = function(fn, _this) {
	    if (_this == null) {
	      _this = this;
	    }
	    if (typeof fn !== 'function') {
	      return this.toArray();
	    }
	    return this.toArray().filter(fn, _this);
	  };


	  /**
	  Returns if some items match the condition in given function
	  
	  @method some
	  @public
	  @param {Function} fn
	  @param {Object} _this
	  @return {Boolean}
	   */

	  Collection.prototype.some = function(fn, _this) {
	    if (_this == null) {
	      _this = this;
	    }
	    if (typeof fn !== 'function') {
	      return false;
	    }
	    return this.toArray().some(fn, _this);
	  };


	  /**
	  Returns if every items match the condition in given function
	  
	  @method every
	  @public
	  @param {Function} fn
	  @param {Object} _this
	  @return {Boolean}
	   */

	  Collection.prototype.every = function(fn, _this) {
	    if (_this == null) {
	      _this = this;
	    }
	    if (typeof fn !== 'function') {
	      return false;
	    }
	    return this.toArray().every(fn, _this);
	  };

	  Collection.prototype.initItems = function() {};


	  /**
	  include all relational models if not set
	  
	  @method include
	  @param {Object} [options]
	  @param {Boolean} [options.async=true] get async values
	  @param {Array(String)} [options.props] include only given props
	  @return {Promise(BaseModel)} self
	   */

	  Collection.prototype.include = function(options) {
	    var superResult;
	    if (options == null) {
	      options = {};
	    }
	    if (options.entityPool == null) {
	      options.entityPool = new EntityPool;
	    }
	    superResult = Collection.__super__.include.call(this, options);
	    if (!this.isItemEntity) {
	      return superResult;
	    }
	    return this.includeEntityItems(options, superResult);
	  };

	  Collection.prototype.includeEntityItems = function(options, superResult) {
	    var EntityCollectionIncluder;
	    EntityCollectionIncluder = __webpack_require__(25);
	    return Promise.all([superResult, new EntityCollectionIncluder(this, options).include()]).then((function(_this) {
	      return function() {
	        return _this;
	      };
	    })(this));
	  };


	  /**
	  freeze the model
	   */

	  Collection.prototype.freeze = function() {
	    if (!this.constructor.isImmutable) {
	      throw this.error('FreezeMutableModel', 'Cannot freeze mutable model.');
	    }
	    if (this.loaded) {
	      Object.freeze(this.items);
	      return Object.freeze(this);
	    } else {
	      return this.include().then((function(_this) {
	        return function() {
	          Object.freeze(_this.items);
	          return Object.freeze(_this);
	        };
	      })(this));
	    }
	  };


	  /**
	  create plain object.
	  if this dict contains entities, returns their ids
	  if this dict contains non-entity models, returns their plain objects
	  
	  @method toPlainObject
	  @return {Object} plainObject
	   */

	  Collection.prototype.toPlainObject = function() {
	    var item, key, plain, plainItems;
	    plain = Collection.__super__.toPlainObject.call(this);
	    if (this.isItemEntity) {
	      plain.ids = this.ids.slice();
	      delete plain.items;
	    } else if (this.loaded()) {
	      plainItems = (function() {
	        var ref, results;
	        ref = this.items;
	        results = [];
	        for (key in ref) {
	          item = ref[key];
	          if (typeof item.toPlainObject === 'function') {
	            results.push(item.toPlainObject());
	          } else {
	            results.push(item);
	          }
	        }
	        return results;
	      }).call(this);
	      plain.items = plainItems;
	    }
	    return plain;
	  };


	  /**
	  create plain array.
	  
	  @method toPlainArray
	  @return {Array} plainArray
	   */

	  Collection.prototype.toPlainArray = function() {
	    var item, items, key, ref;
	    if (this.isItemEntity) {
	      return this.ids.slice();
	    } else if (this.loaded()) {
	      items = [];
	      ref = this.items;
	      for (key in ref) {
	        item = ref[key];
	        if (typeof item.toPlainObject === 'function') {
	          items.push(item.toPlainObject());
	        } else {
	          items.push(item);
	        }
	      }
	      return items;
	    } else {
	      return [];
	    }
	  };


	  /**
	  clone the model as a plain object
	  
	  @method clone
	  @return {BaseModel}
	   */

	  Collection.prototype.plainClone = function() {
	    var item, key, plain;
	    plain = Collection.__super__.plainClone.call(this);
	    if (this.loaded()) {
	      plain.items = (function() {
	        var ref, results;
	        ref = this.items;
	        results = [];
	        for (key in ref) {
	          item = ref[key];
	          if (item instanceof BaseModel) {
	            results.push(item.plainClone());
	          } else {
	            results.push(item);
	          }
	        }
	        return results;
	      }).call(this);
	    }
	    return plain;
	  };


	  /**
	  @method loaded
	  @public
	  @return {Boolean}
	   */

	  Collection.prototype.loaded = function() {
	    return this.items != null;
	  };


	  /**
	  get item model
	  @method getItemModelClass
	  @return {Function}
	   */

	  Collection.prototype.getItemModelClass = function() {
	    return this.facade.getModel(this.constructor.itemModelName);
	  };

	  Collection.prototype.getDiffProps = function(plainObj) {
	    var ret, thatObj;
	    if (plainObj == null) {
	      plainObj = {};
	    }
	    thatObj = {};
	    if (Array.isArray(plainObj)) {
	      if (plainObj.length === 0) {
	        thatObj.items = [];
	      } else if (typeof plainObj[0] === 'object') {
	        thatObj.items = plainObj;
	      } else {
	        thatObj.ids = plainObj;
	      }
	    } else {
	      thatObj = plainObj;
	    }
	    ret = Collection.__super__.getDiffProps.call(this, thatObj);
	    if (this.isItemEntity && thatObj.ids) {
	      if (this.isIdsDifferent(thatObj.ids)) {
	        ret.push('ids');
	      }
	      return ret;
	    } else if (this.isItemsDifferent(thatObj.items)) {
	      ret.push('items');
	      return ret;
	    }
	    return ret;
	  };

	  Collection.prototype.isItemsDifferent = function(items) {
	    if (!Array.isArray(items)) {
	      return this.itemLength > 0;
	    }
	    if (this.itemLength !== items.length) {
	      return true;
	    }
	    return this.some(function(item, i) {
	      if (typeof item.isDifferentFrom === 'function') {
	        return item.isDifferentFrom(items[i]);
	      } else {
	        return !Util.deepEqual(item, items[i]);
	      }
	    });
	  };

	  Collection.prototype.isIdsDifferent = function(ids) {
	    if (!Array.isArray(ids)) {
	      return this.length > 0;
	    }
	    return !Util.deepEqual(this.ids, ids);
	  };

	  return Collection;

	})(ValueObject);

	module.exports = Collection;


/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseModel, Util, ValueObject,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	Util = __webpack_require__(4);

	BaseModel = __webpack_require__(18);


	/**
	Base model class without "id" column, rather than a set of values

	@class ValueObject
	@extends BaseModel
	@module base-domain
	 */

	ValueObject = (function(superClass) {
	  extend(ValueObject, superClass);

	  function ValueObject() {
	    return ValueObject.__super__.constructor.apply(this, arguments);
	  }

	  ValueObject.isEntity = false;


	  /**
	  check equality
	  
	  @method equals
	  @param {ValueObject} vo
	  @return {Boolean}
	   */

	  ValueObject.prototype.equals = function(vo) {
	    return ValueObject.__super__.equals.call(this, vo) && Util.deepEqual(this, vo);
	  };

	  return ValueObject;

	})(BaseModel);

	module.exports = ValueObject;


/***/ },
/* 18 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var Base, BaseModel, ModelProps, TypeInfo, Util,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	TypeInfo = __webpack_require__(19);

	Base = __webpack_require__(20);

	ModelProps = __webpack_require__(22);

	Util = __webpack_require__(4);


	/**
	Base model class of DDD pattern.

	@class BaseModel
	@extends Base
	@module base-domain
	 */

	BaseModel = (function(superClass) {
	  extend(BaseModel, superClass);

	  BaseModel.isEntity = false;


	  /**
	  Flag of the model's immutablity
	  @static
	  @property {Boolean} isImmutable
	   */

	  BaseModel.isImmutable = false;


	  /**
	  key-value pair representing typeName - type
	  
	  use for definition of @properties for each extender
	  
	  @property TYPES
	  @protected
	  @final
	  @static
	  @type Object
	   */

	  BaseModel.TYPES = TypeInfo.TYPES;


	  /**
	  key-value pair representing property's name - type of the model
	  
	      firstName    : @TYPES.STRING
	      lastName     : @TYPES.STRING
	      age          : @TYPES.NUMBER
	      registeredAt : @TYPES.DATE
	      team         : @TYPES.MODEL 'team'
	      hobbies      : @TYPES.MODEL 'hobby-list'
	      info         : @TYPES.ANY
	  
	  see type-info.coffee for full options.
	  
	  @property properties
	  @abstract
	  @static
	  @protected
	  @type Object
	   */

	  BaseModel.properties = {};


	  /**
	  extend @properties of Parent class
	  
	  @example
	      class Parent extends BaseModel
	          @properties:
	              prop1: @TYPES.STRING
	  
	  
	      class ChildModel extends ParentModel
	  
	          @properties: @withParentProps
	              prop2: @TYPES.NUMBER
	  
	      ChildModel.properties # prop1 and prop2
	  
	  
	  @method withParentProps
	  @protected
	  @static
	  @return {Object}
	   */

	  BaseModel.withParentProps = function(properties) {
	    var k, ref, v;
	    if (properties == null) {
	      properties = {};
	    }
	    ref = this.properties;
	    for (k in ref) {
	      v = ref[k];
	      if (properties[k] == null) {
	        properties[k] = v;
	      }
	    }
	    return properties;
	  };


	  /**
	  @method enum
	  @public
	  @return {Object([key: String => Number])}
	   */

	  BaseModel["enum"] = function(prop) {
	    var ref, ref1;
	    return (ref = this.properties) != null ? (ref1 = ref[prop]) != null ? ref1.numsByValue : void 0 : void 0;
	  };


	  /**
	  @method enum
	  @public
	  @return {Object}
	   */

	  BaseModel.prototype["enum"] = function(prop) {
	    return this.getModelProps().getEnumDic(prop);
	  };


	  /**
	  @method getModelProps
	  @private
	  @return {ModelProps}
	   */

	  BaseModel.prototype.getModelProps = function() {
	    if (this.root != null) {
	      return this.facade.getModelProps(this.constructor.getName());
	    } else {
	      return new ModelProps(this.constructor.getName(), this.constructor.properties, null);
	    }
	  };


	  /**
	  @constructor
	  @params {any} obj
	  @params {RootInterface} root
	   */

	  function BaseModel(obj, root) {
	    BaseModel.__super__.constructor.call(this, root);
	    if (obj) {
	      this.set(obj);
	    }
	  }


	  /**
	  set value to prop
	  @return {BaseModel} this
	   */

	  BaseModel.prototype.set = function(prop, value) {
	    var k, modelProps, subIdProp, submodelProp, v;
	    if (typeof prop === 'object') {
	      for (k in prop) {
	        v = prop[k];
	        this.set(k, v);
	      }
	      return this;
	    }
	    this[prop] = value;
	    modelProps = this.getModelProps();
	    if (modelProps.isEntity(prop)) {
	      subIdProp = modelProps.getIdPropByEntityProp(prop);
	      this[subIdProp] = value != null ? value.id : void 0;
	    } else if (modelProps.isId(prop) && (value != null)) {
	      this[prop] = value;
	      submodelProp = modelProps.getEntityPropByIdProp(prop);
	      if ((this[submodelProp] != null) && this[prop] !== this[submodelProp].id) {
	        this[submodelProp] = void 0;
	      }
	    } else if (modelProps.isEnum(prop)) {
	      this.setEnum(prop, value);
	    }
	    return this;
	  };


	  /**
	  set value to prop and create a new model
	  @method $set
	  @return {BaseModel} this
	   */

	  BaseModel.prototype.$set = function(prop, value) {
	    var props;
	    if (typeof prop === 'object') {
	      return this.copyWith(prop);
	    }
	    props = {};
	    props[prop] = value;
	    return this.copyWith(props);
	  };


	  /**
	  set enum value
	  
	  @method setEnum
	  @private
	  @param {String} prop
	  @param {String|Number} value
	   */

	  BaseModel.prototype.setEnum = function(prop, value) {
	    var enums, modelProps;
	    if (value == null) {
	      return;
	    }
	    modelProps = this.getModelProps();
	    enums = modelProps.getEnumDic(prop);
	    if (typeof value === 'string' && (enums[value] != null)) {
	      return this[prop] = enums[value];
	    } else if (typeof value === 'number' && (modelProps.getEnumValues(prop)[value] != null)) {
	      return this[prop] = value;
	    }
	    return console.error("base-domain: Invalid value is passed to ENUM prop \"" + prop + "\" in model \"" + modelProps.modelName + "\".\nValue: \"" + value + "\"\nThe property was not set.");
	  };


	  /**
	  unset property
	  
	  @method unset
	  @param {String} prop property name
	  @return {BaseModel} this
	   */

	  BaseModel.prototype.unset = function(prop) {
	    var modelProps, subIdProp;
	    this[prop] = void 0;
	    modelProps = this.getModelProps();
	    if (modelProps.isEntity(prop)) {
	      subIdProp = modelProps.getIdPropByEntityProp(prop);
	      this[subIdProp] = void 0;
	    }
	    return this;
	  };


	  /**
	  unset property and create a new model
	  
	  @method $unset
	  @param {String} prop property name
	  @return {BaseModel} this
	   */

	  BaseModel.prototype.$unset = function(prop) {
	    var modelProps, props, subIdProp;
	    props = {};
	    props[prop] = null;
	    modelProps = this.getModelProps();
	    if (modelProps.isEntity(prop)) {
	      subIdProp = modelProps.getIdPropByEntityProp(prop);
	      props[subIdProp] = null;
	    }
	    return this.copyWith(props);
	  };


	  /**
	  inherit value of anotherModel
	  
	  @method inherit
	  @param {BaseModel} anotherModel
	  @return {BaseModel} this
	   */

	  BaseModel.prototype.inherit = function(anotherModel) {
	    var k, v;
	    for (k in anotherModel) {
	      if (!hasProp.call(anotherModel, k)) continue;
	      v = anotherModel[k];
	      if (v != null) {
	        this.set(k, v);
	      }
	    }
	    return this;
	  };


	  /**
	  create plain object without relational entities
	  descendants of Entity are removed, but not descendants of BaseModel
	  descendants of Entity in descendants of BaseModel are removed ( = recursive)
	  
	  @method toPlainObject
	  @return {Object} plainObject
	   */

	  BaseModel.prototype.toPlainObject = function() {
	    var modelProps, plainObject, prop, value;
	    plainObject = {};
	    modelProps = this.getModelProps();
	    for (prop in this) {
	      if (!hasProp.call(this, prop)) continue;
	      value = this[prop];
	      if (modelProps.isEntity(prop) || modelProps.isOmitted(prop)) {
	        continue;
	      }
	      if (typeof (value != null ? value.toPlainObject : void 0) === 'function') {
	        plainObject[prop] = value.toPlainObject();
	      } else {
	        plainObject[prop] = value;
	      }
	    }
	    return plainObject;
	  };


	  /**
	  check equality
	  
	  @method equals
	  @param {BaseModel} model
	  @return {Boolean}
	   */

	  BaseModel.prototype.equals = function(model) {
	    return (model != null) && this.constructor === model.constructor;
	  };


	  /**
	  clone the model as a plain object
	  
	  @method plainClone
	  @public
	  @return {Object}
	   */

	  BaseModel.prototype.plainClone = function() {
	    var modelProps, plainObject, prop, value;
	    plainObject = {};
	    modelProps = this.getModelProps();
	    for (prop in this) {
	      if (!hasProp.call(this, prop)) continue;
	      value = this[prop];
	      if (modelProps.isModel && value instanceof BaseModel) {
	        plainObject[prop] = value.plainClone();
	      } else {
	        plainObject[prop] = Util.clone(value);
	      }
	    }
	    return plainObject;
	  };


	  /**
	  create clone
	  
	  @method clone
	  @public
	  @return {BaseModel}
	   */

	  BaseModel.prototype.clone = function() {
	    var modelProps, plainObject;
	    plainObject = this.plainClone();
	    modelProps = this.getModelProps();
	    return this.facade.createModel(modelProps.modelName, plainObject);
	  };


	  /**
	  shallow copy the model with props
	  
	  @method copyWith
	  @return {BaseModel}
	   */

	  BaseModel.prototype.copyWith = function(props) {
	    var entity, entityProp, i, len, modelProps, obj, prop, ref, subId, subIdProp, value;
	    if (props == null) {
	      props = {};
	    }
	    modelProps = this.getModelProps();
	    obj = {};
	    for (prop in this) {
	      if (!hasProp.call(this, prop)) continue;
	      value = this[prop];
	      obj[prop] = value;
	    }
	    for (prop in props) {
	      if (!hasProp.call(props, prop)) continue;
	      value = props[prop];
	      if (value != null) {
	        obj[prop] = value;
	      } else {
	        delete obj[prop];
	      }
	    }
	    ref = modelProps.getEntityProps();
	    for (i = 0, len = ref.length; i < len; i++) {
	      entityProp = ref[i];
	      entity = obj[entityProp];
	      subIdProp = modelProps.getIdPropByEntityProp(entityProp);
	      subId = obj[subIdProp];
	      if ((entity != null) && entity.id !== subId) {
	        obj[subIdProp] = entity.id;
	      }
	    }
	    modelProps = this.getModelProps();
	    return this.facade.createModel(modelProps.modelName, obj);
	  };


	  /**
	  Get diff prop values
	  
	  @method getDiff
	  @public
	  @param {any} plainObj
	  @param {Object} [options]
	  @param {Array(String)} [options.ignores] prop names to skip checking diff
	  @return {Object}
	   */

	  BaseModel.prototype.getDiff = function(plainObj, options) {
	    if (plainObj == null) {
	      plainObj = {};
	    }
	    if (options == null) {
	      options = {};
	    }
	    return this.getDiffProps(plainObj, options).reduce(function(obj, prop) {
	      return obj[prop] = plainObj[prop];
	    }, {});
	  };


	  /**
	  Get diff props
	  
	  @method diff
	  @public
	  @param {any} plainObj
	  @param {Object} [options]
	  @param {Array(String)} [options.ignores] prop names to skip checking diff
	  @return {Array(String)}
	   */

	  BaseModel.prototype.getDiffProps = function(plainObj, options) {
	    var diffProps, entityProp, i, ignores, j, len, len1, modelProps, prop, propsToCheck, ref, thatEntityValue, thatEnumValue, thatISOValue, thatValue, thisEntityValue, thisISOValue, thisValue;
	    if (plainObj == null) {
	      plainObj = {};
	    }
	    if (options == null) {
	      options = {};
	    }
	    if ((plainObj == null) || typeof plainObj !== 'object') {
	      return Object.keys(this);
	    }
	    diffProps = [];
	    modelProps = this.getModelProps();
	    ignores = {};
	    if (Array.isArray(options.ignores)) {
	      ref = options.ignores;
	      for (i = 0, len = ref.length; i < len; i++) {
	        prop = ref[i];
	        ignores[prop] = true;
	      }
	    }
	    propsToCheck = modelProps.getAllProps().filter(function(prop) {
	      return !ignores[prop] && !modelProps.isEntity(prop);
	    });
	    for (j = 0, len1 = propsToCheck.length; j < len1; j++) {
	      prop = propsToCheck[j];
	      thisValue = this[prop];
	      thatValue = plainObj[prop];
	      if (thisValue == null) {
	        if (thatValue == null) {
	          continue;
	        }
	      }
	      if (thatValue == null) {
	        diffProps.push(prop);
	        continue;
	      }
	      if (thisValue === thatValue) {
	        continue;
	      }
	      if (modelProps.isEntity(prop) && (thisValue[prop] != null) && (thatValue == null)) {
	        continue;
	      }
	      if (modelProps.isId(prop)) {
	        entityProp = modelProps.getEntityPropByIdProp(prop);
	        if (thisValue !== thatValue) {
	          diffProps.push(prop, entityProp);
	          continue;
	        }
	        thisEntityValue = this[entityProp];
	        thatEntityValue = plainObj[entityProp];
	        if (thisEntityValue == null) {
	          if (thatEntityValue != null) {
	            diffProps.push(entityProp);
	          }
	          continue;
	        } else if (typeof thisEntityValue.isDifferentFrom === 'function') {
	          if (thisEntityValue.isDifferentFrom(thatEntityValue)) {
	            diffProps.push(entityProp);
	          }
	          continue;
	        } else {
	          diffProps.push(entityProp);
	        }
	      } else if (modelProps.isDate(prop)) {
	        thisISOValue = typeof thisValue.toISOString === 'function' ? thisValue.toISOString() : thisValue;
	        thatISOValue = typeof thatValue.toISOString === 'function' ? thatValue.toISOString() : thatValue;
	        if (thisISOValue === thatISOValue) {
	          continue;
	        }
	      } else if (modelProps.isEnum(prop)) {
	        thatEnumValue = typeof thatValue === 'string' ? this["enum"](prop)[thatValue] : thatValue;
	        if (thisValue === thatEnumValue) {
	          continue;
	        }
	      } else if (typeof thisValue.isDifferentFrom === 'function') {
	        if (!thisValue.isDifferentFrom(thatValue)) {
	          continue;
	        }
	      } else {
	        if (Util.deepEqual(thisValue, thatValue)) {
	          continue;
	        }
	      }
	      diffProps.push(prop);
	    }
	    return diffProps;
	  };


	  /**
	  Get difference props
	  
	  @method diff
	  @public
	  @param {any} plainObj
	  @return {Array(String)}
	   */

	  BaseModel.prototype.isDifferentFrom = function(val) {
	    return this.getDiffProps(val).length > 0;
	  };


	  /**
	  freeze the model
	   */

	  BaseModel.prototype.freeze = function() {
	    if (!this.constructor.isImmutable) {
	      throw this.error('FreezeMutableModel', 'Cannot freeze mutable model.');
	    }
	    return Object.freeze(this);
	  };


	  /**
	  include all relational models if not set
	  
	  @method include
	  @param {Object} [options]
	  @param {Boolean} [options.async=true] get async values
	  @param {Array(String)} [options.props] include only given props
	  @return {Promise(BaseModel)} self
	   */

	  BaseModel.prototype.include = function(options) {
	    var Includer;
	    if (options == null) {
	      options = {};
	    }
	    Includer = __webpack_require__(23);
	    return new Includer(this, options).include().then((function(_this) {
	      return function() {
	        return _this;
	      };
	    })(this));
	  };


	  /**
	  include all relational models and returns new model
	  
	  @method $include
	  @param {Object} [options]
	  @param {Boolean} [options.async=true] get async values
	  @param {Array(String)} [options.props] include only given props
	  @return {Promise(BaseModel)} new model
	   */

	  BaseModel.prototype.$include = function(options) {
	    var Includer, createNew;
	    if (options == null) {
	      options = {};
	    }
	    Includer = __webpack_require__(23);
	    return new Includer(this, options).include(createNew = true);
	  };


	  /**
	  Check if all subentities are included.
	  @method included
	  @return {Boolean}
	   */

	  BaseModel.prototype.included = function(recursive) {
	    var entityProp, i, j, len, len1, modelProp, modelProps, ref, ref1, subIdProp;
	    if (recursive == null) {
	      recursive = false;
	    }
	    modelProps = this.getModelProps();
	    ref = modelProps.getEntityProps();
	    for (i = 0, len = ref.length; i < len; i++) {
	      entityProp = ref[i];
	      subIdProp = modelProps.getIdPropByEntityProp(entityProp);
	      if ((this[subIdProp] != null) && (this[entityProp] == null)) {
	        return false;
	      }
	    }
	    if (!recursive) {
	      return true;
	    }
	    ref1 = modelProps.models;
	    for (j = 0, len1 = ref1.length; j < len1; j++) {
	      modelProp = ref1[j];
	      if ((this[modelProp] != null) && !this[modelProp].included()) {
	        return false;
	      }
	    }
	    return true;
	  };

	  return BaseModel;

	})(Base);

	module.exports = BaseModel;


/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var TypeInfo, camelize;

	camelize = __webpack_require__(4).camelize;


	/**
	type of model's property

	@class TypeInfo
	@module base-domain
	 */

	TypeInfo = (function() {
	  function TypeInfo(typeName1, options) {
	    var k, v;
	    this.typeName = typeName1;
	    if (options == null) {
	      options = {};
	    }
	    for (k in options) {
	      v = options[k];
	      this[k] = v;
	    }
	  }


	  /**
	  default value
	  @property {any} default
	   */


	  /**
	  flag not to include this prop after 'toPlainObject()'
	  @property {Boolean} omit
	   */


	  /**
	  Creates a function which returns TypeInfo
	  
	  @method createType
	  @private
	  @static
	  @param {String} typeName
	  @return {Function(TypeInfo)}
	   */

	  TypeInfo.createType = function(typeName) {
	    var fn;
	    fn = function(options) {
	      if (!(options != null ? options.hasOwnProperty('default') : void 0) && !(options != null ? options.hasOwnProperty('omit') : void 0)) {
	        options = {
	          "default": options
	        };
	      }
	      return new TypeInfo(typeName, options);
	    };
	    fn.typeName = typeName;
	    return fn;
	  };


	  /**
	  get TypeInfo as MODEL
	  
	  @method createModelType
	  @private
	  @static
	  @param {String} modelName
	  @param {Options|String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
	  @return {TypeInfo} type
	   */

	  TypeInfo.createModelType = function(modelName, options) {
	    if (options == null) {
	      options = {};
	    }
	    if (typeof options === 'string') {
	      options = {
	        idPropName: options
	      };
	    }
	    options.model = modelName;
	    if (options.idPropName == null) {
	      options.idPropName = camelize(modelName, true) + 'Id';
	    }
	    return new TypeInfo('MODEL', options);
	  };


	  /**
	  get TypeInfo as MODEL
	  
	  @method createEnumType
	  @private
	  @static
	  @param {Array(String)} values
	  @param {Object|String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
	  @return {TypeInfo} type
	   */

	  TypeInfo.createEnumType = function(values, options) {
	    var i, j, len, numsByValue, typeInfo, value;
	    if (options == null) {
	      options = {};
	    }
	    if (typeof options !== 'object') {
	      options = {
	        "default": options
	      };
	    }
	    options.values = values;
	    typeInfo = new TypeInfo('ENUM', options);
	    if (!Array.isArray(values)) {
	      throw new Error("Invalid definition of ENUM. Values must be an array.");
	    }
	    numsByValue = {};
	    for (i = j = 0, len = values.length; j < len; i = ++j) {
	      value = values[i];
	      if (typeof value !== 'string') {
	        throw new Error("Invalid definition of ENUM. Values must be an array of string.");
	      }
	      if (numsByValue[value] != null) {
	        throw new Error("Invalid definition of ENUM. Value '" + value + "' is duplicated.");
	      }
	      numsByValue[value] = i;
	    }
	    if (typeof typeInfo["default"] === 'string') {
	      if (numsByValue[typeInfo["default"]] == null) {
	        throw new Error("Invalid default value '" + typeInfo["default"] + "' of ENUM.");
	      }
	      typeInfo["default"] = numsByValue[typeInfo["default"]];
	    }
	    if ((typeInfo["default"] != null) && (values[typeInfo["default"]] == null)) {
	      throw new Error("Invalid default value '" + typeInfo["default"] + "' of ENUM.");
	    }
	    typeInfo.numsByValue = numsByValue;
	    return typeInfo;
	  };


	  /**
	  TYPES defines various data type, including model and array of models
	  
	  key: typeName (String)
	  value: type TypeInfo|Function(TypeInfo)
	  
	  @property TYPES
	  @static
	   */

	  TypeInfo.TYPES = {
	    ANY: TypeInfo.createType('ANY'),
	    STRING: TypeInfo.createType('STRING'),
	    NUMBER: TypeInfo.createType('NUMBER'),
	    BOOLEAN: TypeInfo.createType('BOOLEAN'),
	    OBJECT: TypeInfo.createType('OBJECT'),
	    ARRAY: TypeInfo.createType('ARRAY'),
	    DATE: TypeInfo.createType('DATE'),
	    BUFFER: TypeInfo.createType('BUFFER'),
	    GEOPOINT: TypeInfo.createType('GEOPOINT'),
	    CREATED_AT: TypeInfo.createType('CREATED_AT'),
	    UPDATED_AT: TypeInfo.createType('UPDATED_AT'),
	    SUB_ID: TypeInfo.createType('SUB_ID'),
	    MODEL: TypeInfo.createModelType,
	    ENUM: TypeInfo.createEnumType
	  };

	  return TypeInfo;

	})();

	module.exports = TypeInfo;


/***/ },
/* 20 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var Base, DomainError, getProto, hyphenize, ref;

	DomainError = __webpack_require__(21);

	hyphenize = __webpack_require__(4).hyphenize;

	getProto = (ref = Object.getPrototypeOf) != null ? ref : function(obj) {
	  return obj.__proto__;
	};


	/**
	parent class of model, factory, repository and service

	gives them `this.facade` property

	@class Base
	@module base-domain
	 */

	Base = (function() {
	  Object.defineProperty(Base.prototype, 'facade', {
	    get: function() {
	      return this.root.facade;
	    }
	  });

	  Base.isBaseDomainClass = true;


	  /**
	  Hyphenized name.
	  The name should equal to the file name (without path and extension).
	  If not set, facade will set the file name automatically.
	  This property were not necessary if uglify-js would not mangle class name...
	  
	  @property {String} className
	  @static
	  @private
	   */

	  Base.className = null;

	  function Base(root) {
	    var facade;
	    this.setRoot(root);
	    if (this.root) {
	      facade = this.facade;
	      if (this.constructor.className && !facade.hasClass(this.constructor.className)) {
	        facade.addClass(this.constructor.className, this.constructor);
	      }
	    }
	  }


	  /**
	  @method setRoot
	  @protected
	   */

	  Base.prototype.setRoot = function(root) {
	    var latestInstance;
	    if (!(root != null ? root.constructor.isRoot : void 0)) {
	      console.error("base-domain: [warning] constructor of '" + this.constructor.name + "' was not given RootInterface (e.g. facade).");
	      latestInstance = __webpack_require__(3).latestInstance;
	      if (latestInstance != null) {
	        console.error("@root is automatically set, value is the most recently created facade via Facade.createInstance().\n( class name: " + latestInstance.constructor.name + " )");
	        root = latestInstance;
	      } else {
	        console.error("@root, @facade is unavailable.");
	        root = null;
	      }
	      console.error(new Error().stack);
	    }

	    /**
	    @property {RootInterface} root
	     */
	    return Object.defineProperty(this, 'root', {
	      value: root,
	      writable: true
	    });
	  };


	  /**
	  Get facade
	  
	  @deprecated just use this.facade
	  @method getFacade
	  @return {Facade}
	   */

	  Base.prototype.getFacade = function() {
	    if (this.root == null) {
	      throw this.error('base-domain:noFacadeAssigned', "'" + this.constructor.name + "' does not have @root.\nGive it via constructor or create instance via Facade.");
	    }
	    return this.root.facade;
	  };


	  /**
	  Get module which this class belongs to
	  
	  @method getModule
	  @return {BaseModule}
	   */

	  Base.prototype.getModule = function() {
	    return this.facade.getModule(this.constructor.moduleName);
	  };


	  /**
	  get parent class
	  @method getParent
	  @return {Function}
	   */

	  Base.getParent = function() {
	    return getProto(this.prototype).constructor;
	  };


	  /**
	  get className
	  
	  @method getName
	  @public
	  @static
	  @return {String}
	   */

	  Base.getName = function() {
	    var hyphenized;
	    if (!this.className || this.getParent().className === this.className) {
	      hyphenized = hyphenize(this.name);
	      console.error("@className property is not defined at class " + this.name + ".\nIt will automatically be set when required through Facade.\nYou might have loaded this class not via Facade.\nWe guess the name \"" + hyphenized + "\" by the function name instead of @className.\nIt would not work at mangled JS (uglify-js).");
	      console.error(new Error().stack);
	      return hyphenize(this.name);
	    }
	    return this.className;
	  };


	  /**
	  create instance of DomainError
	  
	  @method error
	  @param {String} reason reason of the error
	  @param {String} [message]
	  @return {Error}
	   */

	  Base.prototype.error = function(reason, message) {
	    return new DomainError(reason, message);
	  };


	  /**
	  Show indication message of deprecated method
	  
	  @method deprecated
	  @protected
	  @param {String} methodName
	  @param {String} message
	  @return {Error}
	   */

	  Base.prototype.deprecated = function(methodName, message) {
	    var e, error, line;
	    try {
	      line = new Error().stack.split('\n')[3];
	      return console.error("Deprecated method: '" + methodName + "'. " + (message ? message : void 0) + "\n", line);
	    } catch (error) {
	      e = error;
	    }
	  };

	  return Base;

	})();

	module.exports = Base;


/***/ },
/* 21 */
/***/ function(module, exports) {

	'use strict';

	/**
	error thrown by base-domain module

	    class DomainError extends Error  # not worked.

	see http://stackoverflow.com/questions/19422145/property-in-subclass-of-error-not-set


	@class DomainError
	@extends Error
	@module base-domain
	 */
	var DomainError;

	DomainError = function(reason, message) {
	  var k, ref, self, v;
	  if (message instanceof Error) {
	    self = message;
	  } else if (typeof message === 'object') {
	    self = new Error((ref = message.message) != null ? ref : reason);
	    for (k in message) {
	      v = message[k];
	      self[k] = v;
	    }
	  } else {
	    if (message == null) {
	      message = reason;
	    }
	    self = new Error(message);
	  }
	  self.name = 'DomainError';
	  self.__proto__ = DomainError.prototype;

	  /**
	  reason of the error
	  alphanumeric string (without space) is recommended,
	  
	  @property reason
	  @type {String}
	  
	  @reason
	   */
	  self.reason = reason;
	  return self;
	};

	DomainError.prototype.__proto__ = Error.prototype;

	module.exports = DomainError;


/***/ },
/* 22 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var ModelProps, TYPES;

	TYPES = __webpack_require__(19).TYPES;


	/**
	parses model properties and classifies them

	@class ModelProps
	@module base-domain
	 */

	ModelProps = (function() {

	  /**
	  @param {String} modelName
	  @param {Object} properties
	  @param {BaseModule} modl
	   */
	  function ModelProps(modelName, properties, modl) {
	    this.modelName = modelName;

	    /**
	    property whose type is CREATED_AT
	    @property {String} createdAt
	    @public
	    @readonly
	     */
	    this.createdAt = null;

	    /**
	    property whose type is UPDATED_AT
	    @property {String} updatedAt
	    @public
	    @readonly
	     */
	    this.updatedAt = null;
	    this.subModelProps = [];
	    this.typeInfoDic = {};
	    this.entityDic = {};
	    this.enumDic = {};
	    this.dateDic = {};
	    this.parse(properties, modl);
	  }


	  /**
	  properties whose type is DATE, CREATED_AT and UPDATED_AT
	  @property {Array(String)} dates
	  @public
	  @readonly
	   */

	  Object.defineProperty(ModelProps.prototype, 'dates', {
	    get: function() {
	      return Object.keys(this.dateDic);
	    }

	    /**
	    parse props by type
	    
	    @method parse
	    @private
	     */
	  });

	  ModelProps.prototype.parse = function(properties, modl) {
	    var prop, typeInfo;
	    for (prop in properties) {
	      typeInfo = properties[prop];
	      this.parseProp(prop, typeInfo, modl);
	    }
	  };


	  /**
	  parse one prop by type
	  
	  @method parseProp
	  @private
	   */

	  ModelProps.prototype.parseProp = function(prop, typeInfo, modl) {
	    this.typeInfoDic[prop] = typeInfo;
	    switch (typeInfo.typeName) {
	      case 'DATE':
	        this.dateDic[prop] = true;
	        break;
	      case 'CREATED_AT':
	        this.createdAt = prop;
	        this.dateDic[prop] = true;
	        break;
	      case 'UPDATED_AT':
	        this.updatedAt = prop;
	        this.dateDic[prop] = true;
	        break;
	      case 'MODEL':
	        this.parseSubModelProp(prop, typeInfo, modl);
	    }
	  };


	  /**
	  parse submodel prop
	  
	  @method parseSubModelProp
	  @private
	   */

	  ModelProps.prototype.parseSubModelProp = function(prop, typeInfo, modl) {
	    var idTypeInfo;
	    this.subModelProps.push(prop);
	    if (modl == null) {
	      console.error("base-domain:ModelProps could not parse property info of '" + prop + "'.\n(@TYPES." + typeInfo.typeName + ", model=" + typeInfo.model + ".)\nConstruct original model '" + this.modelName + "' with RootInterface.\n\n    new Model(obj, facade)\n    facade.createModel('" + this.modelName + "', obj)\n");
	      return;
	    }
	    if (modl.getModel(typeInfo.model).isEntity) {
	      this.entityDic[prop] = true;
	      idTypeInfo = TYPES.SUB_ID({
	        modelProp: prop,
	        entity: typeInfo.model,
	        omit: typeInfo.omit
	      });
	      this.parseProp(typeInfo.idPropName, idTypeInfo, modl);
	    }
	  };


	  /**
	  get all prop names
	  
	  @method getAllProps
	  @public
	  @return {Array(String)}
	   */

	  ModelProps.prototype.getAllProps = function() {
	    return Object.keys(this.typeInfoDic);
	  };


	  /**
	  get all entity prop names
	  
	  @method getEntityProps
	  @public
	  @return {Array(String)}
	   */

	  ModelProps.prototype.getEntityProps = function() {
	    return Object.keys(this.entityDic);
	  };


	  /**
	  get all model prop names
	  
	  @method getSubModelProps
	  @public
	  @return {Array(String)}
	   */

	  ModelProps.prototype.getSubModelProps = function() {
	    return this.subModelProps.slice();
	  };


	  /**
	  check if the given prop is entity prop
	  
	  @method isEntity
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isEntity = function(prop) {
	    return this.entityDic[prop] != null;
	  };


	  /**
	  check if the given prop is model prop
	  
	  @method isModel
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isModel = function(prop) {
	    var ref;
	    return ((ref = this.typeInfoDic[prop]) != null ? ref.typeName : void 0) === 'MODEL';
	  };


	  /**
	  check if the given prop is submodel's id
	  
	  @method isId
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isId = function(prop) {
	    var ref;
	    return ((ref = this.typeInfoDic[prop]) != null ? ref.typeName : void 0) === 'SUB_ID';
	  };


	  /**
	  check if the given prop is date
	  
	  @method isDate
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isDate = function(prop) {
	    return this.dateDic[prop] != null;
	  };


	  /**
	  check if the given prop is enum
	  
	  @method isEnum
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isEnum = function(prop) {
	    var ref;
	    return ((ref = this.typeInfoDic[prop]) != null ? ref.typeName : void 0) === 'ENUM';
	  };


	  /**
	  get value - enum pair
	  
	  @method isEnumDic
	  @public
	  @param {String} prop
	  @return {Object}
	   */

	  ModelProps.prototype.getEnumDic = function(prop) {
	    var ref;
	    return (ref = this.typeInfoDic[prop]) != null ? ref.numsByValue : void 0;
	  };


	  /**
	  get values of enum
	  
	  @method isEnumValues
	  @public
	  @param {String} prop
	  @return {Array(String)}
	   */

	  ModelProps.prototype.getEnumValues = function(prop) {
	    var ref;
	    return (ref = this.typeInfoDic[prop]) != null ? ref.values.slice() : void 0;
	  };


	  /**
	  get entity prop of the given idPropName
	  
	  @method getEntityPropByIdProp
	  @public
	  @param {String} idPropName
	  @return {String} submodelProp
	   */

	  ModelProps.prototype.getEntityPropByIdProp = function(idProp) {
	    var ref;
	    return (ref = this.typeInfoDic[idProp]) != null ? ref.modelProp : void 0;
	  };


	  /**
	  check if the given prop is tmp prop
	  
	  @method isOmitted
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isOmitted = function(prop) {
	    var ref;
	    return !!((ref = this.typeInfoDic[prop]) != null ? ref.omit : void 0);
	  };


	  /**
	  get prop name of id of entity prop
	  
	  @method getIdPropByEntityProp
	  @public
	  @param {String} prop
	  @return {String} idPropName
	   */

	  ModelProps.prototype.getIdPropByEntityProp = function(entityProp) {
	    var ref;
	    return (ref = this.typeInfoDic[entityProp]) != null ? ref.idPropName : void 0;
	  };


	  /**
	  get model name of model prop
	  
	  @method getSubModelProps
	  @public
	  @param {String} prop
	  @return {String} model name
	   */

	  ModelProps.prototype.getSubModelName = function(prop) {
	    var ref;
	    return (ref = this.typeInfoDic[prop]) != null ? ref.model : void 0;
	  };


	  /**
	  check if the prop is optional
	  
	  @method isOptional
	  @public
	  @param {String} prop
	  @return {Boolean}
	   */

	  ModelProps.prototype.isOptional = function(prop) {
	    var ref;
	    return !!((ref = this.typeInfoDic[prop]) != null ? ref.optional : void 0);
	  };


	  /**
	  get the default value of the prop
	  
	  @method getDefaultValue
	  @public
	  @param {String} prop
	  @return {any} defaultValue
	   */

	  ModelProps.prototype.getDefaultValue = function(prop) {
	    var ref;
	    return (ref = this.typeInfoDic[prop]) != null ? ref["default"] : void 0;
	  };

	  return ModelProps;

	})();

	module.exports = ModelProps;


/***/ },
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseModel, EntityPool, Includer,
	  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

	BaseModel = __webpack_require__(18);

	EntityPool = __webpack_require__(24);


	/**
	include submodels

	@class Includer
	@module base-domain
	 */

	Includer = (function() {

	  /**
	  @constructor
	  @param {Object} options
	  @param {Boolean} [options.async=true] get async values
	  @param {Boolean} [options.entityPool] entityPool, to detect circular references
	  @param {Array(String)} [options.noParentRepos] array of modelNames which needs "noParent" option when calling root.createPreferredRepository()
	  @param {Array(String)} [options.props] include only given props
	   */
	  function Includer(model1, options1) {
	    var ModelClass, base, ref;
	    this.model = model1;
	    this.options = options1 != null ? options1 : {};
	    if (this.options.entityPool == null) {
	      this.entityPoolCreated = true;
	      this.options.entityPool = new EntityPool;
	    }
	    this.entityPool = this.options.entityPool;
	    if ((base = this.options).async == null) {
	      base.async = true;
	    }
	    ModelClass = this.model.constructor;
	    this.modelProps = this.model.facade.getModelProps(ModelClass.getName());
	    ref = this.splitEntityProps(), this.syncs = ref.syncs, this.asyncs = ref.asyncs, this.repos = ref.repos;
	  }

	  Includer.prototype.splitEntityProps = function() {
	    var asyncs, entityProp, entityProps, i, len, p, repo, repos, subModelName, syncs;
	    repos = {};
	    syncs = [];
	    asyncs = [];
	    entityProps = this.modelProps.getEntityProps();
	    if (this.options.props) {
	      entityProps = (function() {
	        var i, len, results;
	        results = [];
	        for (i = 0, len = entityProps.length; i < len; i++) {
	          p = entityProps[i];
	          if (indexOf.call(this.options.props, p) >= 0) {
	            results.push(p);
	          }
	        }
	        return results;
	      }).call(this);
	    }
	    for (i = 0, len = entityProps.length; i < len; i++) {
	      entityProp = entityProps[i];
	      if (!(this.isNotIncludedProp(entityProp))) {
	        continue;
	      }
	      subModelName = this.modelProps.getSubModelName(entityProp);
	      repo = this.createPreferredRepository(subModelName);
	      repos[entityProp] = repo;
	      if (repo.constructor.isSync) {
	        syncs.push(entityProp);
	      } else {
	        asyncs.push(entityProp);
	      }
	    }
	    return {
	      syncs: syncs,
	      asyncs: asyncs,
	      repos: repos
	    };
	  };


	  /**
	  include sub entities
	  
	  @method include
	  @public
	  @return {Promise}
	   */

	  Includer.prototype.include = function(createNew) {
	    var model, modelName, newAsyncProps, promises;
	    if (createNew == null) {
	      createNew = false;
	    }
	    if (this.model.constructor.isEntity) {
	      modelName = this.model.constructor.getName();
	      if (this.entityPool.get(modelName, this.model.id)) {
	        return Promise.resolve(this.model);
	      }
	      this.entityPool.set(this.model);
	    }
	    model = this.includeSync(createNew);
	    if (!this.options.async || this.asyncs.length === 0) {
	      return Promise.resolve(model);
	    }
	    if (this.model.constructor.isImmutable && !createNew && Object.isFrozen(this.model)) {
	      console.error('frozen model.');
	      return Promise.resolve(model);
	    }
	    newAsyncProps = {};
	    promises = this.asyncs.map((function(_this) {
	      return function(prop) {
	        return _this.getSubModel(prop, true).then(function(subModel) {
	          if (subModel == null) {
	            return;
	          }
	          _this.entityPool.set(subModel);
	          return newAsyncProps[prop] = subModel;
	        });
	      };
	    })(this));
	    return Promise.all(promises).then((function(_this) {
	      return function() {
	        return _this.applyNewProps(newAsyncProps, createNew);
	      };
	    })(this));
	  };

	  Includer.prototype.getSubModel = function(prop, isAsync) {
	    var subId, subIdProp, subModel, subModelName;
	    subIdProp = this.modelProps.getIdPropByEntityProp(prop);
	    subModelName = this.modelProps.getSubModelName(prop);
	    subId = this.model[subIdProp];
	    if (subModel = this.entityPool.get(subModelName, subId)) {
	      if (isAsync) {
	        return Promise.resolve(subModel);
	      } else {
	        return subModel;
	      }
	    }
	    return this.repos[prop].get(this.model[subIdProp], {
	      include: this.options
	    });
	  };

	  Includer.prototype.includeSync = function(createNew) {
	    var newProps;
	    if (createNew == null) {
	      createNew = false;
	    }
	    newProps = {};
	    this.syncs.forEach((function(_this) {
	      return function(prop) {
	        var subModel;
	        subModel = _this.getSubModel(prop, false);
	        if (subModel == null) {
	          return;
	        }
	        _this.entityPool.set(subModel);
	        return newProps[prop] = subModel;
	      };
	    })(this));
	    return this.applyNewProps(newProps, createNew);
	  };

	  Includer.prototype.isNotIncludedProp = function(entityProp) {
	    var subIdProp;
	    subIdProp = this.modelProps.getIdPropByEntityProp(entityProp);
	    return (this.model[entityProp] == null) && (this.model[subIdProp] != null);
	  };

	  Includer.prototype.applyNewProps = function(newProps, createNew) {
	    if (createNew) {
	      return this.model.$set(newProps);
	    } else {
	      return this.model.set(newProps);
	    }
	  };

	  Includer.prototype.createPreferredRepository = function(modelName) {
	    var e, error, options;
	    options = {};
	    if (Array.isArray(this.options.noParentRepos) && indexOf.call(this.options.noParentRepos, modelName) >= 0) {
	      if (options.noParent == null) {
	        options.noParent = true;
	      }
	    }
	    try {
	      return this.model.root.createPreferredRepository(modelName, options);
	    } catch (error) {
	      e = error;
	      return null;
	    }
	  };

	  return Includer;

	})();

	module.exports = Includer;


/***/ },
/* 24 */
/***/ function(module, exports) {

	'use strict';

	/**
	@class EntityPool
	@module base-domain
	 */
	var EntityPool;

	EntityPool = (function() {
	  function EntityPool() {}


	  /**
	  Register an entity to pool
	  @method set
	  @param {Entity} model
	   */

	  EntityPool.prototype.set = function(model) {
	    var Model, modelName;
	    Model = model.constructor;
	    if (!Model.isEntity || ((model != null ? model.id : void 0) == null)) {
	      return;
	    }
	    modelName = Model.getName();
	    if (EntityPool.prototype[modelName]) {
	      throw new Error("invalid model name " + modelName);
	    }
	    if (this[modelName] == null) {
	      this[modelName] = {};
	    }
	    return this[modelName][model.id] = model;
	  };


	  /**
	  Get registred models by model name and id
	  
	  @method get
	  @param {String} modelName
	  @param {String} id
	  @return {Entity}
	   */

	  EntityPool.prototype.get = function(modelName, id) {
	    var ref;
	    return (ref = this[modelName]) != null ? ref[id] : void 0;
	  };


	  /**
	  Clear all the registered entities
	  
	  @method clear
	   */

	  EntityPool.prototype.clear = function() {
	    var id, modelName, models, results;
	    results = [];
	    for (modelName in this) {
	      models = this[modelName];
	      for (id in models) {
	        delete models[id];
	      }
	      results.push(delete models[modelName]);
	    }
	    return results;
	  };

	  return EntityPool;

	})();

	module.exports = EntityPool;


/***/ },
/* 25 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var EntityCollectionIncluder, Includer,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	Includer = __webpack_require__(23);


	/**
	include submodels

	@class EntityCollectionIncluder
	@extends Includer
	@module base-domain
	 */

	EntityCollectionIncluder = (function(superClass) {
	  extend(EntityCollectionIncluder, superClass);

	  function EntityCollectionIncluder() {
	    EntityCollectionIncluder.__super__.constructor.apply(this, arguments);
	    this.itemModelName = this.model.constructor.itemModelName;
	  }

	  EntityCollectionIncluder.prototype.include = function() {
	    return Promise.all([this.includeItems(), EntityCollectionIncluder.__super__.include.apply(this, arguments)]);
	  };

	  EntityCollectionIncluder.prototype.includeItems = function() {
	    var i, id, item, items, len, ref, repo;
	    if (this.model.loaded()) {
	      return;
	    }
	    items = [];
	    ref = this.model.ids;
	    for (i = 0, len = ref.length; i < len; i++) {
	      id = ref[i];
	      item = this.entityPool.get(this.itemModelName, id);
	      if (item != null) {
	        items.push(item);
	      }
	    }
	    if (items.length === this.model.length) {
	      this.model.setItems(items);
	      return;
	    }
	    repo = this.createPreferredRepository(this.itemModelName);
	    if (repo == null) {
	      return;
	    }
	    if (repo.constructor.isSync) {
	      items = repo.getByIds(this.model.ids, {
	        include: this.options
	      });
	      if (items.length !== this.model.ids.length) {
	        console.warn('EntityCollectionIncluder#include(): some ids were not loaded.');
	      }
	      return this.model.setItems(items);
	    } else {
	      if (!this.options.async) {
	        return;
	      }
	      return repo.getByIds(this.model.ids, {
	        include: this.options
	      }).then((function(_this) {
	        return function(items) {
	          if (items.length !== _this.model.ids.length) {
	            console.warn('EntityCollectionIncluder#include(): some ids were not loaded.');
	          }
	          return _this.model.setItems(items);
	        };
	      })(this))["catch"](function(e) {});
	    }
	  };

	  return EntityCollectionIncluder;

	})(Includer);

	module.exports = EntityCollectionIncluder;


/***/ },
/* 26 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseDict, Collection,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty,
	  slice = [].slice;

	Collection = __webpack_require__(16);


	/**
	dictionary-structured data model

	@class BaseDict
	@extends Collection
	@module base-domain
	 */

	BaseDict = (function(superClass) {
	  extend(BaseDict, superClass);

	  function BaseDict() {
	    return BaseDict.__super__.constructor.apply(this, arguments);
	  }


	  /**
	  get unique key from item
	  
	  @method key
	  @static
	  @protected
	   */

	  BaseDict.key = function(item) {
	    return item.id;
	  };


	  /**
	  the number of items
	  
	  @property {Number} itemLength
	  @public
	   */

	  Object.defineProperty(BaseDict.prototype, 'itemLength', {
	    get: function() {
	      if (!this.loaded()) {
	        return 0;
	      }
	      return Object.keys(this.items).length;
	    }
	  });


	  /**
	  items: dictionary of keys - models
	  
	  @property {Object} items
	   */


	  /**
	  @method initItems
	  @protected
	   */

	  BaseDict.prototype.initItems = function() {
	    return this.items = {};
	  };


	  /**
	  check if the model has submodel of the given key or not
	  
	  @method has
	  @public
	  @param {String|Number} key
	  @return {Boolean}
	   */

	  BaseDict.prototype.has = function(key) {
	    if (!this.loaded()) {
	      return false;
	    }
	    return this.items[key] != null;
	  };


	  /**
	  check if the model contains the given submodel or not
	  
	  @method contains
	  @public
	  @param {BaseModel} item
	  @return {Boolean}
	   */

	  BaseDict.prototype.contains = function(item) {
	    var key, sameKeyItem;
	    if (!this.loaded()) {
	      return false;
	    }
	    key = this.constructor.key(item);
	    sameKeyItem = this.get(key);
	    return sameKeyItem != null ? sameKeyItem.equals(item) : void 0;
	  };


	  /**
	  turn on/off the value
	  
	  @method toggle
	  @param {BaseModel} item
	   */

	  BaseDict.prototype.toggle = function(item) {
	    var key;
	    if (!this.loaded()) {
	      return this.add(item);
	    }
	    key = this.constructor.key(item);
	    if (this.has(key)) {
	      return this.remove(item);
	    } else {
	      return this.add(item);
	    }
	  };


	  /**
	  turn on/off the value and create a new model
	  
	  @method toggle
	  @param {BaseModel} item
	  @return {BaseDict} newDict
	   */

	  BaseDict.prototype.$toggle = function(item) {
	    var key;
	    if (!this.loaded()) {
	      throw this.error('NotLoaded');
	    }
	    key = this.constructor.key(item);
	    if (this.has(key)) {
	      return this.$remove(item);
	    } else {
	      return this.$add(item);
	    }
	  };


	  /**
	  return submodel of the given key
	  
	  @method get
	  @public
	  @param {String|Number} key
	  @return {BaseModel}
	   */

	  BaseDict.prototype.get = function(key) {
	    if (!this.loaded()) {
	      return void 0;
	    }
	    return this.items[key];
	  };


	  /**
	  return submodel of the given key
	  throw error when not found.
	  
	  @method getItem
	  @public
	  @param {String|Number} key
	  @return {BaseModel}
	   */

	  BaseDict.prototype.getItem = function(key) {
	    if (!this.has(key)) {
	      throw this.error('KeyNotFound');
	    }
	    return this.items[key];
	  };


	  /**
	  add item to @items
	  
	  @method addItem
	  @protected
	  @param {BaseModel} item
	   */

	  BaseDict.prototype.addItem = function(item) {
	    var key;
	    key = this.constructor.key(item);
	    return this.items[key] = item;
	  };


	  /**
	  remove submodel from items
	  both acceptable, keys and submodels
	  
	  @method remove
	  @public
	  @param {BaseModel|String|Number} item
	   */

	  BaseDict.prototype.remove = function() {
	    var ItemClass, arg, args, i, idx, item, key, len;
	    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    if (!this.loaded()) {
	      return;
	    }
	    ItemClass = this.getItemModelClass();
	    for (i = 0, len = args.length; i < len; i++) {
	      arg = args[i];
	      if (arg instanceof ItemClass) {
	        key = this.constructor.key(arg);
	      } else {
	        key = arg;
	      }
	      item = this.items[key];
	      delete this.items[key];
	      if (item && this.ids) {
	        idx = this.ids.indexOf(item.id);
	        if (idx >= 0) {
	          this.ids.splice(idx, 1);
	        }
	      }
	    }
	  };


	  /**
	  remove submodel and create a new dict
	  both acceptable, keys and submodels
	  
	  @method $remove
	  @public
	  @param {BaseModel|String|Number} item
	  @return {BaseDict} newDict
	   */

	  BaseDict.prototype.$remove = function() {
	    var ItemClass, arg, args, i, key, len, newItems;
	    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
	    if (!this.loaded()) {
	      throw this.error('NotLoaded');
	    }
	    ItemClass = this.getItemModelClass();
	    newItems = this.toObject();
	    for (i = 0, len = args.length; i < len; i++) {
	      arg = args[i];
	      if (arg instanceof ItemClass) {
	        key = this.constructor.key(arg);
	      } else {
	        key = arg;
	      }
	      delete newItems[key];
	    }
	    return this.copyWith({
	      items: newItems
	    });
	  };


	  /**
	  replace item and return a new dict
	  
	  @method $replace
	  @public
	  @param {BaseModel} item
	  @return {BaseDict} newDict
	   */

	  BaseDict.prototype.$replace = function(item) {
	    var key, newItems;
	    newItems = this.toObject();
	    key = this.constructor.key(item);
	    if (key == null) {
	      throw new Error('InvalidItem');
	    }
	    if (!this.has(key)) {
	      throw new Error('KeyNotFound');
	    }
	    newItems[key] = item;
	    return this.copyWith({
	      items: newItems
	    });
	  };


	  /**
	  export models to Array
	  
	  @method toArray
	  @public
	   */

	  BaseDict.prototype.toArray = function() {
	    var item, key, ref, results;
	    if (!this.loaded()) {
	      return [];
	    }
	    ref = this.items;
	    results = [];
	    for (key in ref) {
	      item = ref[key];
	      results.push(item);
	    }
	    return results;
	  };


	  /**
	  get all keys
	  
	  @method keys
	  @public
	  @return {Array}
	   */

	  BaseDict.prototype.keys = function() {
	    var item, key, ref, results;
	    if (!this.loaded()) {
	      return [];
	    }
	    ref = this.items;
	    results = [];
	    for (key in ref) {
	      item = ref[key];
	      results.push(key);
	    }
	    return results;
	  };


	  /**
	  iterate key - item
	  
	  @method keyValues
	  @public
	  @params {Function} fn 1st argument: key, 2nd argument: value
	   */

	  BaseDict.prototype.keyValues = function(fn, _this) {
	    var item, key, ref;
	    if (_this == null) {
	      _this = this;
	    }
	    if (typeof fn !== 'function' || !this.loaded()) {
	      return;
	    }
	    ref = this.items;
	    for (key in ref) {
	      item = ref[key];
	      fn.call(_this, key, item);
	    }
	  };


	  /**
	  to key-value object
	  
	  @method toObject
	  @public
	   */

	  BaseDict.prototype.toObject = function() {
	    var k, obj, ref, v;
	    obj = {};
	    ref = this.items;
	    for (k in ref) {
	      v = ref[k];
	      obj[k] = v;
	    }
	    return obj;
	  };

	  return BaseDict;

	})(Collection);

	module.exports = BaseDict;


/***/ },
/* 27 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var MasterDataResource, MemoryResource;

	MemoryResource = __webpack_require__(28);


	/**

	@class MasterDataResource
	@implements ResourceClientInterface
	 */

	MasterDataResource = (function() {

	  /**
	  load master JSON file if exists
	  
	  @constructor
	   */
	  function MasterDataResource(facade) {
	    var dirname;
	    this.facade = facade;
	    dirname = this.facade.dirname;
	    this.masterDirPath = this.constructor.getDirPath(dirname);
	    this.masterJSONPath = this.constructor.getJSONPath(dirname);
	    this.memories = {};
	  }


	  /**
	  Get master data dir
	  
	  @method getDirPath
	  @public
	  @static
	  @return {String}
	   */

	  MasterDataResource.getDirPath = function(dirname) {
	    return dirname + '/master-data';
	  };


	  /**
	  Get master JSON path
	  
	  @method getJSONPath
	  @public
	  @static
	  @return {String}
	   */

	  MasterDataResource.getJSONPath = function(dirname) {
	    return this.getDirPath(dirname) + '/all.json';
	  };


	  /**
	  load data from directory(Node.js) or JSON (other environments)
	  
	  @method init
	  @public
	  @chainable
	   */

	  MasterDataResource.prototype.init = function() {
	    var modelName, plainMemories, plainMemory;
	    if ((typeof Ti === "undefined" || Ti === null) && (typeof window === "undefined" || window === null)) {
	      this.build();
	    } else {
	      plainMemories = this.loadFromJSON();
	      for (modelName in plainMemories) {
	        plainMemory = plainMemories[modelName];
	        this.memories[modelName] = MemoryResource.restore(plainMemory);
	      }
	    }
	    return this;
	  };

	  MasterDataResource.prototype.initWithData = function(data) {
	    var modelName, plainMemory;
	    for (modelName in data) {
	      plainMemory = data[modelName];
	      this.memories[modelName] = MemoryResource.restore(plainMemory);
	    }
	    return this;
	  };


	  /**
	  load data from JSON file
	  
	  @method loadFromJSON
	  @private
	   */

	  MasterDataResource.prototype.loadFromJSON = function() {
	    var e, error, requireJSON;
	    requireJSON = this.facade.constructor.requireJSON;
	    try {
	      return requireJSON(this.masterJSONPath);
	    } catch (error) {
	      e = error;
	      return console.error("base-domain: [warning] MasterDataResource could not load from path '" + this.masterJSONPath + "'");
	    }
	  };


	  /**
	  Get memory resource of the given modelName
	  @method getMemoryResource
	  @return {MemoryResource}
	   */

	  MasterDataResource.prototype.getMemoryResource = function(modelName) {
	    var base;
	    return (base = this.memories)[modelName] != null ? base[modelName] : base[modelName] = new MemoryResource;
	  };


	  /**
	  Create JSON file from tsv files (**only called by Node.js**)
	  
	  @method build
	   */

	  MasterDataResource.prototype.build = function() {
	    var FixtureLoader, fs;
	    FixtureLoader = __webpack_require__(29);
	    new FixtureLoader(this.facade, this.masterDirPath).load();
	    fs = this.facade.constructor.fs;
	    return fs.writeFileSync(this.masterJSONPath, JSON.stringify(this.toPlainObject(), null, 1));
	  };


	  /**
	  Create plain object
	  
	  @method toPlainObject
	  @return {Object} plainObject
	   */

	  MasterDataResource.prototype.toPlainObject = function() {
	    var memory, modelName, plainObj, ref;
	    plainObj = {};
	    ref = this.memories;
	    for (modelName in ref) {
	      memory = ref[modelName];
	      plainObj[modelName] = memory.toPlainObject();
	    }
	    return plainObj;
	  };

	  return MasterDataResource;

	})();

	module.exports = MasterDataResource;


/***/ },
/* 28 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var MemoryResource, Util;

	Util = __webpack_require__(4);


	/**
	sync memory storage, implements ResourceClientInterface

	@class MemoryResource
	@implements ResourceClientInterface
	 */

	MemoryResource = (function() {
	  MemoryResource.restore = function(obj) {
	    var currentIdNum, memoryResource, pool;
	    pool = obj.pool, currentIdNum = obj.currentIdNum;
	    memoryResource = new MemoryResource();
	    memoryResource.pool = pool;
	    memoryResource.currentIdNum = currentIdNum;
	    return memoryResource;
	  };

	  function MemoryResource() {
	    this.currentIdNum = 1;
	    this.pool = {};
	  }


	  /**
	  Generate id
	  
	  @method generateId
	  @public
	  @param {Object} data
	  @return {String}
	   */

	  MemoryResource.prototype.generateId = function() {
	    var id;
	    id = this.currentIdNum;
	    while (this.pool[id] != null) {
	      id = ++this.currentIdNum;
	    }
	    return id.toString();
	  };


	  /**
	  Create new instance of Model class, saved in database
	  
	  @method create
	  @public
	  @param {Object} data
	  @return {Object}
	   */

	  MemoryResource.prototype.create = function(data) {
	    if (data == null) {
	      data = {};
	    }
	    if (data.id == null) {
	      data.id = this.generateId();
	    }
	    return this.pool[data.id] = Util.clone(data);
	  };


	  /**
	  Update or insert a model instance
	  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
	  
	  @method upsert
	  @public
	  @param {Object} data
	  @return {Object}
	   */

	  MemoryResource.prototype.upsert = function(data) {
	    if (data == null) {
	      data = {};
	    }
	    return this.create(data);
	  };


	  /**
	  Find object by ID.
	  
	  @method findById
	  @public
	  @param {String} id
	  @return {Object}
	   */

	  MemoryResource.prototype.findById = function(id) {
	    return Util.clone(this.pool[id]);
	  };


	  /**
	  Find all model instances that match filter specification.
	  
	  @method find
	  @public
	  @param {Object} filter
	  @return {Array(Object)}
	   */

	  MemoryResource.prototype.find = function(filter) {
	    var id, obj, where;
	    if (filter == null) {
	      filter = {};
	    }
	    where = filter.where;
	    if (!where) {
	      return (function() {
	        var ref, results;
	        ref = this.pool;
	        results = [];
	        for (id in ref) {
	          obj = ref[id];
	          results.push(Util.clone(obj));
	        }
	        return results;
	      }).call(this);
	    }
	    throw new Error('"find" method with "where" is currently unimplemented.');
	  };


	  /**
	  Find one model instance that matches filter specification. Same as find, but limited to one result
	  
	  @method findOne
	  @public
	  @param {Object} filter
	  @return {Object}
	   */

	  MemoryResource.prototype.findOne = function(filter) {
	    return this.find(filter)[0];
	  };


	  /**
	  Destroy model instance
	  
	  @method destroyById
	  @public
	  @param {Object} data
	   */

	  MemoryResource.prototype.destroy = function(data) {
	    return delete this.pool[data != null ? data.id : void 0];
	  };


	  /**
	  Destroy model instance with the specified ID.
	  
	  @method destroyById
	  @public
	  @param {String} id
	   */

	  MemoryResource.prototype.destroyById = function(id) {
	    return delete this.pool[id];
	  };


	  /**
	  Update set of attributes.
	  
	  @method updateAttributes
	  @public
	  @param {Object} data
	  @return {Object}
	   */

	  MemoryResource.prototype.updateAttributes = function(id, data) {
	    var k, pooledData, v;
	    pooledData = this.pool[id];
	    if (pooledData == null) {
	      throw new Error("id " + id + " is not found");
	    }
	    for (k in data) {
	      v = data[k];
	      pooledData[k] = v;
	    }
	    this.pool[id] = pooledData;
	    return Util.clone(pooledData);
	  };


	  /**
	  Count all registered data
	  
	  @method count
	  @return {Number} total
	   */

	  MemoryResource.prototype.count = function() {
	    return Object.keys(this.pool).length;
	  };


	  /**
	  create plain object
	  
	  @method toPlainObject
	  @return {Object} plainObject
	   */

	  MemoryResource.prototype.toPlainObject = function() {
	    return {
	      pool: Util.clone(this.pool),
	      currentIdNum: this.currentIdNum
	    };
	  };

	  return MemoryResource;

	})();

	module.exports = MemoryResource;


/***/ },
/* 29 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var DomainError, EntityPool, FixtureLoader, Scope, Util, debug,
	  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

	EntityPool = __webpack_require__(24);

	DomainError = __webpack_require__(21);

	Util = __webpack_require__(4);

	debug = __webpack_require__(30)('base-domain:fixture-loader');


	/**
	Load fixture data (only works in Node.js)

	@class FixtureLoader
	@module base-domain
	 */

	FixtureLoader = (function() {
	  function FixtureLoader(facade, fixtureDirs) {
	    this.facade = facade;
	    this.fixtureDirs = fixtureDirs != null ? fixtureDirs : [];
	    if (!Array.isArray(this.fixtureDirs)) {
	      this.fixtureDirs = [this.fixtureDirs];
	    }
	    this.entityPool = new EntityPool;
	    this.fixturesByModel = {};
	  }


	  /**
	  @method load
	  @public
	  @param {Object} [options]
	  @param {Boolean} [options.async] if true, returns Promise.
	  @return {EntityPool|Promise(EntityPool)}
	   */

	  FixtureLoader.prototype.load = function(options) {
	    var e, error, ext, file, fixtureDir, fs, fx, j, k, l, len, len1, len2, modelName, modelNames, names, path, ref, ref1, ref2, ref3, ref4, requireFile;
	    if (options == null) {
	      options = {};
	    }
	    ref = this.facade.constructor, fs = ref.fs, requireFile = ref.requireFile;
	    try {
	      modelNames = [];
	      ref1 = this.fixtureDirs;
	      for (j = 0, len = ref1.length; j < len; j++) {
	        fixtureDir = ref1[j];
	        ref2 = fs.readdirSync(fixtureDir + '/data');
	        for (k = 0, len1 = ref2.length; k < len1; k++) {
	          file = ref2[k];
	          ref3 = file.split('.'), modelName = ref3[0], ext = ref3[1];
	          if (ext !== 'coffee' && ext !== 'js' && ext !== 'json') {
	            continue;
	          }
	          path = fixtureDir + '/data/' + file;
	          fx = requireFile(path);
	          fx.path = path;
	          fx.fixtureDir = fixtureDir;
	          this.fixturesByModel[modelName] = fx;
	          modelNames.push(modelName);
	        }
	      }
	      modelNames = this.topoSort(modelNames);
	      names = (ref4 = options.names) != null ? ref4 : modelNames;
	      modelNames = modelNames.filter(function(name) {
	        return indexOf.call(names, name) >= 0;
	      });
	      if (options.async) {
	        return this.saveAsync(modelNames).then((function(_this) {
	          return function() {
	            return _this.entityPool;
	          };
	        })(this));
	      } else {
	        for (l = 0, len2 = modelNames.length; l < len2; l++) {
	          modelName = modelNames[l];
	          this.loadAndSaveModels(modelName);
	        }
	        return this.entityPool;
	      }
	    } catch (error) {
	      e = error;
	      if (options.async) {
	        return Promise.reject(e);
	      } else {
	        throw e;
	      }
	    }
	  };


	  /**
	  @private
	   */

	  FixtureLoader.prototype.saveAsync = function(modelNames) {
	    var modelName;
	    if (!modelNames.length) {
	      return Promise.resolve(true);
	    }
	    modelName = modelNames.shift();
	    return Promise.resolve(this.loadAndSaveModels(modelName)).then((function(_this) {
	      return function() {
	        return _this.saveAsync(modelNames);
	      };
	    })(this));
	  };


	  /**
	  @private
	   */

	  FixtureLoader.prototype.loadAndSaveModels = function(modelName) {
	    var PORTION_SIZE, data, e, error, fx, ids, repo, saveModelsByPortion;
	    fx = this.fixturesByModel[modelName];
	    data = (function() {
	      switch (typeof fx.data) {
	        case 'string':
	          return this.readTSV(fx.fixtureDir, fx.data);
	        case 'function':
	          return fx.data.call(new Scope(this, fx), this.entityPool);
	        case 'object':
	          return fx.data;
	      }
	    }).call(this);
	    try {
	      repo = this.facade.createPreferredRepository(modelName);
	    } catch (error) {
	      e = error;
	      console.error(e.message);
	      return;
	    }
	    if (data == null) {
	      throw new Error("Invalid fixture in model '" + modelName + "'. Check the fixture file: " + fx.path);
	    }
	    ids = Object.keys(data);
	    debug('inserting %s models into %s', ids.length, modelName);
	    PORTION_SIZE = 5;
	    return (saveModelsByPortion = (function(_this) {
	      return function() {
	        var id, idsPortion, obj, results;
	        if (ids.length === 0) {
	          return;
	        }
	        idsPortion = ids.slice(0, PORTION_SIZE);
	        ids = ids.slice(idsPortion.length);
	        results = (function() {
	          var j, len, results1;
	          results1 = [];
	          for (j = 0, len = idsPortion.length; j < len; j++) {
	            id = idsPortion[j];
	            obj = data[id];
	            obj.id = id;
	            results1.push(this.saveModel(repo, obj));
	          }
	          return results1;
	        }).call(_this);
	        if (Util.isPromise(results[0])) {
	          return Promise.all(results).then(function() {
	            return saveModelsByPortion();
	          });
	        } else {
	          return saveModelsByPortion();
	        }
	      };
	    })(this))();
	  };

	  FixtureLoader.prototype.saveModel = function(repo, obj) {
	    var result;
	    result = repo.save(obj, {
	      method: 'create',
	      fixtureInsertion: true,
	      include: {
	        entityPool: this.entityPool
	      }
	    });
	    if (Util.isPromise(result)) {
	      return result.then((function(_this) {
	        return function(entity) {
	          return _this.entityPool.set(entity);
	        };
	      })(this));
	    } else {
	      return this.entityPool.set(result);
	    }
	  };


	  /**
	  topological sort
	  
	  @method topoSort
	  @private
	   */

	  FixtureLoader.prototype.topoSort = function(names) {
	    var add, el, j, k, len, len1, namesWithDependencies, sortedNames, visit, visited;
	    namesWithDependencies = [];
	    for (j = 0, len = names.length; j < len; j++) {
	      el = names[j];
	      (add = (function(_this) {
	        return function(name) {
	          var depname, fx, k, len1, ref, ref1, results1;
	          if (indexOf.call(namesWithDependencies, name) >= 0) {
	            return;
	          }
	          namesWithDependencies.push(name);
	          fx = _this.fixturesByModel[name];
	          if (fx == null) {
	            throw new DomainError('base-domain:modelNotFound', "model '" + name + "' is not found. It might be written in some 'dependencies' property.");
	          }
	          ref1 = (ref = fx.dependencies) != null ? ref : [];
	          results1 = [];
	          for (k = 0, len1 = ref1.length; k < len1; k++) {
	            depname = ref1[k];
	            results1.push(add(depname));
	          }
	          return results1;
	        };
	      })(this))(el);
	    }
	    visited = {};
	    sortedNames = [];
	    for (k = 0, len1 = namesWithDependencies.length; k < len1; k++) {
	      el = namesWithDependencies[k];
	      (visit = (function(_this) {
	        return function(name, ancestors) {
	          var depname, fx, l, len2, ref, ref1;
	          fx = _this.fixturesByModel[name];
	          if (visited[name] != null) {
	            return;
	          }
	          ancestors.push(name);
	          visited[name] = true;
	          ref1 = (ref = fx.dependencies) != null ? ref : [];
	          for (l = 0, len2 = ref1.length; l < len2; l++) {
	            depname = ref1[l];
	            if (indexOf.call(ancestors, depname) >= 0) {
	              throw new DomainError('base-domain:dependencyLoop', 'dependency chain is making loop');
	            }
	            visit(depname, ancestors.slice());
	          }
	          return sortedNames.push(name);
	        };
	      })(this))(el, []);
	    }
	    return sortedNames;
	  };


	  /*
	  read TSV, returns model data
	  
	  @method readTSV
	  @private
	   */

	  FixtureLoader.prototype.readTSVContent = function(txt) {
	    var csvParse, data, i, id, j, k, len, len1, name, names, obj, objs, tsv, value;
	    csvParse = this.facade.constructor.csvParse;
	    tsv = csvParse(txt, {
	      delimiter: '\t'
	    });
	    names = tsv.shift();
	    names.shift();
	    objs = {};
	    for (j = 0, len = tsv.length; j < len; j++) {
	      data = tsv[j];
	      obj = {};
	      id = data.shift();
	      obj.id = id;
	      if (!id) {
	        break;
	      }
	      for (i = k = 0, len1 = names.length; k < len1; i = ++k) {
	        name = names[i];
	        if (!name) {
	          break;
	        }
	        value = data[i];
	        if (value.match(/^[0-9]+$/)) {
	          value = Number(value);
	        }
	        obj[name] = value;
	      }
	      objs[obj.id] = obj;
	    }
	    return objs;
	  };


	  /**
	  read TSV, returns model data
	  
	  @method readTSV
	  @private
	   */

	  FixtureLoader.prototype.readTSV = function(fixtureDir, file) {
	    var fs;
	    fs = this.facade.constructor.fs;
	    return this.readTSVContent(fs.readFileSync(fixtureDir + '/tsvs/' + file, 'utf8'));
	  };

	  return FixtureLoader;

	})();


	/**
	'this' property in fixture's data function

	this.readTSV('xxx.tsv') is available

	    module.exports = {
	        data: function(entityPool) {
	            this.readTSV('model-name.tsv');
	        }
	    };

	@class Scope
	@private
	 */

	Scope = (function() {
	  function Scope(loader, fx1) {
	    this.loader = loader;
	    this.fx = fx1;
	  }


	  /**
	  @method readTSV
	  @param {String} filename filename (directory is automatically set)
	  @return {Object} tsv contents
	   */

	  Scope.prototype.readTSV = function(filename) {
	    return this.loader.readTSV(this.fx.fixtureDir, filename);
	  };

	  return Scope;

	})();

	module.exports = FixtureLoader;


/***/ },
/* 30 */
/***/ function(module, exports, __webpack_require__) {

	
	/**
	 * This is the web browser implementation of `debug()`.
	 *
	 * Expose `debug()` as the module.
	 */

	exports = module.exports = __webpack_require__(31);
	exports.log = log;
	exports.formatArgs = formatArgs;
	exports.save = save;
	exports.load = load;
	exports.useColors = useColors;
	exports.storage = 'undefined' != typeof chrome
	               && 'undefined' != typeof chrome.storage
	                  ? chrome.storage.local
	                  : localstorage();

	/**
	 * Colors.
	 */

	exports.colors = [
	  'lightseagreen',
	  'forestgreen',
	  'goldenrod',
	  'dodgerblue',
	  'darkorchid',
	  'crimson'
	];

	/**
	 * Currently only WebKit-based Web Inspectors, Firefox >= v31,
	 * and the Firebug extension (any Firefox version) are known
	 * to support "%c" CSS customizations.
	 *
	 * TODO: add a `localStorage` variable to explicitly enable/disable colors
	 */

	function useColors() {
	  // is webkit? http://stackoverflow.com/a/16459606/376773
	  return ('WebkitAppearance' in document.documentElement.style) ||
	    // is firebug? http://stackoverflow.com/a/398120/376773
	    (window.console && (console.firebug || (console.exception && console.table))) ||
	    // is firefox >= v31?
	    // https://developer.mozilla.org/en-US/docs/Tools/Web_Console#Styling_messages
	    (navigator.userAgent.toLowerCase().match(/firefox\/(\d+)/) && parseInt(RegExp.$1, 10) >= 31);
	}

	/**
	 * Map %j to `JSON.stringify()`, since no Web Inspectors do that by default.
	 */

	exports.formatters.j = function(v) {
	  return JSON.stringify(v);
	};


	/**
	 * Colorize log arguments if enabled.
	 *
	 * @api public
	 */

	function formatArgs() {
	  var args = arguments;
	  var useColors = this.useColors;

	  args[0] = (useColors ? '%c' : '')
	    + this.namespace
	    + (useColors ? ' %c' : ' ')
	    + args[0]
	    + (useColors ? '%c ' : ' ')
	    + '+' + exports.humanize(this.diff);

	  if (!useColors) return args;

	  var c = 'color: ' + this.color;
	  args = [args[0], c, 'color: inherit'].concat(Array.prototype.slice.call(args, 1));

	  // the final "%c" is somewhat tricky, because there could be other
	  // arguments passed either before or after the %c, so we need to
	  // figure out the correct index to insert the CSS into
	  var index = 0;
	  var lastC = 0;
	  args[0].replace(/%[a-z%]/g, function(match) {
	    if ('%%' === match) return;
	    index++;
	    if ('%c' === match) {
	      // we only are interested in the *last* %c
	      // (the user may have provided their own)
	      lastC = index;
	    }
	  });

	  args.splice(lastC, 0, c);
	  return args;
	}

	/**
	 * Invokes `console.log()` when available.
	 * No-op when `console.log` is not a "function".
	 *
	 * @api public
	 */

	function log() {
	  // this hackery is required for IE8/9, where
	  // the `console.log` function doesn't have 'apply'
	  return 'object' === typeof console
	    && console.log
	    && Function.prototype.apply.call(console.log, console, arguments);
	}

	/**
	 * Save `namespaces`.
	 *
	 * @param {String} namespaces
	 * @api private
	 */

	function save(namespaces) {
	  try {
	    if (null == namespaces) {
	      exports.storage.removeItem('debug');
	    } else {
	      exports.storage.debug = namespaces;
	    }
	  } catch(e) {}
	}

	/**
	 * Load `namespaces`.
	 *
	 * @return {String} returns the previously persisted debug modes
	 * @api private
	 */

	function load() {
	  var r;
	  try {
	    r = exports.storage.debug;
	  } catch(e) {}
	  return r;
	}

	/**
	 * Enable namespaces listed in `localStorage.debug` initially.
	 */

	exports.enable(load());

	/**
	 * Localstorage attempts to return the localstorage.
	 *
	 * This is necessary because safari throws
	 * when a user disables cookies/localstorage
	 * and you attempt to access it.
	 *
	 * @return {LocalStorage}
	 * @api private
	 */

	function localstorage(){
	  try {
	    return window.localStorage;
	  } catch (e) {}
	}


/***/ },
/* 31 */
/***/ function(module, exports, __webpack_require__) {

	
	/**
	 * This is the common logic for both the Node.js and web browser
	 * implementations of `debug()`.
	 *
	 * Expose `debug()` as the module.
	 */

	exports = module.exports = debug;
	exports.coerce = coerce;
	exports.disable = disable;
	exports.enable = enable;
	exports.enabled = enabled;
	exports.humanize = __webpack_require__(32);

	/**
	 * The currently active debug mode names, and names to skip.
	 */

	exports.names = [];
	exports.skips = [];

	/**
	 * Map of special "%n" handling functions, for the debug "format" argument.
	 *
	 * Valid key names are a single, lowercased letter, i.e. "n".
	 */

	exports.formatters = {};

	/**
	 * Previously assigned color.
	 */

	var prevColor = 0;

	/**
	 * Previous log timestamp.
	 */

	var prevTime;

	/**
	 * Select a color.
	 *
	 * @return {Number}
	 * @api private
	 */

	function selectColor() {
	  return exports.colors[prevColor++ % exports.colors.length];
	}

	/**
	 * Create a debugger with the given `namespace`.
	 *
	 * @param {String} namespace
	 * @return {Function}
	 * @api public
	 */

	function debug(namespace) {

	  // define the `disabled` version
	  function disabled() {
	  }
	  disabled.enabled = false;

	  // define the `enabled` version
	  function enabled() {

	    var self = enabled;

	    // set `diff` timestamp
	    var curr = +new Date();
	    var ms = curr - (prevTime || curr);
	    self.diff = ms;
	    self.prev = prevTime;
	    self.curr = curr;
	    prevTime = curr;

	    // add the `color` if not set
	    if (null == self.useColors) self.useColors = exports.useColors();
	    if (null == self.color && self.useColors) self.color = selectColor();

	    var args = Array.prototype.slice.call(arguments);

	    args[0] = exports.coerce(args[0]);

	    if ('string' !== typeof args[0]) {
	      // anything else let's inspect with %o
	      args = ['%o'].concat(args);
	    }

	    // apply any `formatters` transformations
	    var index = 0;
	    args[0] = args[0].replace(/%([a-z%])/g, function(match, format) {
	      // if we encounter an escaped % then don't increase the array index
	      if (match === '%%') return match;
	      index++;
	      var formatter = exports.formatters[format];
	      if ('function' === typeof formatter) {
	        var val = args[index];
	        match = formatter.call(self, val);

	        // now we need to remove `args[index]` since it's inlined in the `format`
	        args.splice(index, 1);
	        index--;
	      }
	      return match;
	    });

	    if ('function' === typeof exports.formatArgs) {
	      args = exports.formatArgs.apply(self, args);
	    }
	    var logFn = enabled.log || exports.log || console.log.bind(console);
	    logFn.apply(self, args);
	  }
	  enabled.enabled = true;

	  var fn = exports.enabled(namespace) ? enabled : disabled;

	  fn.namespace = namespace;

	  return fn;
	}

	/**
	 * Enables a debug mode by namespaces. This can include modes
	 * separated by a colon and wildcards.
	 *
	 * @param {String} namespaces
	 * @api public
	 */

	function enable(namespaces) {
	  exports.save(namespaces);

	  var split = (namespaces || '').split(/[\s,]+/);
	  var len = split.length;

	  for (var i = 0; i < len; i++) {
	    if (!split[i]) continue; // ignore empty strings
	    namespaces = split[i].replace(/\*/g, '.*?');
	    if (namespaces[0] === '-') {
	      exports.skips.push(new RegExp('^' + namespaces.substr(1) + '$'));
	    } else {
	      exports.names.push(new RegExp('^' + namespaces + '$'));
	    }
	  }
	}

	/**
	 * Disable debug output.
	 *
	 * @api public
	 */

	function disable() {
	  exports.enable('');
	}

	/**
	 * Returns true if the given mode name is enabled, false otherwise.
	 *
	 * @param {String} name
	 * @return {Boolean}
	 * @api public
	 */

	function enabled(name) {
	  var i, len;
	  for (i = 0, len = exports.skips.length; i < len; i++) {
	    if (exports.skips[i].test(name)) {
	      return false;
	    }
	  }
	  for (i = 0, len = exports.names.length; i < len; i++) {
	    if (exports.names[i].test(name)) {
	      return true;
	    }
	  }
	  return false;
	}

	/**
	 * Coerce `val`.
	 *
	 * @param {Mixed} val
	 * @return {Mixed}
	 * @api private
	 */

	function coerce(val) {
	  if (val instanceof Error) return val.stack || val.message;
	  return val;
	}


/***/ },
/* 32 */
/***/ function(module, exports) {

	/**
	 * Helpers.
	 */

	var s = 1000;
	var m = s * 60;
	var h = m * 60;
	var d = h * 24;
	var y = d * 365.25;

	/**
	 * Parse or format the given `val`.
	 *
	 * Options:
	 *
	 *  - `long` verbose formatting [false]
	 *
	 * @param {String|Number} val
	 * @param {Object} options
	 * @return {String|Number}
	 * @api public
	 */

	module.exports = function(val, options){
	  options = options || {};
	  if ('string' == typeof val) return parse(val);
	  return options.long
	    ? long(val)
	    : short(val);
	};

	/**
	 * Parse the given `str` and return milliseconds.
	 *
	 * @param {String} str
	 * @return {Number}
	 * @api private
	 */

	function parse(str) {
	  str = '' + str;
	  if (str.length > 10000) return;
	  var match = /^((?:\d+)?\.?\d+) *(milliseconds?|msecs?|ms|seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h|days?|d|years?|yrs?|y)?$/i.exec(str);
	  if (!match) return;
	  var n = parseFloat(match[1]);
	  var type = (match[2] || 'ms').toLowerCase();
	  switch (type) {
	    case 'years':
	    case 'year':
	    case 'yrs':
	    case 'yr':
	    case 'y':
	      return n * y;
	    case 'days':
	    case 'day':
	    case 'd':
	      return n * d;
	    case 'hours':
	    case 'hour':
	    case 'hrs':
	    case 'hr':
	    case 'h':
	      return n * h;
	    case 'minutes':
	    case 'minute':
	    case 'mins':
	    case 'min':
	    case 'm':
	      return n * m;
	    case 'seconds':
	    case 'second':
	    case 'secs':
	    case 'sec':
	    case 's':
	      return n * s;
	    case 'milliseconds':
	    case 'millisecond':
	    case 'msecs':
	    case 'msec':
	    case 'ms':
	      return n;
	  }
	}

	/**
	 * Short format for `ms`.
	 *
	 * @param {Number} ms
	 * @return {String}
	 * @api private
	 */

	function short(ms) {
	  if (ms >= d) return Math.round(ms / d) + 'd';
	  if (ms >= h) return Math.round(ms / h) + 'h';
	  if (ms >= m) return Math.round(ms / m) + 'm';
	  if (ms >= s) return Math.round(ms / s) + 's';
	  return ms + 'ms';
	}

	/**
	 * Long format for `ms`.
	 *
	 * @param {Number} ms
	 * @return {String}
	 * @api private
	 */

	function long(ms) {
	  return plural(ms, d, 'day')
	    || plural(ms, h, 'hour')
	    || plural(ms, m, 'minute')
	    || plural(ms, s, 'second')
	    || ms + ' ms';
	}

	/**
	 * Pluralization helper.
	 */

	function plural(ms, n, name) {
	  if (ms < n) return;
	  if (ms < n * 1.5) return Math.floor(ms / n) + ' ' + name;
	  return Math.ceil(ms / n) + ' ' + name + 's';
	}


/***/ },
/* 33 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseModule, Util,
	  slice = [].slice;

	Util = __webpack_require__(4);


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
	  
	  @deprecated just call facade property
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
	    var e, error, requireFile;
	    requireFile = this.facade.constructor.requireFile;
	    try {
	      return requireFile(this.path + '/' + fullName);
	    } catch (error) {
	      e = error;
	      return null;
	    }
	  };

	  return BaseModule;

	})();

	module.exports = BaseModule;


/***/ },
/* 34 */
/***/ function(module, exports, __webpack_require__) {

	var BaseModule, CoreModule,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	BaseModule = __webpack_require__(33);

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


/***/ },
/* 35 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(__dirname) {'use strict';
	var DomainError, Fixture, FixtureLoader, debug;

	DomainError = __webpack_require__(21);

	FixtureLoader = __webpack_require__(29);

	debug = null;


	/**
	load data from directory and generates fixtures
	only available in Node.js

	@class Fixture
	@module base-domain
	 */

	Fixture = (function() {

	  /**
	  @constructor
	  @param {Object} [options]
	  @param {String|Array} [options.dirname='./fixtures'] director(y|ies) to have fixture files. /data, /tsvs should be included in the directory.
	  @param {String} [options.debug] if true, shows debug log
	   */
	  function Fixture(facade, options) {
	    var debugMode, ref;
	    this.facade = facade;
	    if (options == null) {
	      options = {};
	    }
	    debugMode = (ref = options.debug) != null ? ref : !!this.facade.debug;
	    if (debugMode) {
	      __webpack_require__(30).enable('base-domain:fixture');
	    }
	    debug = __webpack_require__(30)('base-domain:fixture');
	    this.dirnames = options.dirname != null ? Array.isArray(options.dirname) ? options.dirname : [options.dirname] : [__dirname + '/fixtures'];
	  }


	  /**
	  inserts data to datasource
	  
	  @method insert
	  @param {Array} names list of fixture models to insert data
	  @public
	  @return {Promise(EntityPool)}
	   */

	  Fixture.prototype.insert = function(names) {
	    return new FixtureLoader(this.facade, this.dirnames).load({
	      async: true,
	      names: names
	    });
	  };

	  return Fixture;

	})();

	module.exports = Fixture;

	/* WEBPACK VAR INJECTION */}.call(exports, "/"))

/***/ },
/* 36 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var Base, BaseService,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty,
	  slice = [].slice;

	Base = __webpack_require__(20);


	/**
	Base service class of DDD pattern.

	the parent "Base" class just simply gives `this.facade` property

	@class BaseService
	@extends Base
	@module base-domain
	 */

	BaseService = (function(superClass) {
	  extend(BaseService, superClass);

	  function BaseService() {
	    var i, params, root;
	    params = 2 <= arguments.length ? slice.call(arguments, 0, i = arguments.length - 1) : (i = 0, []), root = arguments[i++];
	    BaseService.__super__.constructor.call(this, root);
	  }

	  return BaseService;

	})(Base);

	module.exports = BaseService;


/***/ },
/* 37 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseModel, Entity,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	BaseModel = __webpack_require__(18);


	/**
	Base model class with "id" column

	@class Entity
	@extends BaseModel
	@module base-domain
	 */

	Entity = (function(superClass) {
	  extend(Entity, superClass);


	  /**
	  primary key for the model
	  
	  @property id
	  @type {String|Number}
	   */

	  function Entity() {
	    this.id = null;
	    Entity.__super__.constructor.apply(this, arguments);
	  }

	  Entity.isEntity = true;


	  /**
	  check equality
	  
	  @method equals
	  @param {Entity} entity
	  @return {Boolean}
	   */

	  Entity.prototype.equals = function(entity) {
	    if (this.id == null) {
	      return false;
	    }
	    return Entity.__super__.equals.call(this, entity) && this.id === entity.id;
	  };

	  return Entity;

	})(BaseModel);

	module.exports = Entity;


/***/ },
/* 38 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var AggregateRoot, Entity, MemoryResource,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty,
	  slice = [].slice;

	Entity = __webpack_require__(37);

	MemoryResource = __webpack_require__(28);


	/**

	@class AggregateRoot
	@implements RootInterface
	@extends Entity
	@module base-domain
	 */

	AggregateRoot = (function(superClass) {
	  extend(AggregateRoot, superClass);


	  /**
	  is root (to identify RootInterface)
	  @property {Boolean} isRoot
	  @static
	   */

	  AggregateRoot.isRoot = true;


	  /**
	  key: modelName, value: MemoryResource
	  
	  @property {Object(MemoryResource)} memories
	   */

	  function AggregateRoot() {
	    Object.defineProperty(this, 'memories', {
	      value: {}
	    });
	    AggregateRoot.__super__.constructor.apply(this, arguments);
	  }


	  /**
	  create a factory instance
	  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
	  
	  @method createFactory
	  @param {String} modFirstName
	  @return {BaseFactory}
	   */

	  AggregateRoot.prototype.createFactory = function() {
	    var modFirstName, params;
	    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
	    return this.facade.__create(modFirstName, 'factory', params, this);
	  };


	  /**
	  create a repository instance
	  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
	  
	  @method createRepository
	  @param {String} modFirstName
	  @return {BaseRepository}
	   */

	  AggregateRoot.prototype.createRepository = function() {
	    var modFirstName, params;
	    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
	    return this.facade.__create(modFirstName, 'repository', params, this);
	  };


	  /**
	  create an instance of the given modFirstName using obj
	  if obj is null or undefined, empty object will be created.
	  
	  @method createModel
	  @param {String} modFirstName
	  @param {Object} obj
	  @param {Object} [options]
	  @return {BaseModel}
	   */

	  AggregateRoot.prototype.createModel = function(modFirstName, obj, options) {
	    return this.facade.createModel(modFirstName, obj, options, this);
	  };


	  /**
	  create a service instance
	  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service
	  
	  @method createService
	  @param {String} modFirstName
	  @return {BaseRepository}
	   */

	  AggregateRoot.prototype.createService = function() {
	    var modFirstName, params;
	    modFirstName = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
	    return this.facade.__create(modFirstName, 'service', params, this);
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

	  AggregateRoot.prototype.createPreferredRepository = function() {
	    var firstName, options, params;
	    firstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
	    return this.facade.createPreferred(firstName, 'repository', options, params, this);
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

	  AggregateRoot.prototype.createPreferredFactory = function() {
	    var firstName, options, params;
	    firstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
	    if (options == null) {
	      options = {};
	    }
	    if (options.noParent == null) {
	      options.noParent = true;
	    }
	    return this.facade.createPreferred(firstName, 'factory', options, params, this);
	  };


	  /**
	  create a preferred service instance
	  3rd, 4th ... arguments are the params to pass to the constructor of the factory
	  
	  @method createPreferredService
	  @param {String} firstName
	  @param {Object} [options]
	  @param {Object} [options.noParent=true] if true, stop requiring parent class
	  @return {BaseService}
	   */

	  AggregateRoot.prototype.createPreferredService = function() {
	    var firstName, options, params;
	    firstName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
	    if (options == null) {
	      options = {};
	    }
	    if (options.noParent == null) {
	      options.noParent = true;
	    }
	    return this.facade.createPreferred(firstName, 'service', options, params, this);
	  };


	  /**
	  get or create a memory resource to save to @memories
	  Only called from LocalRepository
	  
	  @method useMemoryResource
	  @param {String} modelName
	  @return {MemoryResource}
	   */

	  AggregateRoot.prototype.useMemoryResource = function(modelName) {
	    var base;
	    return (base = this.memories)[modelName] != null ? base[modelName] : base[modelName] = new MemoryResource();
	  };


	  /**
	  create plain object without relational entities
	  plainize memoryResources
	  
	  @method toPlainObject
	  @return {Object} plainObject
	   */

	  AggregateRoot.prototype.toPlainObject = function() {
	    var memoryResource, modelName, plain, ref;
	    plain = AggregateRoot.__super__.toPlainObject.apply(this, arguments);
	    plain.memories = {};
	    ref = this.memories;
	    for (modelName in ref) {
	      memoryResource = ref[modelName];
	      plain.memories[modelName] = memoryResource.toPlainObject();
	    }
	    return plain;
	  };


	  /**
	  set value to prop
	  set memories
	  
	  @method set
	   */

	  AggregateRoot.prototype.set = function(k, memories) {
	    var modelName, plainMemory;
	    if (k !== 'memories') {
	      return AggregateRoot.__super__.set.apply(this, arguments);
	    }
	    for (modelName in memories) {
	      plainMemory = memories[modelName];
	      this.memories[modelName] = MemoryResource.restore(plainMemory);
	    }
	    return this;
	  };

	  return AggregateRoot;

	})(Entity);

	module.exports = AggregateRoot;


/***/ },
/* 39 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var Base, BaseFactory, GeneralFactory,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	Base = __webpack_require__(20);

	GeneralFactory = __webpack_require__(14);


	/**
	Base factory class of DDD pattern.

	create instance of model

	@class BaseFactory
	@extends Base
	@implements FactoryInterface
	@module base-domain
	 */

	BaseFactory = (function(superClass) {
	  extend(BaseFactory, superClass);


	  /**
	  model name to handle
	  
	  @property modelName
	  @static
	  @protected
	  @type String
	   */

	  BaseFactory.modelName = null;

	  BaseFactory.prototype.getModelName = function() {
	    var ref;
	    return (ref = this.constructor.modelName) != null ? ref : this.constructor.getName().slice(0, -'-factory'.length);
	  };


	  /**
	  constructor
	  
	  @constructor
	  @params {RootInterface} root
	   */

	  function BaseFactory(root) {
	    var modelName;
	    BaseFactory.__super__.constructor.call(this, root);
	    modelName = this.getModelName();
	    this.gf = new GeneralFactory(modelName, this.root);
	  }

	  BaseFactory._ModelClass;

	  BaseFactory.prototype.getModelClass = function() {
	    return this._ModelClass != null ? this._ModelClass : this._ModelClass = this.gf.getModelClass();
	  };


	  /**
	  create empty model instance
	  
	  @method createEmpty
	  @return {BaseModel}
	   */

	  BaseFactory.prototype.createEmpty = function() {
	    return this.gf.createEmpty();
	  };


	  /**
	  create instance of model class by plain object
	  
	  for each prop, values are set by Model#set(prop, value)
	  
	  @method createFromObject
	  @public
	  @param {Object} obj
	  @param {Object} [options={}]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include submodels asynchronously
	  @param {Array(String)} [options.include.props] include submodels of given props
	  @return {BaseModel} model
	   */

	  BaseFactory.prototype.createFromObject = function(obj, options) {
	    if (options == null) {
	      options = {};
	    }
	    return this.gf.createFromObject(obj, options);
	  };


	  /**
	  create model list
	  
	  @method createList
	  @public
	  @param {String} listModelName model name of list
	  @param {any} obj
	  @param {Object} [options={}]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include submodels asynchronously
	  @param {Array(String)} [options.include.props] include submodels of given props
	  @return {BaseList} list
	   */

	  BaseFactory.prototype.createList = function(listModelName, obj, options) {
	    return this.gf.createList(listModelName, obj, options);
	  };


	  /**
	  create model dict
	  
	  @method createDict
	  @public
	  @param {String} dictModelName model name of dict
	  @param {any} obj
	  @param {Object} [options={}]
	  @param {Object} [options.include] options to pass to Includer
	  @param {Object} [options.include.async=false] include submodels asynchronously
	  @param {Array(String)} [options.include.props] include submodels of given props
	  @return {BaseDict} dict
	   */

	  BaseFactory.prototype.createDict = function(dictModelName, obj, options) {
	    return this.gf.createDict(dictModelName, obj, options);
	  };

	  return BaseFactory;

	})(Base);

	module.exports = BaseFactory;


/***/ },
/* 40 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var Base, BaseRepository, Entity, GeneralFactory, isPromise,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	Base = __webpack_require__(20);

	Entity = __webpack_require__(37);

	GeneralFactory = __webpack_require__(14);

	isPromise = __webpack_require__(4).isPromise;


	/**
	Base repository class of DDD pattern.
	Responsible for perpetuation of models.
	BaseRepository has a client, which access to data resource (RDB, NoSQL, memory, etc...)

	the parent "Base" class just simply gives `this.facade` property

	@class BaseRepository
	@extends Base
	@module base-domain
	 */

	BaseRepository = (function(superClass) {
	  extend(BaseRepository, superClass);


	  /**
	  model name to handle
	  
	  @property modelName
	  @static
	  @protected
	  @type String
	   */

	  BaseRepository.modelName = null;

	  BaseRepository.prototype.getModelName = function() {
	    var ref;
	    return (ref = this.constructor.modelName) != null ? ref : this.constructor.getName().slice(0, -'-repository'.length);
	  };


	  /**
	  client accessing to data resource (RDB, NoSQL, memory, etc...)
	  
	  mock object is input by default.
	  Extenders must set this property to achieve perpetuation
	  
	  @property client
	  @abstract
	  @protected
	  @type ResourceClientInterface
	   */

	  BaseRepository.prototype.client = null;


	  /**
	  constructor
	  
	  @constructor
	  @params {RootInterface} root
	  @return
	   */

	  function BaseRepository(root) {
	    var modelName;
	    BaseRepository.__super__.constructor.call(this, root);
	    modelName = this.getModelName();

	    /**
	    factory of the entity.
	    
	    @property {FactoryInterface} factory
	     */
	    this.factory = GeneralFactory.create(modelName, this.root);
	    if (!((this.factory.getModelClass().prototype) instanceof Entity)) {
	      this.error('base-domain:repositoryWithNonEntity', "cannot define repository to non-entity: '" + modelName + "'");
	    }
	  }


	  /**
	  get model class this factory handles
	  
	  @method getModelClass
	  @return {Class}
	   */

	  BaseRepository.prototype.getModelClass = function() {
	    return this.factory.getModelClass();
	  };


	  /**
	  returns Promise or the result of given function
	  @return {any}
	  @protected
	   */

	  BaseRepository.prototype.resolve = function(result, fn) {
	    if (isPromise(result)) {
	      return result.then((function(_this) {
	        return function(obj) {
	          return fn.call(_this, obj);
	        };
	      })(this));
	    } else {
	      return fn.call(this, result);
	    }
	  };


	  /**
	  Update or insert a model instance
	  
	  @method save
	  @public
	  @param {Entity|Object} entity
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity|Promise(Entity)} entity (the same instance from input, if entity given,)
	   */

	  BaseRepository.prototype.save = function(entity, options) {
	    var client, data, method;
	    if (options == null) {
	      options = {};
	    }
	    client = options.client;
	    delete options.client;
	    if (!(entity instanceof Entity)) {
	      entity = this.factory.createFromObject(entity, options);
	    }
	    if (client == null) {
	      client = this.client;
	    }
	    data = entity.toPlainObject();
	    this.appendTimeStamp(data);
	    method = (function() {
	      switch (options.method) {
	        case 'upsert':
	        case 'create':
	          return options.method;
	        default:
	          return 'upsert';
	      }
	    })();
	    return this.resolve(client[method](data), function(obj) {
	      var newEntity;
	      newEntity = this.createFromResult(obj, options);
	      if (this.getModelClass().isImmutable) {
	        return newEntity;
	      } else {
	        return entity.inherit(newEntity);
	      }
	    });
	  };


	  /**
	  get entity by id.
	  
	  @method get
	  @public
	  @param {String|Number} id
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity|Promise(Entity)} entity
	   */

	  BaseRepository.prototype.get = function(id, options) {
	    var client;
	    if (options == null) {
	      options = {};
	    }
	    client = options.client;
	    delete options.client;
	    if (client == null) {
	      client = this.client;
	    }
	    return this.resolve(client.findById(id), function(obj) {
	      return this.createFromResult(obj, options);
	    });
	  };


	  /**
	  alias for get()
	  
	  @method getById
	  @public
	  @param {String|Number} id
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity|Promise(Entity)} entity
	   */

	  BaseRepository.prototype.getById = function(id, options) {
	    return this.get(id, options);
	  };


	  /**
	  get entities by id.
	  
	  @method getByIds
	  @public
	  @param {Array|(String|Number)} ids
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Array(Entity)|Promise(Array(Entity))} entities
	   */

	  BaseRepository.prototype.getByIds = function(ids, options) {
	    var existence, id, results;
	    results = (function() {
	      var i, len, results1;
	      results1 = [];
	      for (i = 0, len = ids.length; i < len; i++) {
	        id = ids[i];
	        results1.push(this.get(id, options));
	      }
	      return results1;
	    }).call(this);
	    existence = function(val) {
	      return val != null;
	    };
	    if (isPromise(results[0])) {
	      return Promise.all(results).then(function(models) {
	        return models.filter(existence);
	      });
	    } else {
	      return results.filter(existence);
	    }
	  };


	  /**
	  get all entities
	  
	  @method getAll
	  @return {Array(Entity)|Promise(Array(Entity))} array of entities
	   */

	  BaseRepository.prototype.getAll = function() {
	    return this.query({});
	  };


	  /**
	  Find all model instances that match params
	  
	  @method query
	  @public
	  @param {Object} [params] query parameters
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Array(Entity)|Promise(Array(Entity))} array of entities
	   */

	  BaseRepository.prototype.query = function(params, options) {
	    var client;
	    if (options == null) {
	      options = {};
	    }
	    client = options.client;
	    delete options.client;
	    if (client == null) {
	      client = this.client;
	    }
	    return this.resolve(client.find(params), function(objs) {
	      return this.createFromQueryResults(params, objs, options);
	    });
	  };


	  /**
	  Find one model instance that matches params, Same as query, but limited to one result
	  
	  @method singleQuery
	  @public
	  @param {Object} [params] query parameters
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity|Promise(Entity)} entity
	   */

	  BaseRepository.prototype.singleQuery = function(params, options) {
	    var client;
	    if (options == null) {
	      options = {};
	    }
	    client = options.client;
	    delete options.client;
	    if (client == null) {
	      client = this.client;
	    }
	    return this.resolve(client.findOne(params), function(obj) {
	      return this.createFromResult(obj, options);
	    });
	  };


	  /**
	  Destroy the given entity (which must have "id" value)
	  
	  @method delete
	  @public
	  @param {Entity} entity
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Boolean|Promise(Boolean)} isDeleted
	   */

	  BaseRepository.prototype["delete"] = function(entity, options) {
	    var client;
	    if (options == null) {
	      options = {};
	    }
	    client = options.client;
	    delete options.client;
	    if (client == null) {
	      client = this.client;
	    }
	    return this.resolve(client.destroy(entity), function() {
	      return true;
	    });
	  };


	  /**
	  Update set of attributes.
	  
	  @method update
	  @public
	  @param {String|Number} id id of the entity to update
	  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity|Promise(Entity)} updated entity
	   */

	  BaseRepository.prototype.update = function(id, data, options) {
	    var client, isUpdate;
	    if (options == null) {
	      options = {};
	    }
	    client = options.client;
	    delete options.client;
	    if (data instanceof Entity) {
	      throw this.error('base-domain:updateWithModelInhihited', "update entity with BaseRepository#update() is not allowed.\nuse BaseRepository#save(entity) instead");
	    }
	    if (client == null) {
	      client = this.client;
	    }
	    this.appendTimeStamp(data, isUpdate = true);
	    return this.resolve(client.updateAttributes(id, data), function(obj) {
	      return this.createFromResult(obj, options);
	    });
	  };


	  /**
	  Update set of attributes and returns newly-updated props (other than `props`)
	  
	  @method updateProps
	  @public
	  @param {Entity} entity
	  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Object} updated props
	   */

	  BaseRepository.prototype.updateProps = function(entity, props, options) {
	    var client, id, isUpdate;
	    if (props == null) {
	      props = {};
	    }
	    if (options == null) {
	      options = {};
	    }
	    id = entity.id;
	    if (id == null) {
	      throw this.error('EntityMustContainId');
	    }
	    client = options.client;
	    delete options.client;
	    if (client == null) {
	      client = this.client;
	    }
	    this.appendTimeStamp(props, isUpdate = true);
	    return this.resolve(client.updateAttributes(id, props), function(obj) {
	      return entity.getDiff(obj, {
	        ignores: Object.keys(props)
	      });
	    });
	  };


	  /**
	  add createdAt, updatedAt to given data
	  - createdAt will not be overriden if already set.
	  - updatedAt will be overriden for each time
	  
	  @method appendTimeStamp
	  @protected
	  @param {Object} data
	  @param {Boolean} isUpdate true when updating
	  @return {Object} data
	   */

	  BaseRepository.prototype.appendTimeStamp = function(data, isUpdate) {
	    var modelProps, now, propCreatedAt, propUpdatedAt;
	    if (isUpdate == null) {
	      isUpdate = false;
	    }
	    modelProps = this.facade.getModelProps(this.getModelName());
	    propCreatedAt = modelProps.createdAt;
	    propUpdatedAt = modelProps.updatedAt;
	    now = new Date().toISOString();
	    if (propCreatedAt && !isUpdate) {
	      if (data[propCreatedAt] == null) {
	        data[propCreatedAt] = now;
	      }
	    }
	    if (propUpdatedAt) {
	      data[propUpdatedAt] = now;
	    }
	    return data;
	  };


	  /**
	  Create model instance from result from client
	  
	  @method createFromResult
	  @protected
	  @param {Object} obj
	  @param {Object} [options]
	  @return {BaseModel} model
	   */

	  BaseRepository.prototype.createFromResult = function(obj, options) {
	    return this.factory.createFromObject(obj, options);
	  };


	  /**
	  Create model instances from query results
	  
	  @method createFromQueryResults
	  @protected
	  @param {Object} params
	  @param {Array(Object)} objs
	  @param {Object} [options]
	  @return {Array(BaseModel)} models
	   */

	  BaseRepository.prototype.createFromQueryResults = function(params, objs, options) {
	    var i, len, obj, results1;
	    results1 = [];
	    for (i = 0, len = objs.length; i < len; i++) {
	      obj = objs[i];
	      results1.push(this.createFromResult(obj, options));
	    }
	    return results1;
	  };

	  return BaseRepository;

	})(Base);

	module.exports = BaseRepository;


/***/ },
/* 41 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseRepository, BaseSyncRepository,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	BaseRepository = __webpack_require__(40);


	/**
	sync repository
	@class BaseSyncRepository
	@extends BaseRepository
	@module base-domain
	 */

	BaseSyncRepository = (function(superClass) {
	  extend(BaseSyncRepository, superClass);

	  function BaseSyncRepository() {
	    return BaseSyncRepository.__super__.constructor.apply(this, arguments);
	  }

	  BaseSyncRepository.isSync = true;


	  /**
	  returns the result of the function
	  
	  @return {any}
	  @protected
	   */

	  BaseSyncRepository.prototype.resolve = function(result, fn) {
	    return fn.call(this, result);
	  };


	  /**
	  get entities by ID.
	  
	  @method getByIds
	  @public
	  @param {Array(String|Number)} ids
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Array(Entity)} entities
	   */

	  BaseSyncRepository.prototype.getByIds = function(ids, options) {
	    var id;
	    return ((function() {
	      var i, len, results;
	      results = [];
	      for (i = 0, len = ids.length; i < len; i++) {
	        id = ids[i];
	        results.push(this.get(id, options));
	      }
	      return results;
	    }).call(this)).filter(function(model) {
	      return model != null;
	    });
	  };


	  /**
	  Update or insert a model instance
	  
	  @method save
	  @public
	  @param {Entity|Object} entity
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity} entity (the same instance from input, if entity given,)
	   */


	  /**
	  get object by id.
	  
	  @method get
	  @public
	  @param {String|Number} id
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity} entity
	   */


	  /**
	  alias for get()
	  
	  @method getById
	  @public
	  @param {String|Number} id
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity} entity
	   */


	  /**
	  get all entities
	  
	  @method getAll
	  @return {Array(Entity)} array of entities
	   */


	  /**
	  Find all model instances that match params
	  
	  @method query
	  @public
	  @param {Object} [params] query parameters
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Array(Entity)} array of entities
	   */


	  /**
	  Find one model instance that matches params, Same as query, but limited to one result
	  
	  @method singleQuery
	  @public
	  @param {Object} [params] query parameters
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity|} entity
	   */


	  /**
	  Destroy the given entity (which must have "id" value)
	  
	  @method delete
	  @public
	  @param {Entity} entity
	  @param {ResourceClientInterface} [client=@client]
	  @return {Boolean} isDeleted
	   */


	  /**
	  Update set of attributes.
	  
	  @method update
	  @public
	  @param {String|Number} id of the entity to update
	  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Entity} updated entity
	   */


	  /**
	  Update set of attributes and returns newly-updated props (other than `props`)
	  
	  @method updateProps
	  @public
	  @param {Entity} entity
	  @param {Object} props key-value pair to update (notice: this must not be instance of Entity)
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Object} updated props
	   */

	  return BaseSyncRepository;

	})(BaseRepository);

	module.exports = BaseSyncRepository;


/***/ },
/* 42 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseAsyncRepository, BaseRepository,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	BaseRepository = __webpack_require__(40);


	/**
	async repository
	@class BaseAsyncRepository
	@extends BaseRepository
	@module base-domain
	 */

	BaseAsyncRepository = (function(superClass) {
	  extend(BaseAsyncRepository, superClass);

	  function BaseAsyncRepository() {
	    return BaseAsyncRepository.__super__.constructor.apply(this, arguments);
	  }

	  BaseAsyncRepository.isSync = false;


	  /**
	  returns Promise
	  
	  @return {Promise}
	  @protected
	   */

	  BaseAsyncRepository.prototype.resolve = function(result, fn) {
	    return Promise.resolve(result).then((function(_this) {
	      return function(obj) {
	        return fn.call(_this, obj);
	      };
	    })(this));
	  };


	  /**
	  get entities by ID.
	  
	  @method getByIds
	  @public
	  @param {Array(String|Number)} ids
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Promise(Array(Entity))} entities
	   */

	  BaseAsyncRepository.prototype.getByIds = function(ids, options) {
	    var id;
	    return Promise.all((function() {
	      var i, len, results;
	      results = [];
	      for (i = 0, len = ids.length; i < len; i++) {
	        id = ids[i];
	        results.push(this.get(id, options));
	      }
	      return results;
	    }).call(this)).then(function(models) {
	      return models.filter(function(model) {
	        return model != null;
	      });
	    });
	  };


	  /**
	  Update or insert a model instance
	  
	  @method save
	  @public
	  @param {Entity|Object} entity
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Promise(Entity)} entity (the same instance from input, if entity given,)
	   */


	  /**
	  get object by id.
	  
	  @method get
	  @public
	  @param {String|Number} id
	  @param {ResourceClientInterface} [client=@client]
	  @return {Promise(Entity)} entity
	   */


	  /**
	  alias for get()
	  
	  @method getById
	  @public
	  @param {String|Number} id
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Promise(Entity)} entity
	   */


	  /**
	  get all entities
	  
	  @method getAll
	  @return {Promise(Array(Entity))} array of entities
	   */


	  /**
	  Find all model instances that match params
	  
	  @method query
	  @public
	  @param {Object} [params] query parameters
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Promise(Array(Entity))} array of entities
	   */


	  /**
	  Find one model instance that matches params, Same as query, but limited to one result
	  
	  @method singleQuery
	  @public
	  @param {Object} [params] query parameters
	  @param {ResourceClientInterface} [client=@client]
	  @return {Promise(Entity)} entity
	   */


	  /**
	  Destroy the given entity (which must have "id" value)
	  
	  @method delete
	  @public
	  @param {Entity} entity
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Promise(Boolean)} isDeleted
	   */


	  /**
	  Update set of attributes.
	  
	  @method update
	  @public
	  @param {String|Number} id of the entity to update
	  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Promise(Entity)} updated entity
	   */


	  /**
	  Update set of attributes and returns newly-updated props (other than `props`)
	  
	  @method updateProps
	  @public
	  @param {Entity} entity
	  @param {Object} props key-value pair to update (notice: this must not be instance of Entity)
	  @param {Object} [options]
	  @param {ResourceClientInterface} [options.client=@client]
	  @return {Object} updated props
	   */

	  return BaseAsyncRepository;

	})(BaseRepository);

	module.exports = BaseAsyncRepository;


/***/ },
/* 43 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var AggregateRoot, BaseSyncRepository, LocalRepository,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	AggregateRoot = __webpack_require__(38);

	BaseSyncRepository = __webpack_require__(41);


	/**
	repository of local memory, saved in AggregateRoot

	@class LocalRepository
	@extends BaseSyncRepository
	@module base-domain
	 */

	LocalRepository = (function(superClass) {
	  extend(LocalRepository, superClass);


	  /**
	  root name
	   */

	  LocalRepository.aggregateRoot = null;

	  function LocalRepository() {
	    var Root;
	    LocalRepository.__super__.constructor.apply(this, arguments);
	    if (this.constructor.aggregateRoot == null) {
	      throw this.error('aggregateRootIsRequired', (this.constructor.getName()) + " must define its static property '@aggregateRoot'.");
	    }
	    Root = this.facade.getModel(this.constructor.aggregateRoot);
	    if (!(Root.prototype instanceof AggregateRoot)) {
	      throw this.error('invalidAggregateRoot', (this.constructor.getName()) + " has invalid aggregateRoot property.\n'" + this.constructor.aggregateRoot + "' is not instance of AggregateRoot.");
	    }
	    if (!(this.root instanceof Root)) {
	      throw this.error('invalidRoot', "'" + (this.constructor.getName()) + "' wasn't created by AggregateRoot '" + this.constructor.aggregateRoot + "'.\n\nTry\n\naggregateRoot.createRepository('" + this.constructor.modelName + "')\n\nwhere aggregateRoot is an instance of '" + this.constructor.aggregateRoot + "'.");
	    }
	    this.client = this.root.useMemoryResource(this.constructor.modelName);
	  }

	  return LocalRepository;

	})(BaseSyncRepository);

	module.exports = LocalRepository;


/***/ },
/* 44 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var BaseSyncRepository, MasterRepository,
	  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
	  hasProp = {}.hasOwnProperty;

	BaseSyncRepository = __webpack_require__(41);


	/**
	Master repository: handling static data
	Master data are loaded from master-data directory (by default, it's facade.dirname + /master-data)
	These data should be formatted in Fixture.
	Master data are read-only, so 'save', 'update' and 'delete' methods are not available.
	(And currently, 'query' and 'singleQuery' are also unavailable as MemoryResource does not support them yet...)

	@class MasterRepository
	@extends BaseSyncRepository
	@module base-domain
	 */

	MasterRepository = (function(superClass) {
	  extend(MasterRepository, superClass);


	  /**
	  Name of the data in master data.
	  @modelName is used if not set.
	  
	  @property {String} dataName
	  @static
	   */

	  MasterRepository.dataName = null;

	  function MasterRepository() {
	    var dataName, master, ref;
	    MasterRepository.__super__.constructor.apply(this, arguments);
	    master = this.facade.master;
	    if (master == null) {
	      throw this.error('masterNotFound', "MasterRepository is disabled by default.\nTo enable it, set the option to Facade.createInstance() like\n\nFacade.createInstance(master: true)");
	    }
	    dataName = (ref = this.constructor.dataName) != null ? ref : this.constructor.modelName;
	    this.client = master.getMemoryResource(dataName);
	  }


	  /**
	  Update or insert a model instance
	  Save data with "fixtureInsertion" option. Otherwise throw an error.
	  
	  @method save
	  @public
	   */

	  MasterRepository.prototype.save = function(data, options) {
	    if (options == null) {
	      options = {};
	    }
	    if (options.fixtureInsertion) {
	      return MasterRepository.__super__.save.call(this, data, options);
	    } else {
	      throw this.error('cannotSaveWithMasterRepository', 'base-domain:cannot save with MasterRepository');
	    }
	  };


	  /**
	  Destroy the given entity (which must have "id" value)
	  
	  @method delete
	  @public
	  @param {Entity} entity
	  @param {ResourceClientInterface} [client=@client]
	  @return {Boolean} isDeleted
	   */

	  MasterRepository.prototype["delete"] = function() {
	    throw this.error('cannotDeleteWithMasterRepository', 'base-domain:cannot delete with MasterRepository');
	  };


	  /**
	  Update set of attributes.
	  
	  @method update
	  @public
	  @param {String|Number} id of the entity to update
	  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
	  @param {ResourceClientInterface} [client=@client]
	  @return {Entity} updated entity
	   */

	  MasterRepository.prototype.update = function() {
	    throw this.error('cannotUpdateWithMasterRepository', 'base-domain:cannot update with MasterRepository');
	  };

	  return MasterRepository;

	})(BaseSyncRepository);

	module.exports = MasterRepository;


/***/ }
/******/ ]);