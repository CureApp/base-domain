var BaseRepository, BaseSyncRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseRepository = require('./base-repository');


/**
sync repository
@class BaseSyncRepository
@extends BaseRepository
@module base-domain
 */

BaseSyncRepository = (function(superClass) {
  extend(BaseSyncRepository, superClass);

  function BaseSyncRepository() {
    return BaseSyncRepository.__super__.constructor.apply(this, arguments);
  }

  BaseSyncRepository.isSync = true;


  /**
  returns the result of the function
  
  @return {any}
  @protected
   */

  BaseSyncRepository.prototype.resolve = function(result, fn) {
    return fn.call(this, result);
  };


  /**
  get entities by ID.
  
  @method getByIds
  @public
  @param {Array} ids
  @param {ResourceClientInterface} [client=@client]
  @return {Array(Entity)} entities
   */

  BaseSyncRepository.prototype.getByIds = function(ids, client) {
    var id;
    return ((function() {
      var i, len, results;
      results = [];
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        results.push(this.get(id, client));
      }
      return results;
    }).call(this)).filter(function(model) {
      return model != null;
    });
  };


  /**
  Update or insert a model instance
  
  @method save
  @public
  @param {Entity|Object} entity
  @param {ResourceClientInterface} [client=@client]
  @return {Entity} entity (the same instance from input, if entity given,)
   */


  /**
  get object by ID.
  
  @method get
  @public
  @param {any} id
  @param {ResourceClientInterface} [client=@client]
  @return {Entity} entity
   */


  /**
  alias for get()
  
  @method getById
  @public
  @param {any} id
  @param {ResourceClientInterface} [client=@client]
  @return {Entity} entity
   */


  /**
  get all entities
  
  @method getAll
  @return {Array(Entity)} array of entities
   */


  /**
  Find all model instances that match params
  
  @method query
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Array(Entity)} array of entities
   */


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Entity|} entity
   */

  BaseSyncRepository.prototype.singleQuery = function(params, client) {
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.findOne(params), function(obj) {
      return this.factory.createFromObject(obj);
    });
  };


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @param {ResourceClientInterface} [client=@client]
  @return {Boolean} isDeleted
   */

  BaseSyncRepository.prototype["delete"] = function(entity, client) {
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.destroy(entity), function() {
      return true;
    });
  };


  /**
  Update set of attributes.
  
  @method update
  @public
  @param {any} id id of the entity to update
  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
  @param {ResourceClientInterface} [client=@client]
  @return {Entity} updated entity
   */

  BaseSyncRepository.prototype.update = function(id, data, client) {
    var isUpdate;
    if (data instanceof Entity) {
      throw this.getFacade().error("update entity with BaseRepository#update() is not allowed.\nuse BaseRepository#save(entity) instead");
    }
    if (client == null) {
      client = this.client;
    }
    this.appendTimeStamp(data, isUpdate = true);
    return this.resolve(client.updateAttributes(id, data), function(obj) {
      return this.factory.createFromObject(obj);
    });
  };

  return BaseSyncRepository;

})(BaseRepository);

module.exports = BaseSyncRepository;
