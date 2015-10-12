var Id, Ids,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Id = require('./id');


/**
ids

@class Ids
@extends Array
@implements Id
@module base-domain
 */

Ids = (function(superClass) {
  extend(Ids, superClass);

  function Ids(ids) {
    var i, id, len;
    for (i = 0, len = ids.length; i < len; i++) {
      id = ids[i];
      if (!(id instanceof Id)) {
        id = new Id(id);
      }
      this.push(id);
    }
  }

  Ids.prototype.toPlainObject = function() {
    var i, item, len, results;
    results = [];
    for (i = 0, len = this.length; i < len; i++) {
      item = this[i];
      results.push(item.toString());
    }
    return results;
  };

  Ids.prototype.equals = function(ids) {
    return this.toString() === this.ids.toString();
  };

  return Ids;

})(Array);

module.exports = Ids;
