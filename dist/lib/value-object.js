var BaseModel, Util, ValueObject,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Util = require('../util');

BaseModel = require('./base-model');


/**
Base model class without "id" column, rather than a set of values

@class ValueObject
@extends BaseModel
@module base-domain
 */

ValueObject = (function(superClass) {
  extend(ValueObject, superClass);

  function ValueObject() {
    return ValueObject.__super__.constructor.apply(this, arguments);
  }

  ValueObject.isEntity = false;


  /**
  check equality
  
  @method equals
  @param {ValueObject} vo
  @return {Boolean}
   */

  ValueObject.prototype.equals = function(vo) {
    return ValueObject.__super__.equals.call(this, vo) && Util.deepEqual(this, vo);
  };

  return ValueObject;

})(BaseModel);

module.exports = ValueObject;
