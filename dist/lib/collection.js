var Collection, Ids, ValueObject,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

ValueObject = require('./value-object');

Ids = require('./ids');


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
  ids: get ids of items
  
  @property {Ids} ids
   */

  Object.defineProperty(Collection.prototype, 'ids', {
    get: function() {
      var item, key;
      if (!this.constructor.containsEntity()) {
        return null;
      }
      return new Ids((function() {
        var ref, results;
        ref = this.items;
        results = [];
        for (key in ref) {
          item = ref[key];
          results.push(item.id);
        }
        return results;
      }).call(this));
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
  loaded: is data loaded or not
  
  @property loaded
  @type Boolean
   */


  /**
  @constructor
  @params {any} props
  @params {RootInterface} root
   */

  function Collection(props, root) {
    if (props == null) {
      props = {};
    }
    if (this.constructor.itemModelName == null) {
      throw this.getFacade().error("@itemModelName is not set, in class " + this.constructor.name);
    }
    Collection.__super__.constructor.call(this, props, root);
    Object.defineProperty(this, 'loaded', {
      value: false,
      writable: true
    });
    if (props.items) {
      this.setItems(props.items);
    }
    if (props.ids) {
      this.setIds(props.ids);
    }
  }


  /**
  add model(s)
  
  @method add
  @param {BaseModel} model
  @abstract
   */

  Collection.prototype.add = function() {
    var models;
    models = 1 <= arguments.length ? slice.call(arguments, 0) : [];
  };


  /**
  set ids.
  
  @method setIds
  @param {Ids|Array(String|Number)} ids
   */

  Collection.prototype.setIds = function(ids) {
    var repo, subModels;
    if (ids == null) {
      ids = [];
    }
    if (!this.constructor.containsEntity()) {
      return;
    }
    this.loaded = false;
    repo = this.root.createRepository(this.constructor.itemModelName);
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
  set items from dict object
  update to new key
  
  @method setItems
  @param {Object|Array} models
   */

  Collection.prototype.setItems = function(models) {
    var item, items, prevKey;
    if (models == null) {
      models = {};
    }
    items = (function() {
      var results;
      results = [];
      for (prevKey in models) {
        item = models[prevKey];
        results.push(item);
      }
      return results;
    })();
    this.add.apply(this, items);
    this.loaded = true;
    this.emitNext('loaded');
    return this;
  };


  /**
  returns item is Entity
  
  @method containsEntity
  @static
  @public
  @return {Boolean}
   */

  Collection.containsEntity = function() {
    return this.getFacade().getModel(this.itemModelName).isEntity;
  };


  /**
  export models to Array
  
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
    if (this.constructor.containsEntity()) {
      plain.ids = this.ids.toPlainObject();
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
  @method getItemModel
  @return {BaseModel}
   */

  Collection.prototype.getItemModel = function() {
    return this.getFacade().getModel(this.constructor.itemModelName);
  };

  return Collection;

})(ValueObject);

module.exports = Collection;
