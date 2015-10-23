var BaseDict, BaseList, GeneralFactory,
  hasProp = {}.hasOwnProperty;

BaseList = require('./base-list');

BaseDict = require('./base-dict');


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
    var e;
    try {
      return root.createFactory(modelName);
    } catch (_error) {
      e = _error;
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
  @param {Boolean} [options.include.recursive=false] recursively include or not
  @param {Array(String)} [options.include.props] include sub-entities of given props
  @param {RootInterface} root
  @return {BaseModel}
   */

  GeneralFactory.createModel = function(modelName, obj, options, root) {
    var Model;
    if (obj === null) {
      return null;
    }
    Model = root.getModel(modelName);
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
    this.modelProps = this.getModelClass().getModelProps();
  }


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Function}
   */

  GeneralFactory.prototype.getModelClass = function() {
    return this.root.getModel(this.modelName);
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
  @param {Boolean} [options.include.recursive=false] recursively include or not
  @param {Array(String)} [options.include.props] include sub-entities of given props
  @return {BaseModel} model
   */

  GeneralFactory.prototype.createFromObject = function(obj, options) {
    var ModelClass, i, len, model, prop, ref, ref1, subModelName, value;
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
      if (subModelName = (ref = this.modelProps.getTypeInfo(prop)) != null ? ref.model : void 0) {
        value = this.constructor.createModel(subModelName, value, options, this.root);
      }
      model.set(prop, value);
    }
    ref1 = this.modelProps.names();
    for (i = 0, len = ref1.length; i < len; i++) {
      prop = ref1[i];
      if ((model[prop] != null) || obj.hasOwnProperty(prop)) {
        continue;
      }
      if (subModelName = this.modelProps.getTypeInfo(prop).model) {
        if (this.modelProps.isEntity(prop)) {
          continue;
        }
        model.set(prop, this.constructor.createModel(subModelName, void 0, options, this.root));
      } else {
        model.set(prop, void 0);
      }
    }
    if (options.include !== null) {
      this.include(model, options.include);
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
  @param {Boolean} [options.include.recursive=false] recursively include or not
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
      return;
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
  @param {Boolean} [options.include.recursive=false] recursively include or not
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
  @param {Boolean} [options.include.recursive=false] recursively include or not
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
    var CollectionFactory;
    if (val === null) {
      return null;
    }
    CollectionFactory = require('./collection-factory');
    return new CollectionFactory(collModelName, this.root).createFromObject(val, options);
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
