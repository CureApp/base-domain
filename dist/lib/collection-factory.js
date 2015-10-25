var CollectionFactory, DomainError, GeneralFactory,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

DomainError = require('./domain-error');

GeneralFactory = require('./general-factory');


/**
factory of Collection

@class CollectionFactory
@extends GeneralFactory
@module base-domain
 */

CollectionFactory = (function(superClass) {
  extend(CollectionFactory, superClass);


  /**
  @constructor
   */

  function CollectionFactory() {
    CollectionFactory.__super__.constructor.apply(this, arguments);
    this.itemFactory = this.constructor.create(this.getModelClass().itemModelName, this.root);
    this.isItemEntity = this.itemFactory.getModelClass().isEntity;
  }


  /**
  creates an instance of Collection by value
  
  @method createFromObject
  @public
  @param {any} obj
  @return {Collection}
   */

  CollectionFactory.prototype.createFromObject = function(obj) {
    var coll, ids, item, items, key;
    if ((obj == null) || typeof obj !== 'object') {
      return this.createEmpty();
    }
    if (Array.isArray(obj)) {
      return this.createFromArray(obj);
    }
    ids = obj.ids, items = obj.items;
    if (items) {
      delete obj.items;
      items = (function() {
        var results;
        results = [];
        for (key in items) {
          item = items[key];
          results.push(this.createItemFromObject(item));
        }
        return results;
      }).call(this);
      coll = CollectionFactory.__super__.createFromObject.call(this, obj).setItems(items);
      obj.items = items;
    } else if (this.isItemEntity) {
      delete obj.ids;
      coll = CollectionFactory.__super__.createFromObject.call(this, obj).setIds(ids);
      obj.ids = ids;
    } else {
      return CollectionFactory.__super__.createFromObject.call(this, obj);
    }
    return coll;
  };


  /**
  creates an instance of Collection from array
  
  @method createFromArray
  @public
  @param {Array} arr
  @return {Collection}
   */

  CollectionFactory.prototype.createFromArray = function(arr) {
    var firstValue, items, obj;
    firstValue = arr[0];
    if (firstValue == null) {
      return this.createEmpty();
    }
    if (typeof firstValue === 'object') {
      items = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = arr.length; i < len; i++) {
          obj = arr[i];
          results.push(this.createItemFromObject(obj));
        }
        return results;
      }).call(this);
      return this.create().setItems(items);
    }
    if (this.isItemEntity) {
      return this.create().setIds(arr);
    }
    throw new DomainError('base-domain:invalidParamsToCreateFromArray', "cannot create " + this.modelName + " with arr\n [" + (arr.toString()) + "]");
  };


  /**
  creates an instance of Collection by value
  
  @method createEmpty
  @private
  @return {Collection}
   */

  CollectionFactory.prototype.createEmpty = function() {
    return this.create().setItems();
  };


  /**
  create item model
  
  @method createItemFromObject
  @return {BaseModel}
   */

  CollectionFactory.prototype.createItemFromObject = function(obj) {
    return this.itemFactory.createFromObject(obj);
  };

  return CollectionFactory;

})(GeneralFactory);

module.exports = CollectionFactory;
