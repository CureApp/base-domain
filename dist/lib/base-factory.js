'use strict';
var Base, BaseFactory, GeneralFactory,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');

GeneralFactory = require('./general-factory');


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
