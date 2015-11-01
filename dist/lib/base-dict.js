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
  @constructor
  @params {any} props
  @params {RootInterface} root
   */

  function BaseDict(props, root) {
    if (props == null) {
      props = {};
    }
    BaseDict.__super__.constructor.call(this, props, root);
  }


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
      return;
    }
    key = this.constructor.key(item);
    if (this.has(key)) {
      return this.remove(item);
    } else {
      return this.add(item);
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
    var ItemClass, arg, args, i, key, len;
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
      delete this.items[key];
    }
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

  return BaseDict;

})(Collection);

module.exports = BaseDict;
