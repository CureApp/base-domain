'use strict';
var BaseList, Collection,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

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
  
  @property itemLength
  @type number
  @public
   */
  extend(BaseList, superClass);

  Object.defineProperty(BaseList.prototype, 'itemLength', {
    get: function() {
      if (!this.loaded()) {
        return 0;
      }
      return this.items.length;
    }
  });


  /**
  items: array of models
  
  @property {Array} items
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
    BaseList.__super__.constructor.call(this, props, root);
  }


  /**
  @method initItems
  @protected
   */

  BaseList.prototype.initItems = function() {
    return this.items = [];
  };


  /**
  @method addItems
  @param {Array(BaseModel|Object)} items
  @protected
   */

  BaseList.prototype.addItems = function(items) {
    var item;
    BaseList.__super__.addItems.apply(this, arguments);
    if (this.sort) {
      this.items.sort(this.sort);
      if (this.isItemEntity) {
        return this.ids = (function() {
          var i, len, ref, results;
          ref = this.items;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            item = ref[i];
            results.push(item.id);
          }
          return results;
        }).call(this);
      }
    }
  };


  /**
  add item to @items
  
  @method addItem
  @protected
  @param {BaseModel} item
   */

  BaseList.prototype.addItem = function(item) {
    return this.items.push(item);
  };


  /**
  remove item by index
  
  @method remove
  @param {Number} index
   */

  BaseList.prototype.remove = function(index) {
    if (!this.loaded()) {
      return;
    }
    this.items.splice(index, 1);
    if (this.isItemEntity) {
      return this.ids.splice(index, 1);
    }
  };


  /**
  remove item by index and create a new model
  
  @method $remove
  @param {Number} index
  @return {Baselist} newList
   */

  BaseList.prototype.$remove = function(index) {
    var newItems;
    if (!this.loaded()) {
      throw this.error('NotLoaded');
    }
    newItems = this.toArray();
    newItems.splice(index, 1);
    return this.copyWith({
      items: newItems
    });
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
    if (!this.loaded()) {
      return void 0;
    }
    return this.items[0];
  };


  /**
  last item
  
  @method last
  @public
   */

  BaseList.prototype.last = function() {
    if (!this.loaded()) {
      return void 0;
    }
    return this.items[this.length - 1];
  };


  /**
  get item by index
  
  @method getByIndex
  @public
   */

  BaseList.prototype.getByIndex = function(idx) {
    if (!this.loaded()) {
      return void 0;
    }
    return this.items[idx];
  };


  /**
  get item by index
  
  @method getItem
  @public
   */

  BaseList.prototype.getItem = function(idx) {
    return this.items[idx] || (function() {
      throw this.error('IndexNotFound');
    }).call(this);
  };


  /**
  export models to Array
  
  @method toArray
  @public
   */

  BaseList.prototype.toArray = function() {
    if (!this.loaded()) {
      return [];
    }
    return this.items.slice();
  };

  return BaseList;

})(Collection);

module.exports = BaseList;
