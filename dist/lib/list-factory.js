var BaseFactory, ListFactory,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./base-factory');


/**
factory of list

@class ListFactory
@extends Base
@module base-domain
 */

ListFactory = (function(superClass) {
  extend(ListFactory, superClass);


  /**
  create instance
   */

  ListFactory.create = function(listModelName, itemFactory) {
    return new ListFactory(listModelName, itemFactory);
  };


  /**
  @constructor
   */

  function ListFactory(listModelName1, itemFactory1) {
    this.listModelName = listModelName1;
    this.itemFactory = itemFactory1;
    this.getFacade = function() {
      return this.itemFactory.getFacade();
    };
    ListFactory.__super__.constructor.apply(this, arguments);
  }


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Function}
   */

  ListFactory.prototype.getModelClass = function() {
    return this.getFacade().getModel(this.listModelName);
  };


  /**
  creates an instance of BaseList by value
  
  @method createFromObject
  @public
  @param {any} obj
  @return {BaseList}
   */

  ListFactory.prototype.createFromObject = function(obj) {
    var ListModel, ids, item, items, list;
    if ((obj == null) || typeof obj !== 'object') {
      return this.createEmpty();
    }
    if (Array.isArray(obj)) {
      return this.createFromArray(obj);
    }
    ListModel = this.getModelClass();
    ids = obj.ids, items = obj.items;
    if (items) {
      delete obj.items;
      items = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = items.length; i < len; i++) {
          item = items[i];
          results.push(this.createItemFromObject(item));
        }
        return results;
      }).call(this);
      list = ListFactory.__super__.createFromObject.call(this, obj).setItems(items);
      obj.items = items;
    } else if (ListModel.containsEntity()) {
      delete obj.ids;
      list = ListFactory.__super__.createFromObject.call(this, obj).setIds(ids);
      obj.ids = ids;
    } else {
      return ListFactory.__super__.createFromObject.call(this, obj);
    }
    return list;
  };


  /**
  creates an instance of BaseList from array
  
  @method createFromArray
  @public
  @param {Array} arr
  @return {BaseList}
   */

  ListFactory.prototype.createFromArray = function(arr) {
    var ListModel, firstValue, items, obj;
    ListModel = this.getModelClass();
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
      return new ListModel().setItems(items);
    }
    if (ListModel.containsEntity()) {
      return new ListModel().setIds(arr);
    }
    throw new Error("cannot create " + this.constructor.modelName + " with arr\n [" + (arr.toString()) + "]");
  };


  /**
  creates an instance of BaseList by value
  
  @method createEmpty
  @private
  @return {BaseList}
   */

  ListFactory.prototype.createEmpty = function() {
    var ListModel;
    ListModel = this.getModelClass();
    return new ListModel().setItems();
  };


  /**
  create item model
  
  @method createItemFromObject
  @return {BaseModel}
   */

  ListFactory.prototype.createItemFromObject = function(obj) {
    return this.itemFactory.createFromObject(obj);
  };

  return ListFactory;

})(BaseFactory);

module.exports = ListFactory;
