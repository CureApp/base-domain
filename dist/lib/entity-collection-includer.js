'use strict';
var EntityCollectionIncluder, Includer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Includer = require('./includer');


/**
include submodels

@class EntityCollectionIncluder
@extends Includer
@module base-domain
 */

EntityCollectionIncluder = (function(superClass) {
  extend(EntityCollectionIncluder, superClass);

  function EntityCollectionIncluder() {
    EntityCollectionIncluder.__super__.constructor.apply(this, arguments);
    this.itemModelName = this.model.constructor.itemModelName;
  }

  EntityCollectionIncluder.prototype.include = function() {
    return Promise.all([this.includeItems(), EntityCollectionIncluder.__super__.include.apply(this, arguments)]);
  };

  EntityCollectionIncluder.prototype.includeItems = function() {
    var i, id, item, items, len, ref, repo;
    if (this.model.loaded()) {
      return;
    }
    items = [];
    ref = this.model.ids;
    for (i = 0, len = ref.length; i < len; i++) {
      id = ref[i];
      item = this.entityPool.get(this.itemModelName, id);
      if (item != null) {
        items.push(item);
      }
    }
    if (items.length === this.model.length) {
      this.model.setItems(items);
      return;
    }
    repo = this.createPreferredRepository(this.itemModelName);
    if (repo == null) {
      return;
    }
    if (repo.constructor.isSync) {
      items = repo.getByIds(this.model.ids, {
        include: this.options
      });
      if (items.length !== this.model.ids.length) {
        console.warn('EntityCollectionIncluder#include(): some ids were not loaded.');
      }
      return this.model.setItems(items);
    } else {
      if (!this.options.async) {
        return;
      }
      return repo.getByIds(this.model.ids, {
        include: this.options
      }).then((function(_this) {
        return function(items) {
          if (items.length !== _this.model.ids.length) {
            console.warn('EntityCollectionIncluder#include(): some ids were not loaded.');
          }
          return _this.model.setItems(items);
        };
      })(this))["catch"](function(e) {});
    }
  };

  return EntityCollectionIncluder;

})(Includer);

module.exports = EntityCollectionIncluder;
