var BaseList, Collection,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

Collection = require('./collection');


/**
list class of DDD pattern.

@class BaseList
@extends Collection
@module base-domain
 */

BaseList = (function(superClass) {

  /**
  the number of items
  
  @property length
  @type number
  @public
   */
  extend(BaseList, superClass);

  Object.defineProperty(BaseList.prototype, 'length', {
    get: function() {
      return this.items.length;
    }
  });


  /**
  items: array of models
  
  @property items
  @type Array
   */


  /**
  @constructor
  @params {any} props
  @params {RootInterface} root
   */

  function BaseList(props, root) {
    if (props == null) {
      props = {};
    }
    Object.defineProperty(this, 'items', {
      value: [],
      enumerable: true
    });
    BaseList.__super__.constructor.call(this, props, root);
  }


  /**
  add model(s)
  
  @method add
  @param {BaseModel} model
   */

  BaseList.prototype.add = function() {
    var ItemClass, item, j, len, models;
    models = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    ItemClass = this.getItemModelClass();
    for (j = 0, len = models.length; j < len; j++) {
      item = models[j];
      if (item instanceof ItemClass) {
        this.items.push(item);
      }
    }
    if (this.sort) {
      return this.items.sort(this.sort);
    }
  };


  /**
  clear all models
  
  @method clear
   */

  BaseList.prototype.clear = function() {
    var i, j, ref;
    for (i = j = 0, ref = this.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      this.items.pop();
    }
  };


  /**
  remove item by index
  
  @method remove
  @param {Number} index
   */

  BaseList.prototype.remove = function(index) {
    return this.items.splice(index, 1);
  };


  /**
  sort items in constructor
  
  @method sort
  @protected
  @abstract
  @param modelA
  @param modelB
  @return {Number}
   */


  /**
  first item
  
  @method first
  @public
   */

  BaseList.prototype.first = function() {
    return this.items[0];
  };


  /**
  last item
  
  @method last
  @public
   */

  BaseList.prototype.last = function() {
    return this.items[this.length - 1];
  };


  /**
  export models to Array
  
  @method toArray
  @public
   */

  BaseList.prototype.toArray = function() {
    return this.items.slice();
  };

  return BaseList;

})(Collection);

module.exports = BaseList;
