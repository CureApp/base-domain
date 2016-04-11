'use strict';
var Base, BaseModel, ModelProps, TypeInfo,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TypeInfo = require('./type-info');

Base = require('./base');

ModelProps = require('./model-props');


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
      return this.getFacade().getModelProps(this.constructor.getName());
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
  include all relational models if not set
  
  @method include
  @param {Object} [options]
  @param {Boolean} [options.recursive] recursively include models or not
  @param {Boolean} [options.async=true] get async values
  @param {Array(String)} [options.props] include only given props
  @return {Promise(BaseModel)} self
   */

  BaseModel.prototype.include = function(options) {
    var Includer;
    if (options == null) {
      options = {};
    }
    Includer = require('./includer');
    return new Includer(this, options).include().then((function(_this) {
      return function() {
        return _this;
      };
    })(this));
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
