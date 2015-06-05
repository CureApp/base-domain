var Base, BaseRepository, Entity, ResourceClientInterface,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');

ResourceClientInterface = require('./resource-client-interface');

Entity = require('./entity');


/**
Base repository class of DDD pattern.
Responsible for perpetuation of models.
BaseRepository has a client, which access to data resource (RDB, NoSQL, memory, etc...)

the parent "Base" class just simply gives a @getFacade() method.

@class BaseRepository
@extends Base
@module base-domain
 */

BaseRepository = (function(superClass) {
  extend(BaseRepository, superClass);


  /**
  model name to handle
  
  @property modelName
  @static
  @protected
  @type String
   */

  BaseRepository.modelName = null;


  /**
  client accessing to data resource (RDB, NoSQL, memory, etc...)
  
  mock object is input by default.
  Extenders must set this property to achieve perpetuation
  
  @property client
  @abstract
  @protected
  @type ResourceClientInterface
   */

  BaseRepository.prototype.client = new ResourceClientInterface();


  /**
  constructor
  
  @constructor
  @return
   */

  function BaseRepository() {
    var facade, modelName, useAnonymousFactory;
    modelName = this.constructor.modelName;
    facade = this.getFacade();
    useAnonymousFactory = true;
    this.factory = facade.createFactory(modelName, useAnonymousFactory);
  }


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Class}
   */

  BaseRepository.prototype.getModelClass = function() {
    var modelName;
    modelName = this.constructor.modelName;
    return this.getFacade().getModel(modelName);
  };


  /**
  Update or insert a model instance
  
  @method save
  @public
  @param {Entity|Object} entity
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} entity (the same instance from input, if entity given,)
   */

  BaseRepository.prototype.save = function(entity, client) {
    var data, isCreate;
    if (!(entity instanceof Entity)) {
      entity = this.factory.createFromObject(entity);
    }
    if (client == null) {
      client = this.client;
    }
    isCreate = entity.id == null;
    data = entity.toPlainObject();
    this.appendTimeStamp(data, isCreate);
    return client.upsert(data).then((function(_this) {
      return function(obj) {
        var newEntity;
        newEntity = _this.factory.createFromObject(obj);
        return entity.inherit(newEntity);
      };
    })(this));
  };


  /**
  get object by ID.
  
  @method get
  @public
  @param {any} id
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} entity
   */

  BaseRepository.prototype.get = function(id, client) {
    if (client == null) {
      client = this.client;
    }
    return client.findById(id).then((function(_this) {
      return function(obj) {
        return _this.factory.createFromObject(obj);
      };
    })(this));
  };


  /**
  alias for get()
  
  @method getById
  @public
  @param {any} id
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} entity
   */

  BaseRepository.prototype.getById = function(id, client) {
    return this.get(id, client);
  };


  /**
  Find all model instances that match params
  
  @method query
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Array(Entity))} array of entities
   */

  BaseRepository.prototype.query = function(params, client) {
    if (client == null) {
      client = this.client;
    }
    return client.find(params).then((function(_this) {
      return function(objs) {
        var obj;
        return (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = objs.length; i < len; i++) {
            obj = objs[i];
            results.push(this.factory.createFromObject(obj));
          }
          return results;
        }).call(_this);
      };
    })(this));
  };


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} entity
   */

  BaseRepository.prototype.singleQuery = function(params, client) {
    if (client == null) {
      client = this.client;
    }
    return client.findOne(params).then((function(_this) {
      return function(obj) {
        return _this.factory.createFromObject(obj);
      };
    })(this));
  };


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Boolean)} isDeleted
   */

  BaseRepository.prototype["delete"] = function(entity, client) {
    if (client == null) {
      client = this.client;
    }
    return client.destroy(entity).then((function(_this) {
      return function() {
        return true;
      };
    })(this));
  };


  /**
  Update set of attributes.
  
  @method update
  @public
  @param {any} id id of the entity to update
  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
  @param {ResourceClientInterface} [client=@client]
  @return {Promise(Entity)} updated entity
   */

  BaseRepository.prototype.update = function(id, data, client) {
    var isCreate;
    if (data instanceof Entity) {
      throw this.getFacade().error("update entity with BaseRepository#update() is not allowed.\nuse BaseRepository#save(entity) instead");
    }
    if (client == null) {
      client = this.client;
    }
    isCreate = false;
    this.appendTimeStamp(data, isCreate);
    return client.updateAttributes(id, data).then((function(_this) {
      return function(obj) {
        return _this.factory.createFromObject(obj);
      };
    })(this));
  };


  /**
  add createdAt, updatedAt to given data
  - createdAt will not be overriden if already set.
  - updatedAt will be overriden for each time
  
  @method appendTimeStamp
  @protected
  @param {Object} data 
  @param {Boolean} [isCreate=false]
  @return {Object} data
   */

  BaseRepository.prototype.appendTimeStamp = function(data, isCreate) {
    var Model, propCreatedAt, propUpdatedAt;
    if (isCreate == null) {
      isCreate = false;
    }
    Model = this.getModelClass();
    propCreatedAt = Model.getPropInfo().createdAt;
    propUpdatedAt = Model.getPropInfo().updatedAt;
    if (isCreate && propCreatedAt) {
      if (data[propCreatedAt] == null) {
        data[propCreatedAt] = new Date().toISOString();
      }
    }
    if (propUpdatedAt) {
      data[propUpdatedAt] = new Date().toISOString();
    }
    return data;
  };

  return BaseRepository;

})(Base);

module.exports = BaseRepository;
