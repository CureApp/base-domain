var BaseFactory, DictFactory,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./base-factory');


/**
factory of dict

@class DictFactory
@extends BaseFactory
@module base-domain
 */

DictFactory = (function(superClass) {
  extend(DictFactory, superClass);


  /**
  create instance
   */

  DictFactory.create = function(dictModelName, itemFactory) {
    return new DictFactory(dictModelName, itemFactory);
  };


  /**
  @constructor
   */

  function DictFactory(dictModelName1, itemFactory1) {
    this.dictModelName = dictModelName1;
    this.itemFactory = itemFactory1;
    this.getFacade = function() {
      return this.itemFactory.getFacade();
    };
    DictFactory.__super__.constructor.apply(this, arguments);
  }


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Function}
   */

  DictFactory.prototype.getModelClass = function() {
    return this.getFacade().getModel(this.dictModelName);
  };


  /**
  creates an instance of BaseDict by value
  
  @method createFromObject
  @public
  @param {any} obj
  @return {BaseDict}
   */

  DictFactory.prototype.createFromObject = function(obj) {
    var DictModel, dict, ids, item, items, key;
    if ((obj == null) || typeof obj !== 'object') {
      return this.createEmpty();
    }
    if (Array.isArray(obj)) {
      return this.createFromArray(obj);
    }
    DictModel = this.getModelClass();
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
      dict = DictFactory.__super__.createFromObject.call(this, obj).setItems(items);
      obj.items = items;
    } else if (DictModel.containsEntity()) {
      delete obj.ids;
      dict = DictFactory.__super__.createFromObject.call(this, obj).setIds(ids);
      obj.ids = ids;
    } else {
      return DictFactory.__super__.createFromObject.call(this, obj);
    }
    return dict;
  };


  /**
  creates an instance of BaseDict from array
  
  @method createFromArray
  @public
  @param {Array} arr
  @return {BaseDict}
   */

  DictFactory.prototype.createFromArray = function(arr) {
    var DictModel, firstValue, items, obj;
    DictModel = this.getModelClass();
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
      return new DictModel().setItems(items);
    }
    if (DictModel.containsEntity()) {
      return new DictModel().setIds(arr);
    }
    throw new Error("cannot create " + this.constructor.modelName + " with arr\n [" + (arr.toString()) + "]");
  };


  /**
  creates an instance of BaseDict by value
  
  @method createEmpty
  @private
  @return {BaseDict}
   */

  DictFactory.prototype.createEmpty = function() {
    var DictModel;
    DictModel = this.getModelClass();
    return new DictModel().setItems();
  };


  /**
  create item model
  
  @method createItemFromObject
  @return {BaseModel}
   */

  DictFactory.prototype.createItemFromObject = function(obj) {
    return this.itemFactory.createFromObject(obj);
  };

  return DictFactory;

})(BaseFactory);

module.exports = DictFactory;
