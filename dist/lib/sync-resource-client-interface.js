
/**
interface of client accessing to resource synchronously.
Used in BaseSyncRepository

@class SyncResourceClientInterface
@module base-domain
 */
var SyncResourceClientInterface;

SyncResourceClientInterface = (function() {
  function SyncResourceClientInterface(memory) {
    this.memory = memory;
  }


  /**
  Create new instance of Model class, saved in database
  
  @method create
  @public
  @param {Object} data
  @return {Object}
   */

  SyncResourceClientInterface.prototype.create = function(data) {
    if (data == null) {
      data = {};
    }
    return this.memory.create(data);
  };


  /**
  Update or insert a model instance
  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
  
  @method upsert
  @public
  @param {Object} data
  @return {Object}
   */

  SyncResourceClientInterface.prototype.upsert = function(data) {
    if (data == null) {
      data = {};
    }
    return this.memory.upsert(data);
  };


  /**
  Find object by ID.
  
  @method findById
  @public
  @param {String} id
  @return {Object}
   */

  SyncResourceClientInterface.prototype.findById = function(id) {
    return this.memory.findById(id);
  };


  /**
  Find all model instances that match filter specification.
  
  @method find
  @public
  @param {Object} filter
  @return {Array(Object)}
   */

  SyncResourceClientInterface.prototype.find = function(filter) {
    return this.memory.find(filter);
  };


  /**
  Find one model instance that matches filter specification. Same as find, but limited to one result
  
  @method findOne
  @public
  @param {Object} filter
  @return {Object}
   */

  SyncResourceClientInterface.prototype.findOne = function(filter) {
    return this.memory.findOne(filter);
  };


  /**
  Destroy model instance
  
  @method destroyById
  @public
  @param {Object} data
   */

  SyncResourceClientInterface.prototype.destroy = function(data) {
    return this.memory.destroy(data);
  };


  /**
  Destroy model instance with the specified ID.
  
  @method destroyById
  @public
  @param {String} id
   */

  SyncResourceClientInterface.prototype.destroyById = function(id) {
    return this.memory.destroyById(id);
  };


  /**
  Update set of attributes.
  
  @method updateAttributes
  @public
  @param {Object} data
  @return {Object}
   */

  SyncResourceClientInterface.prototype.updateAttributes = function(id, data) {
    return this.memory.updateAttributes(id, data);
  };

  return SyncResourceClientInterface;

})();

module.exports = SyncResourceClientInterface;
