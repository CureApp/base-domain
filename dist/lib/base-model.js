var Base, BaseModel, ModelProps, TypeInfo,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TypeInfo = require('./type-info');

ModelProps = require('./model-props');

Base = require('./base');


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
  get an instance of ModelProps, which summarizes properties of this class
  
  @method getModelProps
  @public
  @return {ModelProps}
   */

  BaseModel._props = null;

  BaseModel.getModelProps = function() {
    return this._props != null ? this._props : this._props = new ModelProps(this.properties, this.prototype.getFacade());
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
    var k, modelProps, submodelProp, typeInfo, v;
    if (typeof prop === 'object') {
      for (k in prop) {
        v = prop[k];
        this.set(k, v);
      }
      return this;
    }
    this[prop] = value;
    modelProps = this.constructor.getModelProps();
    if (modelProps.isEntity(prop)) {
      typeInfo = modelProps.getTypeInfo(prop);
      this[typeInfo.idPropName] = value != null ? value.id : void 0;
    } else if (modelProps.isId(prop) && (value != null)) {
      this[prop] = value;
      submodelProp = modelProps.submodelOf(prop);
      if ((this[submodelProp] != null) && this[prop] !== this[submodelProp].id) {
        this[submodelProp] = void 0;
      }
    }
    return this;
  };


  /**
  unset property
  
  @method unset
  @param {String} prop property name
  @return {BaseModel} this
   */

  BaseModel.prototype.unset = function(prop) {
    var modelProps, typeInfo;
    this[prop] = void 0;
    modelProps = this.constructor.getModelProps();
    if (modelProps.isEntity(prop)) {
      typeInfo = modelProps.getTypeInfo(prop);
      this[typeInfo.idPropName] = void 0;
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
    modelProps = this.constructor.getModelProps();
    for (prop in this) {
      if (!hasProp.call(this, prop)) continue;
      value = this[prop];
      if (modelProps.isEntity(prop) || modelProps.isTmp(prop)) {
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
    return new Includer(this).include(options).then((function(_this) {
      return function() {
        _this.emit('included');
        return _this;
      };
    })(this));
  };

  return BaseModel;

})(Base);

module.exports = BaseModel;
