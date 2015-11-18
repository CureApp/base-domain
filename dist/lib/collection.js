var Collection, EntityPool, ValueObject,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

ValueObject = require('./value-object');

EntityPool = require('../entity-pool');


/**
collection model of one model

@class Collection
@extends ValueObject
@module base-domain
 */

Collection = (function(superClass) {
  extend(Collection, superClass);


  /**
  model name of the item
  
  @property itemModelName
  @static
  @protected
  @type String
   */

  Collection.itemModelName = null;


  /**
  the number of items (or ids when @isItemEntity is true)
  
  @property {Number} length
  @public
   */

  Object.defineProperty(Collection.prototype, 'length', {
    get: function() {
      if (this.isItemEntity) {
        return this.ids.length;
      } else {
        return this.itemLength;
      }
    }
  });


  /**
  items (submodel collection)
  
  @property {Object} items
  @abstract
   */


  /**
  @constructor
  @params {any} props
  @params {RootInterface} root
   */

  function Collection(props, root) {
    var _itemFactory, ids, isItemEntity;
    if (props == null) {
      props = {};
    }
    this.setRoot(root);
    if (this.constructor.itemModelName == null) {
      throw this.error('base-domain:itemModelNameRequired', "@itemModelName is not set, in class " + this.constructor.name);
    }
    _itemFactory = null;
    isItemEntity = this.getFacade().getModel(this.constructor.itemModelName).isEntity;
    Object.defineProperties(this, {

      /**
      item factory
      Created only one time. Be careful that @root is not changed even the collection's root is changed.
      
      @property {FactoryInterface} itemFactory
       */
      itemFactory: {
        get: function() {
          return _itemFactory != null ? _itemFactory : _itemFactory = require('./general-factory').create(this.constructor.itemModelName, this.root);
        }
      },
      isItemEntity: {
        value: isItemEntity,
        writable: false
      }
    });
    this.clear();
    if ((props.ids != null) && props.items) {
      ids = props.ids;
      delete props.ids;
      Collection.__super__.constructor.call(this, props, root);
      props.ids = ids;
    } else {
      Collection.__super__.constructor.call(this, props, root);
    }
  }


  /**
  Get the copy of ids
  @return {Array(String)} ids
   */

  Collection.prototype.getIds = function() {
    var ref;
    if (!this.isItemEntity) {
      return void 0;
    }
    return (ref = this.ids) != null ? ref.slice() : void 0;
  };


  /**
  set value to prop
  @return {BaseModel} this
   */

  Collection.prototype.set = function(k, v) {
    switch (k) {
      case 'items':
        this.setItems(v);
        break;
      case 'ids':
        this.setIds(v);
        break;
      default:
        Collection.__super__.set.apply(this, arguments);
    }
    return this;
  };


  /**
  add new submodel to item(s)
  
  @method add
  @public
  @param {BaseModel|Object} ...items
   */

  Collection.prototype.add = function() {
    var items;
    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return this.addItems(items);
  };


  /**
  @method addItems
  @param {Object|Array(BaseModel|Object)} items
  @protected
   */

  Collection.prototype.addItems = function(items) {
    var factory, item, key;
    if (items == null) {
      items = [];
    }
    if (!this.loaded()) {
      this.initItems();
    }
    factory = this.itemFactory;
    for (key in items) {
      item = items[key];
      this.addItem(factory.createFromObject(item));
    }
    if (this.isItemEntity) {
      return this.ids = (function() {
        var i, len, ref, results;
        ref = this.toArray();
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          item = ref[i];
          results.push(item.id);
        }
        return results;
      }).call(this);
    }
  };


  /**
  add item to @items
  
  @method addItem
  @protected
  @abstract
  @param {BaseModel} item
   */

  Collection.prototype.addItem = function(item) {};


  /**
  clear and set ids.
  
  @method setIds
  @param {Array(String|Number)} ids
  @chainable
   */

  Collection.prototype.setIds = function(ids) {
    if (ids == null) {
      ids = [];
    }
    if (!this.isItemEntity) {
      return;
    }
    if (!Array.isArray(ids)) {
      return;
    }
    this.clear();
    return this.ids = ids;
  };


  /**
  clear and add items
  
  @method setItems
  @param {Object|Array(BaseModel|Object)} items
   */

  Collection.prototype.setItems = function(items) {
    if (items == null) {
      items = [];
    }
    this.clear();
    this.addItems(items);
    return this;
  };


  /**
  removes all items and ids
  
  @method clear
   */

  Collection.prototype.clear = function() {
    delete this.items;
    if (this.isItemEntity) {
      return this.ids = [];
    }
  };


  /**
  export items to Array
  
  @method toArray
  @public
  @abstract
  @return {Array}
   */

  Collection.prototype.toArray = function() {};


  /**
  Execute given function for each item
  
  @method forEach
  @public
  @param {Function} fn
  @param {Object} _this
   */

  Collection.prototype.forEach = function(fn, _this) {
    this.map(fn, _this);
  };


  /**
  Execute given function for each item
  returns an array of the result
  
  @method map
  @public
  @param {Function} fn
  @param {Object} _this
  @return {Array}
   */

  Collection.prototype.map = function(fn, _this) {
    var i, item, len, ref, results;
    if (_this == null) {
      _this = this;
    }
    if (typeof fn !== 'function') {
      return [];
    }
    ref = this.toArray();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      results.push(fn.call(_this, item));
    }
    return results;
  };


  /**
  Filter items with given function
  
  @method filter
  @public
  @param {Function} fn
  @param {Object} _this
  @return {Array}
   */

  Collection.prototype.filter = function(fn, _this) {
    if (_this == null) {
      _this = this;
    }
    if (typeof fn !== 'function') {
      return this.toArray();
    }
    return this.toArray().filter(fn, _this);
  };


  /**
  Returns if some items match the condition in given function
  
  @method some
  @public
  @param {Function} fn
  @param {Object} _this
  @return {Boolean}
   */

  Collection.prototype.some = function(fn, _this) {
    if (_this == null) {
      _this = this;
    }
    if (typeof fn !== 'function') {
      return false;
    }
    return this.toArray().some(fn, _this);
  };


  /**
  Returns if every items match the condition in given function
  
  @method every
  @public
  @param {Function} fn
  @param {Object} _this
  @return {Boolean}
   */

  Collection.prototype.every = function(fn, _this) {
    if (_this == null) {
      _this = this;
    }
    if (typeof fn !== 'function') {
      return false;
    }
    return this.toArray().every(fn, _this);
  };

  Collection.prototype.initItems = function() {};


  /**
  include all relational models if not set
  
  @method include
  @param {Object} [options]
  @param {Boolean} [options.recursive] recursively include models or not
  @param {Boolean} [options.async=true] get async values
  @param {Array(String)} [options.props] include only given props
  @return {Promise(BaseModel)} self
   */

  Collection.prototype.include = function(options) {
    var superResult;
    if (options == null) {
      options = {};
    }
    if (options.entityPool == null) {
      options.entityPool = new EntityPool;
    }
    superResult = Collection.__super__.include.call(this, options);
    if (!this.isItemEntity) {
      return this.includeVOItems(options, superResult);
    } else {
      return this.includeEntityItems(options, superResult);
    }
  };

  Collection.prototype.includeVOItems = function(options, superResult) {
    if (!options.recursive) {
      return superResult;
    }
    return Promise.all([
      superResult, Promise.all(this.map(function(item) {
        return item.include(options);
      }))
    ]).then((function(_this) {
      return function() {
        return _this;
      };
    })(this));
  };

  Collection.prototype.includeEntityItems = function(options, superResult) {
    var EntityCollectionIncluder;
    EntityCollectionIncluder = require('./entity-collection-includer');
    return Promise.all([superResult, new EntityCollectionIncluder(this, options).include()]).then((function(_this) {
      return function() {
        return _this;
      };
    })(this));
  };


  /**
  create plain object.
  if this dict contains entities, returns their ids
  if this dict contains non-entity models, returns their plain objects
  
  @method toPlainObject
  @return {Object} plainObject
   */

  Collection.prototype.toPlainObject = function() {
    var item, key, plain, plainItems;
    plain = Collection.__super__.toPlainObject.call(this);
    if (this.isItemEntity) {
      plain.ids = this.ids.slice();
      delete plain.items;
    } else {
      plainItems = (function() {
        var ref, results;
        ref = this.items;
        results = [];
        for (key in ref) {
          item = ref[key];
          if (typeof item.toPlainObject === 'function') {
            results.push(item.toPlainObject());
          } else {
            results.push(item);
          }
        }
        return results;
      }).call(this);
      plain.items = plainItems;
    }
    return plain;
  };


  /**
  @method loaded
  @public
  @return {Boolean}
   */

  Collection.prototype.loaded = function() {
    return this.items != null;
  };


  /**
  get item model
  @method getItemModelClass
  @return {Function}
   */

  Collection.prototype.getItemModelClass = function() {
    return this.getFacade().getModel(this.constructor.itemModelName);
  };

  return Collection;

})(ValueObject);

module.exports = Collection;
