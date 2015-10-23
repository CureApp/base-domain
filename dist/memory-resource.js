var MemoryResource, Util;

Util = require('./util');


/**
sync memory storage, implements ResourceClientInterface

@class MemoryResource
@implements ResourceClientInterface
 */

MemoryResource = (function() {
  MemoryResource.restore = function(obj) {
    var currentIdNum, memoryResource, pool;
    pool = obj.pool, currentIdNum = obj.currentIdNum;
    memoryResource = new MemoryResource();
    memoryResource.pool = pool;
    memoryResource.currentIdNum = currentIdNum;
    return memoryResource;
  };

  function MemoryResource() {
    this.currentIdNum = 1;
    this.pool = {};
  }


  /**
  Generate id
  
  @method generateId
  @public
  @param {Object} data
  @return {String}
   */

  MemoryResource.prototype.generateId = function() {
    var id;
    id = this.currentIdNum;
    while (this.pool[id] != null) {
      id = ++this.currentIdNum;
    }
    return id.toString();
  };


  /**
  Create new instance of Model class, saved in database
  
  @method create
  @public
  @param {Object} data
  @return {Object}
   */

  MemoryResource.prototype.create = function(data) {
    if (data == null) {
      data = {};
    }
    if (data.id == null) {
      data.id = this.generateId();
    }
    return this.pool[data.id] = Util.clone(data);
  };


  /**
  Update or insert a model instance
  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
  
  @method upsert
  @public
  @param {Object} data
  @return {Object}
   */

  MemoryResource.prototype.upsert = function(data) {
    if (data == null) {
      data = {};
    }
    return this.create(data);
  };


  /**
  Find object by ID.
  
  @method findById
  @public
  @param {String} id
  @return {Object}
   */

  MemoryResource.prototype.findById = function(id) {
    return Util.clone(this.pool[id]);
  };


  /**
  Find all model instances that match filter specification.
  
  @method find
  @public
  @param {Object} filter
  @return {Array(Object)}
   */

  MemoryResource.prototype.find = function(filter) {
    var id, obj, where;
    if (filter == null) {
      filter = {};
    }
    where = filter.where;
    if (!where) {
      return (function() {
        var ref, results;
        ref = this.pool;
        results = [];
        for (id in ref) {
          obj = ref[id];
          results.push(Util.clone(obj));
        }
        return results;
      }).call(this);
    }
    throw new Error('"find" method with "where" is currently unimplemented.');
  };


  /**
  Find one model instance that matches filter specification. Same as find, but limited to one result
  
  @method findOne
  @public
  @param {Object} filter
  @return {Object}
   */

  MemoryResource.prototype.findOne = function(filter) {
    return this.find(filter)[0];
  };


  /**
  Destroy model instance
  
  @method destroyById
  @public
  @param {Object} data
   */

  MemoryResource.prototype.destroy = function(data) {
    return delete this.pool[data != null ? data.id : void 0];
  };


  /**
  Destroy model instance with the specified ID.
  
  @method destroyById
  @public
  @param {String} id
   */

  MemoryResource.prototype.destroyById = function(id) {
    return delete this.pool[id];
  };


  /**
  Update set of attributes.
  
  @method updateAttributes
  @public
  @param {Object} data
  @return {Object}
   */

  MemoryResource.prototype.updateAttributes = function(id, data) {
    var k, pooledData, v;
    pooledData = this.pool[id];
    throw new Error("id " + id + " is not found")((function() {
      var results;
      if (pooledData) {
        results = [];
        for (k in data) {
          v = data[k];
          results.push(pooledData[k] = v);
        }
        return results;
      }
    })());
    this.pool[id] = pooledData;
    return Util.clone(pooledData);
  };


  /**
  create plain object
  
  @method toPlainObject
  @return {Object} plainObject
   */

  MemoryResource.prototype.toPlainObject = function() {
    return {
      pool: Util.clone(this.pool),
      currentIdNum: this.currentIdNum
    };
  };

  return MemoryResource;

})();

module.exports = MemoryResource;
