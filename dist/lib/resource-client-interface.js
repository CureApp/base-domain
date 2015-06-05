
/**
interface of client accessing to resource.
Used in BaseRepository

LoopBackClient in loopback-promised package implements this interface.

see https://github.com/CureApp/loopback-promised

@class ResourceClientInterface
@module base-domain
 */
var ResourceClientInterface;

ResourceClientInterface = (function() {
  function ResourceClientInterface() {}


  /**
  Create new instance of Model class, saved in database
  
  @method create
  @public
  @param {Object} data
  @return {Promise(Object)}
   */

  ResourceClientInterface.prototype.create = function(data) {
    if (data == null) {
      data = {};
    }
    return this.mock(data);
  };


  /**
  Update or insert a model instance
  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
  
  @method upsert
  @public
  @param {Object} data
  @return {Promise(Object)}
   */

  ResourceClientInterface.prototype.upsert = function(data) {
    if (data == null) {
      data = {};
    }
    return this.mock(data);
  };


  /**
  Find object by ID.
  
  @method findById
  @public
  @param {String} id
  @return {Promise(Object)}
   */

  ResourceClientInterface.prototype.findById = function(id) {
    return this.mock(id);
  };


  /**
  Find all model instances that match filter specification.
  
  @method find
  @public
  @param {Object} filter
  @return {Promise(Array(Object))}
   */

  ResourceClientInterface.prototype.find = function(filter) {
    return Promise.resolve([
      {
        id: 'dummy',
        mock: true
      }
    ]);
  };


  /**
  Find one model instance that matches filter specification. Same as find, but limited to one result
  
  @method findOne
  @public
  @param {Object} filter
  @return {Promise(Object)}
   */

  ResourceClientInterface.prototype.findOne = function(filter) {
    return this.mock(filter);
  };


  /**
  Destroy model instance
  
  @method destroyById
  @public
  @param {Object} data
  @return {Promise}
   */

  ResourceClientInterface.prototype.destroy = function(data) {
    return Promise.resolve({});
  };


  /**
  Destroy model instance with the specified ID.
  
  @method destroyById
  @public
  @param {String} id
  @return {Promise}
   */

  ResourceClientInterface.prototype.destroyById = function(id) {
    return Promise.resolve({});
  };


  /**
  Update set of attributes.
  
  @method updateAttributes
  @public
  @param {Object} data
  @return {Promise(Object)}
   */

  ResourceClientInterface.prototype.updateAttributes = function(id, data) {
    return this.mock(id, data);
  };


  /**
  return Promise object as mock
  
  @method mock
  @private
   */

  ResourceClientInterface.prototype.mock = function(arg1, arg2) {
    return Promise.resolve({
      id: 'dummy',
      mock: true,
      arg1: arg1,
      arg2: arg2
    });
  };

  return ResourceClientInterface;

})();

module.exports = ResourceClientInterface;
