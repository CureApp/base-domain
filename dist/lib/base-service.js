'use strict';
var Base, BaseService,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

Base = require('./base');


/**
Base service class of DDD pattern.

the parent "Base" class just simply gives `this.facade` property

@class BaseService
@extends Base
@module base-domain
 */

BaseService = (function(superClass) {
  extend(BaseService, superClass);

  function BaseService() {
    var i, params, root;
    params = 2 <= arguments.length ? slice.call(arguments, 0, i = arguments.length - 1) : (i = 0, []), root = arguments[i++];
    BaseService.__super__.constructor.call(this, root);
  }

  return BaseService;

})(Base);

module.exports = BaseService;
