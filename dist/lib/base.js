
/**
parent class of model, factory and repository.

gives them @getFacade() method.

@class Base
@module base-domain
 */
var Base;

Base = (function() {
  function Base() {}


  /**
  get facade
  
  the implementation is in Facade#requre()
  
  
  @method getFacade
  @return {Facade}
   */

  Base.prototype.getFacade = function() {
    throw new Error("Facade is not created yet, or you required domain classes not from Facade.\nRequire domain classes by facade.getModel(), facade.getFactory(), facade.getRepository()\nto attach them getFacade() method.");
  };

  return Base;

})();

module.exports = Base;
