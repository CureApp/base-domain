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
  @param {Array(String|Number)} ids
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Array(Entity)} entities
   */

  BaseSyncRepository.prototype.getByIds = function(ids, options) {
    var id;
    return ((function() {
      var i, len, results;
      results = [];
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        results.push(this.get(id, options));
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
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity} entity (the same instance from input, if entity given,)
   */


  /**
  get object by id.
  
  @method get
  @public
  @param {String|Number} id
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity} entity
   */


  /**
  alias for get()
  
  @method getById
  @public
  @param {String|Number} id
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
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
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Array(Entity)} array of entities
   */


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity|} entity
   */


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @param {ResourceClientInterface} [client=@client]
  @return {Boolean} isDeleted
   */


  /**
  Update set of attributes.
  
  @method update
  @public
  @param {String|Number} id of the entity to update
  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity} updated entity
   */

  return BaseSyncRepository;

})(BaseRepository);

module.exports = BaseSyncRepository;
