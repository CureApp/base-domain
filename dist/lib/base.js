var Base, EventEmitter, hyphenize,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

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
    Object.defineProperty(this, 'root', {
      value: root != null ? root : this.getFacade(),
      writable: true
    });
  }


  /**
  get facade
  
  the implementation is in Facade#requre()
  
  
  @method getFacade
  @static
  @return {Facade}
   */

  Base.getFacade = function() {
    throw new Error("Facade is not created yet, or you required domain classes not from Facade.\nRequire domain classes by facade.getModel(), facade.getFactory(), facade.getRepository()\nto attach them getFacade() method.");
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
  get facade
  
  the implementation is in Facade#requre()
  
  
  @method getFacade
  @return {Facade}
   */

  Base.prototype.getFacade = function() {
    throw new Error("Facade is not created yet, or you required domain classes not from Facade.\nRequire domain classes by facade.getModel(), facade.getFactory(), facade.getRepository()\nto attach them getFacade() method.");
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

  return Base;

})(EventEmitter);

module.exports = Base;
