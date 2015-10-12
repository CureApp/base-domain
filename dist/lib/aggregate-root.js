var AggregateRoot, Entity, MemoryResource,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Entity = require('./entity');

MemoryResource = require('./memory-resource');


/**

@class AggregateRoot
@implements RootInterface
@extends Entity
 */

AggregateRoot = (function(superClass) {
  extend(AggregateRoot, superClass);


  /**
  key: modelName, value: MemoryResource
  
  @property {Object(MemoryResource)} memories
   */

  function AggregateRoot() {
    Object.defineProperty(this, 'memories', {
      value: {}
    });
    AggregateRoot.__super__.constructor.apply(this, arguments);
    this.root = this;
  }


  /**
  create a factory instance
  
  @method createFactory
  @param {String} modelName
  @return {BaseFactory}
   */

  AggregateRoot.prototype.createFactory = function(modelName) {
    return this.getFacade().createFactory(modelName, this);
  };


  /**
  create a repository instance
  
  @method createRepository
  @param {String} modelName
  @return {BaseRepository}
   */

  AggregateRoot.prototype.createRepository = function(modelName) {
    return this.getFacade().createRepository(modelName, this);
  };


  /**
  get a model class
  
  @method getModel
  @param {String} modelName
  @return {Function}
   */

  AggregateRoot.prototype.getModel = function(modelName) {
    return this.getFacade().getModel(modelName);
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
    return this.createFactory(modelName).createFromObject(obj != null ? obj : {}, options);
  };


  /**
  get or create a memory resource to save to @memories
  
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
