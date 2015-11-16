
/**
interface of factory

@class FactoryInterface
@module base-domain
 */
var FactoryInterface;

FactoryInterface = (function() {

  /**
  model name to handle
  
  @property modelName
  @static
  @protected
  @type String
   */

  /**
  create empty model instance
  
  @method createEmpty
  @return {BaseModel}
   */

  /**
  create instance of model class by plain object
  
  for each prop, values are set by Model#set(prop, value)
  
  @method createFromObject
  @public
  @param {Object} obj
  @param {Object} [options={}]
  @param {Object} [options.include] options to pass to Includer
  @param {Object} [options.include.async=false] include submodels asynchronously
  @param {Boolean} [options.include.recursive=false] recursively include or not
  @param {Array(String)} [options.include.props] include submodels of given props
  @return {BaseModel} model
   */

  /**
  create model list
  
  @method createList
  @public
  @param {String} listModelName model name of list
  @param {any} obj
  @param {Object} [options={}]
  @param {Object} [options.include] options to pass to Includer
  @param {Object} [options.include.async=false] include submodels asynchronously
  @param {Boolean} [options.include.recursive=false] recursively include or not
  @param {Array(String)} [options.include.props] include submodels of given props
  @return {BaseList} list
   */

  /**
  create model dict
  
  @method createDict
  @public
  @param {String} dictModelName model name of dict
  @param {any} obj
  @param {Object} [options={}]
  @param {Object} [options.include] options to pass to Includer
  @param {Object} [options.include.async=false] include submodels asynchronously
  @param {Boolean} [options.include.recursive=false] recursively include or not
  @param {Array(String)} [options.include.props] include submodels of given props
  @return {BaseDict} dict
   */
  function FactoryInterface() {}

  return FactoryInterface;

})();

module.exports = FactoryInterface;
