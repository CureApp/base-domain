var Base, BaseService,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Base = require('./base');


/**
Base service class of DDD pattern.

the parent "Base" class just simply gives a @getFacade() method.

@class BaseService
@extends Base
@module base-domain
 */

BaseService = (function(superClass) {
  extend(BaseService, superClass);

  function BaseService() {
    return BaseService.__super__.constructor.apply(this, arguments);
  }

  return BaseService;

})(Base);

module.exports = BaseService;
