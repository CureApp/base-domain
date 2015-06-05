var Base, BaseModel, Includer, PropInfo, TypeInfo,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TypeInfo = require('./type-info');

PropInfo = require('./prop-info');

Base = require('./base');

Includer = require('./includer');


/**
Base model class of DDD pattern.

the parent "Base" class just simply gives a @getFacade() method.


@class BaseModel
@extends Base
@module base-domain
 */

BaseModel = (function(superClass) {
  extend(BaseModel, superClass);

  BaseModel.isEntity = false;


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
  ModelName -> model-name
  
  @private
   */

  BaseModel.getModelName = function() {
    return this.name.replace(/([A-Z])/g, function(st) {
      return '-' + st.charAt(0).toLowerCase();
    }).slice(1);
  };


  /**
  key-value pair representing property's name - type of the model
  
      firstName    : @TYPES.STRING
      lastName     : @TYPES.STRING
      age          : @TYPES.NUMBER
      registeredAt : @TYPES.DATE
      team         : @TYPES.MODEL 'team'
      hobbies      : @TYPES.MODEL_LIST 'hobby'
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
  get an instance of PropInfo, which summarizes properties of this class
  
  @method getPropInfo
  @public
  @return {PropInfo}
   */

  BaseModel._pi = null;

  BaseModel.getPropInfo = function() {
    return this._pi != null ? this._pi : this._pi = new PropInfo(this.properties, this.getFacade());
  };


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

  BaseModel.withParentProps = function(props) {
    var k, ref, v;
    if (props == null) {
      props = {};
    }
    ref = this.properties;
    for (k in ref) {
      v = ref[k];
      if (props[k] == null) {
        props[k] = v;
      }
    }
    return props;
  };


  /**
  get list of properties which contains entity
  
  @method getEntityProps
  @public
  @static
  @return {Array}
   */

  BaseModel.getEntityProps = function() {
    return this.getPropInfo().entityProps;
  };


  /**
  get list of properties which contains relational model
  
  @method getModelProps
  @public
  @static
  @param {Object} [options]
  @param {Boolean} [options.includeList] include props of BaseList
  @return {Array}
   */

  BaseModel.getModelProps = function(options) {
    var propInfo, ret;
    if (options == null) {
      options = {};
    }
    propInfo = this.getPropInfo();
    ret = propInfo.modelProps.slice();
    if (options.includeList) {
      ret.concat(propInfo.listProps);
    }
    return ret;
  };


  /**
  @constructor
   */

  function BaseModel(obj) {
    var prop;
    for (prop in this.constructor.properties) {
      if (this[prop] == null) {
        this[prop] = void 0;
      }
    }
    if (obj) {
      this.set(obj);
    }
  }

  BaseModel.prototype.getTypeInfo = function(prop) {
    return this.constructor.getPropInfo().dic[prop];
  };

  BaseModel.prototype.isEntityProp = function(prop) {
    return this.constructor.getPropInfo().isEntityProp(prop);
  };


  /**
  set value to prop
  @return {BaseModel} this
   */

  BaseModel.prototype.set = function(prop, value) {
    var k, typeInfo, v;
    if (typeof prop === 'object') {
      for (k in prop) {
        v = prop[k];
        this.set(k, v);
      }
      return this;
    }
    typeInfo = this.getTypeInfo(prop);
    if ((typeInfo != null ? typeInfo.model : void 0) && this.isEntityProp(prop)) {
      this.setEntityProp(prop, value);
    } else {
      this.setNonEntityProp(prop, value);
    }
    return this;
  };


  /**
  set model prop
  @return {BaseModel} this
   */

  BaseModel.prototype.setNonEntityProp = function(prop, value) {
    return this[prop] = value;
  };


  /**
  set related model(s)
  
  @method setEntityProp
  @param {String} prop property name of the related model
  @param {Entity|Array<Entity>} submodel
  @return {BaseModel} this
   */

  BaseModel.prototype.setEntityProp = function(prop, submodel) {
    var idPropName, modelName, typeInfo;
    typeInfo = this.getTypeInfo(prop);
    modelName = typeInfo.model;
    this[prop] = submodel;
    idPropName = typeInfo.idPropName;
    this[idPropName] = submodel != null ? submodel.id : void 0;
    return this;
  };


  /**
  unset related model(s)
  
  @param {String} prop property name of the related models
  @return {BaseModel} this
  @method unsetEntityProp
   */

  BaseModel.prototype.unsetEntityProp = function(prop) {
    var typeInfo;
    typeInfo = this.getTypeInfo(prop);
    this[prop] = void 0;
    this[typeInfo.idPropName] = void 0;
    return this;
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
        this[k] = v;
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
    var facade, plainObject, prop, typeInfo, value;
    facade = this.getFacade();
    plainObject = {};
    for (prop in this) {
      if (!hasProp.call(this, prop)) continue;
      value = this[prop];
      if (this.isEntityProp(prop)) {
        continue;
      }
      typeInfo = this.getTypeInfo(prop);
      if ((typeInfo != null ? typeInfo.model : void 0) == null) {
        plainObject[prop] = value;
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
  include all relational models if not set
  
  @method include
  @param {Object} [options]
  @param {Boolean} [options.recursive] recursively include models or not
  @return {Promise(BaseModel)} self
   */

  BaseModel.prototype.include = function(options) {
    if (options == null) {
      options = {};
    }
    return new Includer(this).include({
      recursive: options.recursive
    });
  };

  return BaseModel;

})(Base);

module.exports = BaseModel;
