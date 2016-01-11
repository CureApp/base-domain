'use strict';
var AggregateRoot, Entity, MemoryResource,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

Entity = require('./entity');

MemoryResource = require('../memory-resource');


/**

@class AggregateRoot
@implements RootInterface
@extends Entity
@module base-domain
 */

AggregateRoot = (function(superClass) {
  extend(AggregateRoot, superClass);


  /**
  is root (to identify RootInterface)
  @property {Boolean} isRoot
  @static
   */

  AggregateRoot.isRoot = true;


  /**
  key: modelName, value: MemoryResource
  
  @property {Object(MemoryResource)} memories
   */

  function AggregateRoot() {
    Object.defineProperty(this, 'memories', {
      value: {}
    });
    AggregateRoot.__super__.constructor.apply(this, arguments);
  }


  /**
  create a factory instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createFactory
  @param {String} name
  @return {BaseFactory}
   */

  AggregateRoot.prototype.createFactory = function() {
    var name, params;
    name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.getFacade().__create(name, 'factory', params, this);
  };


  /**
  create a repository instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createRepository
  @param {String} name
  @return {BaseRepository}
   */

  AggregateRoot.prototype.createRepository = function() {
    var name, params;
    name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.getFacade().__create(name, 'repository', params, this);
  };


  /**
  create an instance of the given modelName using obj
  if obj is null or undefined, empty object will be created.
  
  @method createModel
  @param {String} modelName
  @param {Object} obj
  @param {Object} [options]
  @return {BaseModel}
   */

  AggregateRoot.prototype.createModel = function(modelName, obj, options) {
    return this.getFacade().createModel(modelName, obj, options, this);
  };


  /**
  create a service instance
  2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service
  
  @method createService
  @param {String} name
  @return {BaseRepository}
   */

  AggregateRoot.prototype.createService = function() {
    var name, params;
    name = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return this.getFacade().__create(name, 'service', params, this);
  };


  /**
  create a preferred repository instance
  3rd, 4th ... arguments are the params to pass to the constructor of the repository
  
  @method createPreferredRepository
  @param {String} modelName
  @param {Object} [options]
  @param {Object} [options.noParent] if true, stop requiring parent class
  @return {BaseRepository}
   */

  AggregateRoot.prototype.createPreferredRepository = function() {
    var modelName, options, params;
    modelName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    return this.getFacade().createPreferred(modelName, 'repository', options, params, this);
  };


  /**
  create a preferred factory instance
  3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredFactory
  @param {String} modelName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseFactory}
   */

  AggregateRoot.prototype.createPreferredFactory = function() {
    var modelName, options, params;
    modelName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    if (options.noParent == null) {
      options.noParent = true;
    }
    return this.getFacade().createPreferred(modelName, 'factory', options, params, this);
  };


  /**
  create a preferred service instance
  3rd, 4th ... arguments are the params to pass to the constructor of the factory
  
  @method createPreferredService
  @param {String} modelName
  @param {Object} [options]
  @param {Object} [options.noParent=true] if true, stop requiring parent class
  @return {BaseService}
   */

  AggregateRoot.prototype.createPreferredService = function() {
    var modelName, options, params;
    modelName = arguments[0], options = arguments[1], params = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    if (options == null) {
      options = {};
    }
    if (options.noParent == null) {
      options.noParent = true;
    }
    return this.getFacade().createPreferred(modelName, 'service', options, params, this);
  };


  /**
  get or create a memory resource to save to @memories
  Only called from LocalRepository
  
  @method useMemoryResource
  @param {String} modelName
  @return {MemoryResource}
   */

  AggregateRoot.prototype.useMemoryResource = function(modelName) {
    var base;
    return (base = this.memories)[modelName] != null ? base[modelName] : base[modelName] = new MemoryResource();
  };


  /**
  create plain object without relational entities
  plainize memoryResources
  
  @method toPlainObject
  @return {Object} plainObject
   */

  AggregateRoot.prototype.toPlainObject = function() {
    var memoryResource, modelName, plain, ref;
    plain = AggregateRoot.__super__.toPlainObject.apply(this, arguments);
    plain.memories = {};
    ref = this.memories;
    for (modelName in ref) {
      memoryResource = ref[modelName];
      plain.memories[modelName] = memoryResource.toPlainObject();
    }
    return plain;
  };


  /**
  set value to prop
  set memories
  
  @method set
   */

  AggregateRoot.prototype.set = function(k, memories) {
    var modelName, plainMemory;
    if (k !== 'memories') {
      return AggregateRoot.__super__.set.apply(this, arguments);
    }
    for (modelName in memories) {
      plainMemory = memories[modelName];
      this.memories[modelName] = MemoryResource.restore(plainMemory);
    }
    return this;
  };

  return AggregateRoot;

})(Entity);

module.exports = AggregateRoot;
