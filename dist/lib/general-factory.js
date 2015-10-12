
/**
general factory class

create instance of model

@class GeneralFactory
@module base-domain
 */
var GeneralFactory,
  hasProp = {}.hasOwnProperty;

GeneralFactory = (function() {

  /**
  constructor
  
  @constructor
  @param {String} modelName
  @param {RootInterface} root
   */
  function GeneralFactory(modelName, root) {
    this.modelName = modelName;
    this.root = root;
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
  @param {Object} [options.include.async=false] include submodels asynchronously
  @param {Boolean} [options.include.recursive=false] recursively include or not
  @param {Array(String)} [options.include.props] include submodels of given props
  @return {BaseModel} model
   */

  GeneralFactory.prototype.createFromObject = function(obj, options) {
    var ModelClass, i, len, model, prop, ref, value;
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
      this.setValueToModel(model, prop, value);
    }
    ref = this.modelProps.names();
    for (i = 0, len = ref.length; i < len; i++) {
      prop = ref[i];
      if ((model[prop] != null) || obj.hasOwnProperty(prop)) {
        continue;
      }
      this.setEmptyValueToModel(model, prop);
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
  set value to model in creation
  
  @method setValueToModel
  @private
   */

  GeneralFactory.prototype.setValueToModel = function(model, prop, value) {
    var ref;
    switch ((ref = this.modelProps.getTypeInfo(prop)) != null ? ref.name : void 0) {
      case 'MODEL':
        return model.set(prop, this.createSubModel(prop, value));
      case 'MODEL_LIST':
      case 'MODEL_DICT':
        return model.set(prop, this.createSubCollection(prop, value));
      default:
        return model.set(prop, value);
    }
  };


  /**
  set empty values to model in creation
  
  @method setEmptyValueToModel
  @private
   */

  GeneralFactory.prototype.setEmptyValueToModel = function(model, prop) {
    switch (this.modelProps.getTypeInfo(prop).name) {
      case 'MODEL':
        if (this.modelProps.isEntity(prop)) {

        } else {
          return model.set(prop, this.createEmptyModel(prop));
        }
        break;
      case 'MODEL_LIST':
      case 'MODEL_DICT':
        return model.set(prop, this.createSubCollection(prop, []));
      default:
        return model.set(prop, void 0);
    }
  };


  /**
  create collection by prop name and value
  
  @method createSubCollection
  @private
  @return {Collection}
   */

  GeneralFactory.prototype.createSubCollection = function(prop, value) {
    var itemModelFactory, typeInfo;
    typeInfo = this.modelProps.getTypeInfo(prop);
    itemModelFactory = this.root.createFactory(typeInfo.itemModel);
    return itemModelFactory.createCollection(typeInfo.model, value);
  };


  /**
  create submodel by prop name and value
  
  @method createSubModel
  @private
   */

  GeneralFactory.prototype.createSubModel = function(prop, value) {
    var SubModel, subModelFactory;
    subModelFactory = this.root.createFactory(this.modelProps.getTypeInfo(prop).model);
    SubModel = subModelFactory.getModelClass();
    if (value instanceof SubModel) {
      return value;
    }
    return subModelFactory.createFromObject(value);
  };


  /**
  create empty model and set to the prop
  
  @method createEmptyModel
  @private
   */

  GeneralFactory.prototype.createEmptyModel = function(prop) {
    var typeInfo;
    typeInfo = this.modelProps.getTypeInfo(prop);
    return this.root.createFactory(typeInfo.model).createEmpty();
  };


  /**
  create model list
  
  @method createList
  @public
  @param {String} listModelName model name of list
  @param {any} val
  @return {BaseList} list
   */

  GeneralFactory.prototype.createList = function(listModelName, val) {
    return this.createCollection(listModelName, val);
  };


  /**
  create model dict
  
  @method createDict
  @public
  @param {String} dictModelName model name of dict
  @param {any} val 
  @return {BaseDict} dict
   */

  GeneralFactory.prototype.createDict = function(dictModelName, val) {
    return this.createCollection(dictModelName, val);
  };


  /**
  create collection
  
  @method createCollection
  @public
  @param {String} collModelName model name of collection
  @param {any} val 
  @return {BaseDict} dict
   */

  GeneralFactory.prototype.createCollection = function(collModelName, val) {
    var CollectionFactory;
    if (val === null) {
      return null;
    }
    CollectionFactory = require('./collection-factory');
    return new CollectionFactory(collModelName, this.root).createFromObject(val);
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
