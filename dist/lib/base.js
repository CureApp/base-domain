var Base, DomainError, EventEmitter, hyphenize,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

DomainError = require('./domain-error');

hyphenize = require('../util').hyphenize;

EventEmitter = require('events').EventEmitter;


/**
parent class of model, factory and repository.

gives them @getFacade() method.

@class Base
@module base-domain
 */

Base = (function(superClass) {
  extend(Base, superClass);


  /**
  @property {RootInterface} root
   */

  function Base(root) {
    if (root && !root.constructor.isRoot) {
      console.error("base-domain: [warning] constructor of '" + this.constructor.name + "' is given non-root object.\n    Use Facade instead.");
      root = null;
    }
    Object.defineProperty(this, 'root', {
      value: root != null ? root : this.getFacade(),
      writable: true
    });
  }


  /**
  get facade
  
  the implementation is in Facade#requre()
  
  
  @method getFacade
  @return {Facade}
   */

  Base.prototype.getFacade = function() {
    throw new DomainError('base-domain:facadeNotRegistered', "Facade is not created yet, or you required domain classes not from Facade.\nRequire domain classes, instances by\n\n    facade.getModel()\n    facade.createModel()\n    facade.createFactory()\n    facade.createRepository()\n\nto attach getFacade() method to them.");
  };


  /**
  emit event at next tick
  @method emitNext
   */

  Base.prototype.emitNext = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return process.nextTick((function(_this) {
      return function() {
        return _this.emit.apply(_this, args);
      };
    })(this));
  };


  /**
  get parent class if it is not BaseClass
  @method getCustomParent
  @return {Function}
   */

  Base.getCustomParent = function() {
    var Facade, ParentClass;
    Facade = require('./facade');
    ParentClass = this.__super__;
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

})(EventEmitter);

module.exports = Base;
