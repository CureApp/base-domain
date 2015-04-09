var Base, BaseFactory, Entity, TYPES,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');

TYPES = require('./types');

Entity = require('./entity');


/**
Base factory class of DDD pattern.

create instance of model

the parent "Base" class just simply gives a @getFacade() method.

@class BaseFactory
@extends Base
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


  /**
  constructor
  
  @constructor
   */

  function BaseFactory() {}


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Class}
   */

  BaseFactory.prototype.getModelClass = function() {
    var modelName;
    modelName = this.constructor.modelName;
    return this.getFacade().getModel(modelName);
  };


  /**
  create empty model instance
  
  @method createEmptyModel
  @return {BaseModel}
   */

  BaseFactory.prototype.createEmptyModel = function() {
    return this.createFromObject({});
  };


  /**
  create instance of model class by plain object
  
  for each prop, values are set by Model#set(prop, value)
  
  @method createFromObject
  @public
  @param {Object} obj
  @param {BaseModel} baseModel fallback properties
  @return {BaseModel} model
   */

  BaseFactory.prototype.createFromObject = function(obj) {
    var ModelClass, SubModel, facade, model, prop, propInfo, subModel, subModelFactory, subModels, subObj, typeInfo, value;
    obj = this.beforeCreateFromObject(obj);
    if ((obj == null) || typeof obj !== 'object') {
      return null;
    }
    ModelClass = this.getModelClass();
    propInfo = ModelClass.getPropertyInfo();
    facade = this.getFacade();
    model = new ModelClass();
    for (prop in ModelClass.properties) {
      if (model[prop] == null) {
        model[prop] = void 0;
      }
    }
    for (prop in obj) {
      if (!hasProp.call(obj, prop)) continue;
      value = obj[prop];
      typeInfo = propInfo[prop];
      if (typeInfo != null ? typeInfo.model : void 0) {
        subModelFactory = facade.createFactory(typeInfo.model);
        SubModel = subModelFactory.getModelClass();
        if (typeInfo.name === 'MODELS' && Array.isArray(value)) {
          subModels = (function() {
            var i, len, results;
            results = [];
            for (i = 0, len = value.length; i < len; i++) {
              subObj = value[i];
              if (subObj instanceof SubModel) {
                results.push(subObj);
              } else {
                results.push(subModelFactory.createFromObject(subObj));
              }
            }
            return results;
          })();
          model.setRelatedModels(prop, subModels);
          continue;
        } else if (typeInfo.name === 'MODEL') {
          if (value instanceof SubModel) {
            model.setRelatedModel(prop, value);
          } else {
            subModel = subModelFactory.createFromObject(value);
            model.setRelatedModel(prop, subModel);
          }
          continue;
        }
      } else {
        model.setNonModelProp(prop, value);
      }
    }
    return this.afterCreateModel(model);
  };


  /**
  modify plain object before @createFromObject(obj)
  
  @method beforeCreateFromObject
  @protected
  @abstract
  @param {Object} obj
  @return {Object} obj
   */

  BaseFactory.prototype.beforeCreateFromObject = function(obj) {
    return obj;
  };


  /**
  modify model after createFromObject(obj), createEmptyModel()
  
  @method afterCreateModel
  @protected
  @abstract
  @param {BaseModel} model
  @return {BaseModel} model
   */

  BaseFactory.prototype.afterCreateModel = function(model) {
    return model;
  };

  return BaseFactory;

})(Base);

module.exports = BaseFactory;
