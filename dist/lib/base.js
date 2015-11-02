var Base, DomainError, getProto, hyphenize, ref;

DomainError = require('./domain-error');

hyphenize = require('../util').hyphenize;

getProto = (ref = Object.getPrototypeOf) != null ? ref : function(obj) {
  return obj.__proto__;
};


/**
parent class of model, factory and repository.

gives them @getFacade() method.

@class Base
@module base-domain
 */

Base = (function() {

  /**
  Hyphenized name.
  The name should equal to the file name (without path and extension).
  If not set, facade will set the file name automatically.
  This property were not necessary if uglify-js would not mangle class name...
  
  @property {String} className
  @static
  @private
   */
  Base.className = null;

  function Base(root) {
    var facade;
    if (!(root != null ? root.constructor.isRoot : void 0)) {
      console.error("base-domain: [warning] constructor of '" + this.constructor.name + "' was not given RootInterface (e.g. facade).\n    @root, @getFacade() is unavailable.");
      root = null;
    }

    /**
    @property {RootInterface} root
     */
    Object.defineProperty(this, 'root', {
      value: root,
      writable: true
    });
    if (root) {
      facade = this.getFacade();
      if (this.constructor.className && !facade.hasClass(this.constructor.className)) {
        facade.addClass(this.constructor.className, this.constructor);
      }
    }
  }


  /**
  Get facade
  
  @method getFacade
  @return {Facade}
   */

  Base.prototype.getFacade = function() {
    if (this.root == null) {
      throw this.error('base-domain:noFacadeAssigned', "'" + this.constructor.name + "' does not have @root.\nGive it via constructor or create instance via Facade.");
    }
    return this.root.getFacade();
  };


  /**
  get parent class
  @method getParent
  @return {Function}
   */

  Base.getParent = function() {
    return getProto(this.prototype).constructor;
  };


  /**
  get className
  
  @method getName
  @public
  @static
  @return {String}
   */

  Base.getName = function() {
    if (!this.className || this.getParent().className === this.className) {
      throw new DomainError('classNameNotDefined', "@className property is not defined at class " + this.name + ".\nIt will automatically be set when required through Facade.\nYou might have loaded this class not via Facade.");
    }
    return this.className;
  };


  /**
  create instance of DomainError
  
  @method error
  @param {String} reason reason of the error
  @param {String} [message]
  @return {Error}
   */

  Base.prototype.error = function(reason, message) {
    return new DomainError(reason, message);
  };

  return Base;

})();

module.exports = Base;
