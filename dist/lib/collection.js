var Collection, ValueObject,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

ValueObject = require('./value-object');


/**
collection model of one model


add      -> addItems -> addItem
setItems -> addItems -> addItem -> emit loaded event

add() is public and setItems is package-level access

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
  ids: get ids of items
  
  @property {Array(String|Number)} ids
   */

  Object.defineProperty(Collection.prototype, 'ids', {
    get: function() {
      var item, key;
      if (!this.isItemEntity) {
        return null;
      }
      return (function() {
        var ref, results;
        ref = this.items;
        results = [];
        for (key in ref) {
          item = ref[key];
          results.push(item.id);
        }
        return results;
      }).call(this);
    }
  });


  /**
  the number of items
  
  @property {Number} length
  @public
  @abstract
   */


  /**
  items (submodel collection)
  
  @property {Object} items
  @abstract
   */

  Collection.prototype.items = null;


  /**
  @constructor
  @params {any} props
  @params {RootInterface} root
   */

  function Collection(props, root) {
    var _itemFactory, isItemEntity;
    if (props == null) {
      props = {};
    }
    if (this.constructor.itemModelName == null) {
      throw this.error('base-domain:itemModelNameRequired', "@itemModelName is not set, in class " + this.constructor.name);
    }
    Collection.__super__.constructor.call(this, props, root);
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

      /**
      loaded: is data loaded or not
      
      @property loaded
      @type Boolean
       */
      loaded: {
        value: false,
        writable: true
      },
      isItemEntity: {
        value: isItemEntity,
        writable: false
      }
    });
    if (props.items) {
      this.setItems(props.items);
    }
    if (props.ids) {
      this.setIds(props.ids);
    }
  }


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
    var factory, item, key, results;
    if (items == null) {
      items = [];
    }
    factory = this.itemFactory;
    results = [];
    for (key in items) {
      item = items[key];
      results.push(this.addItem(factory.createFromObject(item)));
    }
    return results;
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
  set ids.
  
  @method setIds
  @param {Array(String|Number)} ids
  @chainable
   */

  Collection.prototype.setIds = function(ids) {
    var Includer, repo, subModels;
    if (ids == null) {
      ids = [];
    }
    if (!this.isItemEntity) {
      return;
    }
    this.loaded = false;
    if (ids.length === 0) {
      return this.setItems();
    }
    Includer = require('./includer');
    repo = new Includer(this).createRepository(this.constructor.itemModelName);
    if (repo == null) {
      console.error("base-domain:no repository found.\nModel '" + this.constructor.itemModelName + "' cannot be loaded by id.\nGiven ids : " + (ids.join(',')) + " were not set.");
      return this;
    }
    if (repo.constructor.isSync) {
      subModels = repo.getByIds(ids);
      this.setItems(subModels);
    } else {
      repo.getByIds(ids).then((function(_this) {
        return function(subModels) {
          return _this.setItems(subModels);
        };
      })(this));
    }
    return this;
  };


  /**
  set items and emit "loaded" event
  
  @method setItems
  @param {Object|Array(BaseModel|Object)} items
   */

  Collection.prototype.setItems = function(items) {
    if (items == null) {
      items = [];
    }
    this.addItems(items);
    this.loaded = true;
    this.emitNext('loaded');
    return this;
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
