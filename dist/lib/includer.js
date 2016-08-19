'use strict';
var BaseModel, EntityPool, Includer,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseModel = require('./base-model');

EntityPool = require('../entity-pool');


/**
include submodels

@class Includer
@module base-domain
 */

Includer = (function() {

  /**
  @constructor
  @param {Object} options
  @param {Boolean} [options.async=true] get async values
  @param {Boolean} [options.entityPool] entityPool, to detect circular references
  @param {Array(String)} [options.noParentRepos] array of modelNames which needs "noParent" option when calling root.createPreferredRepository()
  @param {Array(String)} [options.props] include only given props
   */
  function Includer(model1, options1) {
    var ModelClass, base, ref;
    this.model = model1;
    this.options = options1 != null ? options1 : {};
    if (this.options.entityPool == null) {
      this.entityPoolCreated = true;
      this.options.entityPool = new EntityPool;
    }
    this.entityPool = this.options.entityPool;
    if ((base = this.options).async == null) {
      base.async = true;
    }
    ModelClass = this.model.constructor;
    this.modelProps = this.model.facade.getModelProps(ModelClass.getName());
    ref = this.splitEntityProps(), this.syncs = ref.syncs, this.asyncs = ref.asyncs, this.repos = ref.repos;
  }

  Includer.prototype.splitEntityProps = function() {
    var asyncs, entityProp, entityProps, i, len, p, repo, repos, subModelName, syncs;
    repos = {};
    syncs = [];
    asyncs = [];
    entityProps = this.modelProps.getEntityProps();
    if (this.options.props) {
      entityProps = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = entityProps.length; i < len; i++) {
          p = entityProps[i];
          if (indexOf.call(this.options.props, p) >= 0) {
            results.push(p);
          }
        }
        return results;
      }).call(this);
    }
    for (i = 0, len = entityProps.length; i < len; i++) {
      entityProp = entityProps[i];
      if (!(this.isNotIncludedProp(entityProp))) {
        continue;
      }
      subModelName = this.modelProps.getSubModelName(entityProp);
      repo = this.createPreferredRepository(subModelName);
      repos[entityProp] = repo;
      if (repo.constructor.isSync) {
        syncs.push(entityProp);
      } else {
        asyncs.push(entityProp);
      }
    }
    return {
      syncs: syncs,
      asyncs: asyncs,
      repos: repos
    };
  };


  /**
  include sub entities
  
  @method include
  @public
  @return {Promise}
   */

  Includer.prototype.include = function(createNew) {
    var model, modelName, newAsyncProps, promises;
    if (createNew == null) {
      createNew = false;
    }
    if (this.model.constructor.isEntity) {
      modelName = this.model.constructor.getName();
      if (this.entityPool.get(modelName, this.model.id)) {
        return Promise.resolve(this.model);
      }
      this.entityPool.set(this.model);
    }
    model = this.includeSync(createNew);
    if (!this.options.async || this.asyncs.length === 0) {
      return Promise.resolve(model);
    }
    if (this.model.constructor.isImmutable && !createNew && Object.isFrozen(this.model)) {
      console.error('frozen model.');
      return Promise.resolve(model);
    }
    newAsyncProps = {};
    promises = this.asyncs.map((function(_this) {
      return function(prop) {
        return _this.getSubModel(prop, true).then(function(subModel) {
          if (subModel == null) {
            return;
          }
          _this.entityPool.set(subModel);
          return newAsyncProps[prop] = subModel;
        });
      };
    })(this));
    return Promise.all(promises).then((function(_this) {
      return function() {
        return _this.applyNewProps(newAsyncProps, createNew);
      };
    })(this));
  };

  Includer.prototype.getSubModel = function(prop, isAsync) {
    var subId, subIdProp, subModel, subModelName;
    subIdProp = this.modelProps.getIdPropByEntityProp(prop);
    subModelName = this.modelProps.getSubModelName(prop);
    subId = this.model[subIdProp];
    if (subModel = this.entityPool.get(subModelName, subId)) {
      if (isAsync) {
        return Promise.resolve(subModel);
      } else {
        return subModel;
      }
    }
    return this.repos[prop].get(this.model[subIdProp], {
      include: this.options
    });
  };

  Includer.prototype.includeSync = function(createNew) {
    var newProps;
    if (createNew == null) {
      createNew = false;
    }
    newProps = {};
    this.syncs.forEach((function(_this) {
      return function(prop) {
        var subModel;
        subModel = _this.getSubModel(prop, false);
        if (subModel == null) {
          return;
        }
        _this.entityPool.set(subModel);
        return newProps[prop] = subModel;
      };
    })(this));
    return this.applyNewProps(newProps, createNew);
  };

  Includer.prototype.isNotIncludedProp = function(entityProp) {
    var subIdProp;
    subIdProp = this.modelProps.getIdPropByEntityProp(entityProp);
    return (this.model[entityProp] == null) && (this.model[subIdProp] != null);
  };

  Includer.prototype.applyNewProps = function(newProps, createNew) {
    if (createNew) {
      return this.model.$set(newProps);
    } else {
      return this.model.set(newProps);
    }
  };

  Includer.prototype.createPreferredRepository = function(modelName) {
    var e, error, options;
    options = {};
    if (Array.isArray(this.options.noParentRepos) && indexOf.call(this.options.noParentRepos, modelName) >= 0) {
      if (options.noParent == null) {
        options.noParent = true;
      }
    }
    try {
      return this.model.root.createPreferredRepository(modelName, options);
    } catch (error) {
      e = error;
      return null;
    }
  };

  return Includer;

})();

module.exports = Includer;
