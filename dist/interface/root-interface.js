
/**
interface of Aggregate Root

@class RootInterface
@module base-domain
 */
var RootInterface;

RootInterface = (function() {

  /**
  is root (to identify RootInterface)
  @property {Boolean} isRoot
  @static
   */

  /**
  create a factory instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createFactory
  @param {String} modelName
  @return {BaseFactory}
   */

  /**
  create a repository instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createRepository
  @param {String} modelName
  @return {BaseRepository}
   */

  /**
  create a service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service
  
  @method createService
  @param {String} name
  @return {BaseRepository}
   */

  /**
  get a model class
  
  @method getModel
  @param {String} modelName
  @return {Function}
   */

  /**
  create an instance of the given modelName using obj
  if obj is null or undefined, empty object will be created.
  
  @method createModel
  @param {String} modelName
  @param {Object} obj
  @param {Object} [options]
  @return {BaseModel}
   */
  function RootInterface() {}

  return RootInterface;

})();

module.exports = RootInterface;
