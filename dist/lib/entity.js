var BaseModel, Entity, Id,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseModel = require('./base-model');

Id = require('./id');


/**
Base model class with "id" column

@class Entity
@extends BaseModel
@module base-domain
 */

Entity = (function(superClass) {
  extend(Entity, superClass);

  function Entity() {
    return Entity.__super__.constructor.apply(this, arguments);
  }

  Entity.isEntity = true;


  /**
  primary key for the model
  
  @property id
  @type {Id}
   */

  Entity.prototype.id = null;


  /**
  check equality
  
  @method equals
  @param {Entity} entity
  @return {Boolean}
   */

  Entity.prototype.equals = function(entity) {
    if (this.id == null) {
      return false;
    }
    return Entity.__super__.equals.call(this, entity) && this.id.equals(entity.id);
  };


  /**
  set value to prop
  @return {Entity} this
   */

  Entity.prototype.set = function(prop, value) {
    if (prop !== 'id') {
      return Entity.__super__.set.apply(this, arguments);
    }
    this[prop] = new Id(value);
    return this;
  };

  return Entity;

})(BaseModel);

module.exports = Entity;
