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
      if (!facade.hasClass(this.constructor.getName())) {
        facade.addClass(this.constructor);
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
  get parent class if it is not BaseClass
  @method getCustomParent
  @return {Function}
   */

  Base.getCustomParent = function() {
    var Facade, ParentClass;
    Facade = require('./facade');
    ParentClass = getProto(this.prototype).constructor;
    if (Facade.isBaseClass(ParentClass)) {
      return null;
    }
    return ParentClass;
  };


  /**
  ClassName -> class-name
  the name must compatible with file name
  
  @method getName
  @public
  @static
  @return {String}
   */

  Base.getName = function() {
    return hyphenize(this.name);
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
