'use strict';
var Base, BaseModel, ModelProps, TypeInfo, Util,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TypeInfo = require('./type-info');

Base = require('./base');

ModelProps = require('./model-props');

Util = require('../util');


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
      obj[prop] = plainObj[prop];
      return obj;
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
    Includer = require('./includer');
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
    Includer = require('./includer');
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
