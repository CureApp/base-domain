var Base, BaseRepository, Entity, GeneralFactory,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');

Entity = require('./entity');

GeneralFactory = require('./general-factory');


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

  BaseRepository.prototype.client = null;


  /**
  constructor
  
  @constructor
  @params {ResourceClientInterface} client
  @params {RootInterface} root
  @return
   */

  function BaseRepository(root) {
    var modelName, ref;
    BaseRepository.__super__.constructor.call(this, root);
    modelName = (ref = this.constructor.modelName) != null ? ref : this.constructor.getName().slice(0, -'-repository'.length);

    /**
    factory of the entity.
    
    @property {FactoryInterface} factory
     */
    this.factory = GeneralFactory.create(modelName, this.root);
    if (!((this.factory.getModelClass().prototype) instanceof Entity)) {
      this.error('base-domain:repositoryWithNonEntity', "cannot define repository to non-entity: '" + modelName + "'");
    }
  }


  /**
  get model class this factory handles
  
  @method getModelClass
  @return {Class}
   */

  BaseRepository.prototype.getModelClass = function() {
    return this.factory.getModelClass();
  };


  /**
  returns Promise or the result of given function
  @return {any}
  @protected
   */

  BaseRepository.prototype.resolve = function(result, fn) {
    if (result instanceof Promise) {
      return result.then((function(_this) {
        return function(obj) {
          return fn.call(_this, obj);
        };
      })(this));
    } else {
      return fn.call(this, result);
    }
  };


  /**
  Update or insert a model instance
  
  @method save
  @public
  @param {Entity|Object} entity
  @param {ResourceClientInterface} [client=@client]
  @return {Entity|Promise(Entity)} entity (the same instance from input, if entity given,)
   */

  BaseRepository.prototype.save = function(entity, client) {
    var data;
    if (!(entity instanceof Entity)) {
      entity = this.factory.createFromObject(entity);
    }
    if (client == null) {
      client = this.client;
    }
    data = entity.toPlainObject();
    this.appendTimeStamp(data);
    return this.resolve(client.upsert(data), function(obj) {
      var newEntity;
      newEntity = this.factory.createFromObject(obj);
      return entity.inherit(newEntity);
    });
  };


  /**
  get entity by id.
  
  @method get
  @public
  @param {String|Number} id
  @param {ResourceClientInterface} [client=@client]
  @return {Entity|Promise(Entity)} entity
   */

  BaseRepository.prototype.get = function(id, client) {
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.findById(id), function(obj) {
      return this.factory.createFromObject(obj);
    });
  };


  /**
  alias for get()
  
  @method getById
  @public
  @param {String|Number} id
  @param {ResourceClientInterface} [client=@client]
  @return {Entity|Promise(Entity)} entity
   */

  BaseRepository.prototype.getById = function(id, client) {
    return this.get(id, client);
  };


  /**
  get entities by id.
  
  @method getByIds
  @public
  @param {Array|(String|Number)} ids
  @param {ResourceClientInterface} [client=@client]
  @return {Array(Entity)|Promise(Array(Entity))} entities
   */

  BaseRepository.prototype.getByIds = function(ids, client) {
    var existence, id, results;
    results = (function() {
      var i, len, results1;
      results1 = [];
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        results1.push(this.get(id, client));
      }
      return results1;
    }).call(this);
    existence = function(val) {
      return val != null;
    };
    if (results[0] instanceof Promise) {
      return Promise.all(results).then(function(models) {
        return models.filter(existence);
      });
    } else {
      return results.filter(existence);
    }
  };


  /**
  get all entities
  
  @method getAll
  @return {Array(Entity)|Promise(Array(Entity))} array of entities
   */

  BaseRepository.prototype.getAll = function() {
    return this.query({});
  };


  /**
  Find all model instances that match params
  
  @method query
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Array(Entity)|Promise(Array(Entity))} array of entities
   */

  BaseRepository.prototype.query = function(params, client) {
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.find(params), function(objs) {
      var obj;
      return (function() {
        var i, len, results1;
        results1 = [];
        for (i = 0, len = objs.length; i < len; i++) {
          obj = objs[i];
          results1.push(this.factory.createFromObject(obj));
        }
        return results1;
      }).call(this);
    });
  };


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {ResourceClientInterface} [client=@client]
  @return {Entity|Promise(Entity)} entity
   */

  BaseRepository.prototype.singleQuery = function(params, client) {
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
  @return {Boolean|Promise(Boolean)} isDeleted
   */

  BaseRepository.prototype["delete"] = function(entity, client) {
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
  @param {String|Number} id id of the entity to update
  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
  @param {ResourceClientInterface} [client=@client]
  @return {Entity|Promise(Entity)} updated entity
   */

  BaseRepository.prototype.update = function(id, data, client) {
    var isUpdate;
    if (data instanceof Entity) {
      throw this.error('base-domain:updateWithModelInhihited', "update entity with BaseRepository#update() is not allowed.\nuse BaseRepository#save(entity) instead");
    }
    if (client == null) {
      client = this.client;
    }
    this.appendTimeStamp(data, isUpdate = true);
    return this.resolve(client.updateAttributes(id, data), function(obj) {
      return this.factory.createFromObject(obj);
    });
  };


  /**
  add createdAt, updatedAt to given data
  - createdAt will not be overriden if already set.
  - updatedAt will be overriden for each time
  
  @method appendTimeStamp
  @protected
  @param {Object} data 
  @param {Boolean} isUpdate true when updating
  @return {Object} data
   */

  BaseRepository.prototype.appendTimeStamp = function(data, isUpdate) {
    var Model, now, propCreatedAt, propUpdatedAt;
    if (isUpdate == null) {
      isUpdate = false;
    }
    Model = this.getModelClass();
    propCreatedAt = Model.getModelProps().createdAt;
    propUpdatedAt = Model.getModelProps().updatedAt;
    now = new Date().toISOString();
    if (propCreatedAt && !isUpdate) {
      if (data[propCreatedAt] == null) {
        data[propCreatedAt] = now;
      }
    }
    if (propUpdatedAt) {
      data[propUpdatedAt] = now;
    }
    return data;
  };

  return BaseRepository;

})(Base);

module.exports = BaseRepository;
