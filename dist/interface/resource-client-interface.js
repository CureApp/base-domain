'use strict';

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

  /**
  Create new instance of Model class, saved in database
  
  @method create
  @public
  @param {Object} data
  @return {Object|Promise(Object)}
   */

  /**
  Update or insert a model instance
  The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.
  
  @method upsert
  @public
  @param {Object} data
  @return {Object|Promise(Object)}
   */

  /**
  Find object by ID.
  
  @method findById
  @public
  @param {String|Number} id
  @return {Object|Promise(Object)}
   */

  /**
  Find all model instances that match filter specification.
  
  @method find
  @public
  @param {Object} filter
  @return {Array(Object)|Promise(Array(Object))}
   */

  /**
  Find one model instance that matches filter specification. Same as find, but limited to one result
  
  @method findOne
  @public
  @param {Object} filter
  @return {Object|Promise(Object)}
   */

  /**
  Destroy model instance
  
  @method destroyById
  @public
  @param {Object} data
   */

  /**
  Destroy model instance with the specified ID.
  
  @method destroyById
  @public
  @param {String|Number} id
   */

  /**
  Update set of attributes.
  
  @method updateAttributes
  @public
  @param {Object} data
  @return {Object|Promise(Object)}
   */
  function ResourceClientInterface() {}

  return ResourceClientInterface;

})();

module.exports = ResourceClientInterface;
