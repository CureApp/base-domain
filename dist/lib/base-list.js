var BaseList, BaseModel,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseModel = require('./base-model');


/**
list class of DDD pattern.

@class BaseList
@extends BaseModel
@module base-domain
 */

BaseList = (function(superClass) {
  extend(BaseList, superClass);


  /**
  model name of the item
  
  @property itemModelName
  @static
  @protected
  @type String
   */

  BaseList.itemModelName = '';


  /**
  creates child class of BaseList
  
  @method getAnonymousClass
  @params {String} itemModelName
  @return {Function} child class of BaseList
   */

  BaseList.getAnonymousClass = function(itemModelName) {
    var AnonymousList;
    AnonymousList = (function(superClass1) {
      extend(AnonymousList, superClass1);

      function AnonymousList() {
        return AnonymousList.__super__.constructor.apply(this, arguments);
      }

      AnonymousList.itemModelName = itemModelName;

      return AnonymousList;

    })(BaseList);
    return AnonymousList;
  };


  /**
  ids: get ids of items
  
  @property ids
  @type Array
  @public
   */

  Object.defineProperty(BaseList.prototype, 'ids', {
    get: function() {
      var item;
      if (!this.constructor.containsEntity()) {
        return null;
      }
      return (function() {
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
  });


  /**
  items: array of models
  
  @property items
  @type Array
   */


  /**
  loaded: is data loaded or not
  
  @property loaded
  @type Boolean
   */


  /**
  @constructor
   */

  function BaseList(props) {
    if (props == null) {
      props = {};
    }
    Object.defineProperties(this, {
      items: {
        value: []
      },
      loaded: {
        value: false,
        writable: true
      },
      listeners: {
        value: []
      }
    });
    if (props.items) {
      this.setItems(props.items);
    }
    if (props.ids) {
      this.setIds(props.ids);
    }
    BaseList.__super__.constructor.call(this, props);
  }


  /**
  set ids.
  
  @method setIds
  @param {Array(String|Number)} ids
   */

  BaseList.prototype.setIds = function(ids) {
    var ItemRepository, id, repo, subModels;
    if (ids == null) {
      ids = [];
    }
    if (!this.constructor.containsEntity()) {
      return;
    }
    this.loaded = false;
    ItemRepository = this.getFacade().getRepository(this.constructor.itemModelName);
    repo = new ItemRepository();
    if (ItemRepository.storeMasterTable && ItemRepository.loaded()) {
      subModels = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = ids.length; i < len; i++) {
          id = ids[i];
          results.push(repo.getByIdSync(id));
        }
        return results;
      })();
      this.setItems(subModels);
    } else {
      repo.query({
        where: {
          id: {
            inq: ids
          }
        }
      }).then((function(_this) {
        return function(subModels) {
          return _this.setItems(subModels);
        };
      })(this));
    }
    return this;
  };


  /**
  set items
  
  @method setItems
  @param {Array} models
   */

  BaseList.prototype.setItems = function(models) {
    var ItemClass, i, item, len;
    if (models == null) {
      models = [];
    }
    ItemClass = this.getFacade().getModel(this.constructor.itemModelName);
    for (i = 0, len = models.length; i < len; i++) {
      item = models[i];
      if (item instanceof ItemClass) {
        this.items.push(item);
      }
    }
    this.items.sort(this.sort);
    this.loaded = true;
    this.emitLoaded();
    return this;
  };


  /**
  returns item is Entity
  
  @method containsEntity
  @static
  @public
  @return {Boolean}
   */

  BaseList.containsEntity = function() {
    return this.getFacade().getModel(this.itemModelName).isEntity;
  };


  /**
  sort items in constructor
  
  @method sort
  @protected
   */

  BaseList.prototype.sort = function(modelA, modelB) {
    if (modelA.id > modelB.id) {
      return 1;
    } else {
      return -1;
    }
  };


  /**
  first item
  
  @method first
  @public
   */

  BaseList.prototype.first = function() {
    if (this.items.length === 0) {
      return null;
    }
    return this.items[0];
  };


  /**
  last item
  
  @method last
  @public
   */

  BaseList.prototype.last = function() {
    if (this.items.length === 0) {
      return null;
    }
    return this.items[this.items.length - 1];
  };


  /**
  export models to Array
  
  @method toArray
  @public
   */

  BaseList.prototype.toArray = function() {
    return this.items.slice();
  };


  /**
  create plain list.
  if this list contains entities, returns their ids
  if this list contains non-entity models, returns their plain objects 
  
  @method toPlainObject
  @return {Object} plainObject
   */

  BaseList.prototype.toPlainObject = function() {
    var i, item, len, plain, plainItems, ref;
    plain = BaseList.__super__.toPlainObject.call(this);
    if (this.constructor.containsEntity()) {
      plain.ids = this.ids;
    } else {
      plainItems = [];
      ref = this.items;
      for (i = 0, len = ref.length; i < len; i++) {
        item = ref[i];
        if (typeof item.toPlainObject === 'function') {
          plainItems.push(item.toPlainObject());
        } else {
          plainItems.push(item);
        }
      }
      plain.items = plainItems;
    }
    return plain;
  };


  /**
  on addEventListeners for 'loaded'
  
  @method on
  @public
   */

  BaseList.prototype.on = function(evtname, fn) {
    if (evtname !== 'loaded') {
      return;
    }
    if (this.loaded) {
      process.nextTick(fn);
    } else if (typeof fn === 'function') {
      this.listeners.push(fn);
    }
  };


  /**
  tell listeners emit loaded
  @method emitLoaded
  @private
   */

  BaseList.prototype.emitLoaded = function() {
    var fn;
    while (fn = this.listeners.shift()) {
      process.nextTick(fn);
    }
  };

  return BaseList;

})(BaseModel);

module.exports = BaseList;
