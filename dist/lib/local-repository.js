var AggregateRoot, BaseSyncRepository, LocalRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

AggregateRoot = require('./aggregate-root');

BaseSyncRepository = require('./base-sync-repository');


/**
repository of local memory, saved in AggregateRoot

@class LocalRepository
@extends BaseSyncRepository
@module base-domain
 */

LocalRepository = (function(superClass) {
  extend(LocalRepository, superClass);


  /**
  root name
   */

  LocalRepository.aggregateRoot = null;

  function LocalRepository() {
    var Root;
    LocalRepository.__super__.constructor.apply(this, arguments);
    if (this.constructor.aggregateRoot == null) {
      throw this.error('aggregateRootIsRequired', (this.constructor.getName()) + " must define its static property '@aggregateRoot'.");
    }
    Root = this.getFacade().getModel(this.constructor.aggregateRoot);
    if (!(Root.prototype instanceof AggregateRoot)) {
      throw this.error('invalidAggregateRoot', (this.constructor.getName()) + " has invalid aggregateRoot property.\n'" + this.constructor.aggregateRoot + "' is not instance of AggregateRoot.");
    }
    if (!(this.root instanceof Root)) {
      throw this.error('invalidRoot', "'" + (this.constructor.getName()) + "' wasn't created by AggregateRoot '" + this.constructor.aggregateRoot + "'.\n\nTry\n\naggregateRoot.createRepository('" + this.constructor.modelName + "')\n\nwhere aggregateRoot is an instance of '" + this.constructor.aggregateRoot + "'.");
    }
    this.client = this.root.useMemoryResource(this.constructor.modelName);
  }

  return LocalRepository;

})(BaseSyncRepository);

module.exports = LocalRepository;
