'use strict';
var Base, BaseRepository, Entity, GeneralFactory, isPromise,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');

Entity = require('./entity');

GeneralFactory = require('./general-factory');

isPromise = require('../util').isPromise;


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

  BaseRepository.prototype.getModelName = function() {
    var ref;
    return (ref = this.constructor.modelName) != null ? ref : this.constructor.getName().slice(0, -'-repository'.length);
  };


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
  @params {RootInterface} root
  @return
   */

  function BaseRepository(root) {
    var modelName;
    BaseRepository.__super__.constructor.call(this, root);
    modelName = this.getModelName();

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
    if (isPromise(result)) {
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
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity|Promise(Entity)} entity (the same instance from input, if entity given,)
   */

  BaseRepository.prototype.save = function(entity, options) {
    var client, data, method;
    if (options == null) {
      options = {};
    }
    client = options.client;
    delete options.client;
    if (!(entity instanceof Entity)) {
      entity = this.factory.createFromObject(entity, options);
    }
    if (client == null) {
      client = this.client;
    }
    data = entity.toPlainObject();
    this.appendTimeStamp(data);
    method = (function() {
      switch (options.method) {
        case 'upsert':
        case 'create':
          return options.method;
        default:
          return 'upsert';
      }
    })();
    return this.resolve(client[method](data), function(obj) {
      var newEntity;
      newEntity = this.createFromResult(obj, options);
      return entity.inherit(newEntity);
    });
  };


  /**
  get entity by id.
  
  @method get
  @public
  @param {String|Number} id
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity|Promise(Entity)} entity
   */

  BaseRepository.prototype.get = function(id, options) {
    var client;
    if (options == null) {
      options = {};
    }
    client = options.client;
    delete options.client;
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.findById(id), function(obj) {
      return this.createFromResult(obj, options);
    });
  };


  /**
  alias for get()
  
  @method getById
  @public
  @param {String|Number} id
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity|Promise(Entity)} entity
   */

  BaseRepository.prototype.getById = function(id, options) {
    return this.get(id, options);
  };


  /**
  get entities by id.
  
  @method getByIds
  @public
  @param {Array|(String|Number)} ids
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Array(Entity)|Promise(Array(Entity))} entities
   */

  BaseRepository.prototype.getByIds = function(ids, options) {
    var existence, id, results;
    results = (function() {
      var i, len, results1;
      results1 = [];
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        results1.push(this.get(id, options));
      }
      return results1;
    }).call(this);
    existence = function(val) {
      return val != null;
    };
    if (isPromise(results[0])) {
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
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Array(Entity)|Promise(Array(Entity))} array of entities
   */

  BaseRepository.prototype.query = function(params, options) {
    var client;
    if (options == null) {
      options = {};
    }
    client = options.client;
    delete options.client;
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.find(params), function(objs) {
      return this.createFromQueryResults(params, objs, options);
    });
  };


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity|Promise(Entity)} entity
   */

  BaseRepository.prototype.singleQuery = function(params, options) {
    var client;
    if (options == null) {
      options = {};
    }
    client = options.client;
    delete options.client;
    if (client == null) {
      client = this.client;
    }
    return this.resolve(client.findOne(params), function(obj) {
      return this.createFromResult(obj, options);
    });
  };


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Boolean|Promise(Boolean)} isDeleted
   */

  BaseRepository.prototype["delete"] = function(entity, options) {
    var client;
    if (options == null) {
      options = {};
    }
    client = options.client;
    delete options.client;
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
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Entity|Promise(Entity)} updated entity
   */

  BaseRepository.prototype.update = function(id, data, options) {
    var client, isUpdate;
    if (options == null) {
      options = {};
    }
    client = options.client;
    delete options.client;
    if (data instanceof Entity) {
      throw this.error('base-domain:updateWithModelInhihited', "update entity with BaseRepository#update() is not allowed.\nuse BaseRepository#save(entity) instead");
    }
    if (client == null) {
      client = this.client;
    }
    this.appendTimeStamp(data, isUpdate = true);
    return this.resolve(client.updateAttributes(id, data), function(obj) {
      return this.createFromResult(obj, options);
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
    var modelProps, now, propCreatedAt, propUpdatedAt;
    if (isUpdate == null) {
      isUpdate = false;
    }
    modelProps = this.getFacade().getModelProps(this.getModelName());
    propCreatedAt = modelProps.createdAt;
    propUpdatedAt = modelProps.updatedAt;
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


  /**
  Create model instance from result from client
  
  @method createFromResult
  @protected
  @param {Object} obj
  @param {Object} [options]
  @return {BaseModel} model
   */

  BaseRepository.prototype.createFromResult = function(obj, options) {
    return this.factory.createFromObject(obj, options);
  };


  /**
  Create model instances from query results
  
  @method createFromQueryResults
  @protected
  @param {Object} params
  @param {Array(Object)} objs
  @param {Object} [options]
  @return {Array(BaseModel)} models
   */

  BaseRepository.prototype.createFromQueryResults = function(params, objs, options) {
    var i, len, obj, results1;
    results1 = [];
    for (i = 0, len = objs.length; i < len; i++) {
      obj = objs[i];
      results1.push(this.createFromResult(obj, options));
    }
    return results1;
  };

  return BaseRepository;

})(Base);

module.exports = BaseRepository;
