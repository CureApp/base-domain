
/**
@class EntityPool
@module base-domain
 */
var EntityPool;

EntityPool = (function() {
  function EntityPool() {}


  /**
  Register an entity to pool
  @method set
  @param {Entity} model
   */

  EntityPool.prototype.set = function(model) {
    var Model, modelName;
    Model = model.constructor;
    if (!Model.isEntity || ((model != null ? model.id : void 0) == null)) {
      return;
    }
    modelName = Model.getName();
    if (EntityPool.prototype[modelName]) {
      throw new Error("invalid model name " + modelName);
    }
    if (this[modelName] == null) {
      this[modelName] = {};
    }
    return this[modelName][model.id] = model;
  };


  /**
  Get registred models by model name and id
  
  @method get
  @param {String} modelName
  @param {String} id
  @return {Entity}
   */

  EntityPool.prototype.get = function(modelName, id) {
    var ref;
    return (ref = this[modelName]) != null ? ref[id] : void 0;
  };


  /**
  Clear all the registered entities
  
  @method clear
   */

  EntityPool.prototype.clear = function() {
    var id, modelName, models, results;
    results = [];
    for (modelName in this) {
      models = this[modelName];
      for (id in models) {
        delete models[id];
      }
      results.push(delete models[modelName]);
    }
    return results;
  };

  return EntityPool;

})();

module.exports = EntityPool;
