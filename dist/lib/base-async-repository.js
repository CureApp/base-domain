var BaseAsyncRepository, BaseRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseRepository = require('./base-repository');


/**
async repository
@class BaseAsyncRepository
@extends BaseRepository
@module base-domain
 */

BaseAsyncRepository = (function(superClass) {
  extend(BaseAsyncRepository, superClass);

  function BaseAsyncRepository() {
    return BaseAsyncRepository.__super__.constructor.apply(this, arguments);
  }

  BaseAsyncRepository.isSync = false;


  /**
  returns Promise
  
  @return {Promise}
  @protected
   */

  BaseAsyncRepository.prototype.resolve = function(result, fn) {
    return Promise.resolve(result).then((function(_this) {
      return function(obj) {
        return fn.call(_this, obj);
      };
    })(this));
  };


  /**
  get entities by ID.
  
  @method getByIds
  @public
  @param {Array(String|Number)} ids
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Promise(Array(Entity))} entities
   */

  BaseAsyncRepository.prototype.getByIds = function(ids, options) {
    var id;
    return Promise.all((function() {
      var i, len, results;
      results = [];
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        results.push(this.get(id, options));
      }
      return results;
    }).call(this)).then(function(models) {
      return models.filter(function(model) {
        return model != null;
      });
    });
  };


  /**
  Update or insert a model instance
  
  @method save
  @public
  @param {Entity|Object} entity
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Promise(Entity)} entity (the same instance from input, if entity given,)
   */


  /**
  get object by id.
  
  @method get
  @public
  @param {String|Number} id
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} entity
   */


  /**
  alias for get()
  
  @method getById
  @public
  @param {String|Number} id
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Promise(Entity)} entity
   */


  /**
  get all entities
  
  @method getAll
  @return {Promise(Array(Entity))} array of entities
   */


  /**
  Find all model instances that match params
  
  @method query
  @public
  @param {Object} [params] query parameters
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Promise(Array(Entity))} array of entities
   */


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} entity
   */


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Promise(Boolean)} isDeleted
   */


  /**
  Update set of attributes.
  
  @method update
  @public
  @param {String|Number} id of the entity to update
  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Promise(Entity)} updated entity
   */

  return BaseAsyncRepository;

})(BaseRepository);

module.exports = BaseAsyncRepository;
