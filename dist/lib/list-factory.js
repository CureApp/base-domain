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

  function ListFactory() {
    return ListFactory.__super__.constructor.apply(this, arguments);
  }


  /**
  get anonymous list factory class
  
  @method getAnonymousClass
  @param {String} modelName
  @param {String} itemModelName
  @return {Function}
   */

  ListFactory.getAnonymousClass = function(modelName, itemModelName) {
    var AnonymousListFactory;
    AnonymousListFactory = (function(superClass1) {
      extend(AnonymousListFactory, superClass1);

      function AnonymousListFactory() {
        return AnonymousListFactory.__super__.constructor.apply(this, arguments);
      }

      AnonymousListFactory.modelName = modelName;

      AnonymousListFactory.itemModelName = itemModelName;

      AnonymousListFactory.isAnonymous = true;

      return AnonymousListFactory;

    })(ListFactory);
    return AnonymousListFactory;
  };


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Class}
   */

  ListFactory._ModelClass = void 0;

  ListFactory.prototype.getModelClass = function() {
    var itemModelName, modelName, ref;
    ref = this.constructor, modelName = ref.modelName, itemModelName = ref.itemModelName;
    return this._ModelClass != null ? this._ModelClass : this._ModelClass = this.getFacade().getListModel(modelName, itemModelName);
  };


  /**
  creates an instance of BaseList by value
  
  @method createFromObject
  @public
  @param {any} obj
  @return {BaseList}
   */

  ListFactory.prototype.createFromObject = function(obj) {
    var ListModel, ids, items, list;
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
          obj = items[i];
          results.push(this.createItemFromObject(obj));
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

  ListFactory.prototype.createItemFromObject = function(obj) {
    var itemFactory;
    itemFactory = this.getFacade().createFactory(this.constructor.itemModelName, true);
    return itemFactory.createFromObject(obj);
  };

  return ListFactory;

})(BaseFactory);

module.exports = ListFactory;
