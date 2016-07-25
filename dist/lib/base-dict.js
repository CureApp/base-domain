'use strict';
var BaseDict, Collection,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

Collection = require('./collection');


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
