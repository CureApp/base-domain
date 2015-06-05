var Base, BaseFactory,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');


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
  get anonymous factory class
  
  @method getAnonymousClass
  @param {String} modelName
  @return {Function}
   */

  BaseFactory.getAnonymousClass = function(modelName) {
    var AnonymousFactory;
    AnonymousFactory = (function(superClass1) {
      extend(AnonymousFactory, superClass1);

      function AnonymousFactory() {
        return AnonymousFactory.__super__.constructor.apply(this, arguments);
      }

      AnonymousFactory.modelName = modelName;

      AnonymousFactory.isAnonymous = true;

      return AnonymousFactory;

    })(BaseFactory);
    return AnonymousFactory;
  };


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

  BaseFactory._ModelClass = void 0;

  BaseFactory.prototype.getModelClass = function() {
    return this._ModelClass != null ? this._ModelClass : this._ModelClass = this.getFacade().getModel(this.constructor.modelName);
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
    var ModelClass, entityProp, i, len, model, prop, ref, typeInfo, value;
    ModelClass = this.getModelClass();
    if (obj instanceof ModelClass) {
      return obj;
    }
    obj = this.beforeCreateFromObject(obj);
    if ((obj == null) || typeof obj !== 'object') {
      return null;
    }
    model = new ModelClass();
    for (prop in obj) {
      if (!hasProp.call(obj, prop)) continue;
      value = obj[prop];
      this.setValueToModel(model, prop, value);
    }
    ref = ModelClass.getEntityProps();
    for (i = 0, len = ref.length; i < len; i++) {
      entityProp = ref[i];
      if (model[entityProp]) {
        continue;
      }
      typeInfo = model.getTypeInfo(entityProp);
      this.fetchEntityProp(model, entityProp);
    }
    return this.afterCreateModel(model);
  };


  /**
  set value to model in creation
  
  @method setValueToModel
  @private
   */

  BaseFactory.prototype.setValueToModel = function(model, prop, value) {
    var typeInfo;
    typeInfo = model.getTypeInfo(prop);
    switch (typeInfo != null ? typeInfo.name : void 0) {
      case 'MODEL_LIST':
        return this.setSubModelListToModel(model, prop, value);
      case 'MODEL':
        return this.setSubModelToModel(model, prop, value);
      default:
        return model.setNonEntityProp(prop, value);
    }
  };


  /**
  fetch submodel(s) by id
  available only when repository of submodel implements 'getByIdSync'
  (MasterRepository implements one)
  
  @method fetchEntityProp
  @private
   */

  BaseFactory.prototype.fetchEntityProp = function(model, prop) {
    var Repository, e, id, idPropName, repository, subModel, typeInfo;
    typeInfo = model.getTypeInfo(prop);
    idPropName = typeInfo.idPropName;
    try {
      Repository = this.getFacade().getRepository(typeInfo.model);
      if (!Repository.storeMasterTable) {
        return;
      }
      repository = new Repository();
      if (!repository.getByIdSync) {
        return;
      }
    } catch (_error) {
      e = _error;
      return;
    }
    id = model[idPropName];
    subModel = repository.getByIdSync(id);
    if (subModel) {
      return model.setEntityProp(prop, subModel);
    }
  };


  /**
  creates list and set it to the model
  
  @method setSubModelListToModel
  @private
   */

  BaseFactory.prototype.setSubModelListToModel = function(model, prop, value) {
    var list, listFactory, typeInfo;
    typeInfo = model.getTypeInfo(prop);
    listFactory = this.getFacade().createListFactory(typeInfo.listName, typeInfo.model);
    list = listFactory.createFromObject(value);
    model.setNonEntityProp(prop, list);
  };


  /**
  set submodel to the prop
  
  @method setSubModelToModel
  @private
   */

  BaseFactory.prototype.setSubModelToModel = function(model, prop, value) {
    var SubModel, subModelFactory, subModelName, useAnonymousFactory;
    subModelName = model.getTypeInfo(prop).model;
    useAnonymousFactory = true;
    subModelFactory = this.getFacade().createFactory(subModelName, useAnonymousFactory);
    SubModel = subModelFactory.getModelClass();
    if (!(value instanceof SubModel)) {
      value = subModelFactory.createFromObject(value);
    }
    if (SubModel.isEntity) {
      model.setEntityProp(prop, value);
    } else {
      model.setNonEntityProp(prop, value);
    }
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
