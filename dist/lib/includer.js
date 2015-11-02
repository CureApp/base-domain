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
  @param {Boolean} [options.recursive=false] recursively include or not
  @param {Boolean} [options.entityPool] entityPool, to detect circular references
  @param {Array(String)} [options.props] include only given props
   */
  function Includer(model, options) {
    var base;
    this.model = model;
    this.options = options != null ? options : {};
    if (this.options.entityPool == null) {
      this.entityPoolCreated = true;
      this.options.entityPool = new EntityPool;
    }
    this.entityPool = this.options.entityPool;
    if ((base = this.options).async == null) {
      base.async = true;
    }
    this.facade = this.model.getFacade();
    this.ModelClass = this.model.constructor;
    this.modelProps = this.facade.getModelProps(this.ModelClass.getName());
    this.root = this.model.root;
    if (this.ModelClass.isEntity) {
      this.entityPool.set(this.model);
    }
  }


  /**
  include sub entities
  
  @method include
  @public
  @return {Promise}
   */

  Includer.prototype.include = function() {
    var entityProp, entityProps, i, len, p, promises, subModelPromise;
    entityProps = this.modelProps.entities;
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
    promises = [];
    for (i = 0, len = entityProps.length; i < len; i++) {
      entityProp = entityProps[i];
      if (!(this.model[entityProp] == null)) {
        continue;
      }
      subModelPromise = this.setSubEntity(entityProp);
      if (subModelPromise) {
        promises.push(subModelPromise);
      }
    }
    return Promise.all(promises).then((function(_this) {
      return function() {
        if (_this.options.recursive) {
          return _this.doRecursively();
        }
        if (_this.entityPoolCreated) {
          _this.entityPool.clear();
        }
        return _this.model;
      };
    })(this));
  };


  /**
  run include for each submodel
  
  @method doRecursively
  @private
  @return {Promise}
   */

  Includer.prototype.doRecursively = function() {
    var i, len, modelProp, promises, ref, subModel;
    promises = [];
    ref = this.modelProps.models;
    for (i = 0, len = ref.length; i < len; i++) {
      modelProp = ref[i];
      subModel = this.model[modelProp];
      if (!(subModel instanceof BaseModel)) {
        continue;
      }
      if (subModel.included()) {
        continue;
      }
      promises.push(subModel.include(this.options));
    }
    return Promise.all(promises).then((function(_this) {
      return function() {
        if (_this.entityPoolCreated) {
          _this.entityPool.clear();
        }
        return _this.model;
      };
    })(this));
  };


  /**
  load entity by entityProp and set it to @model
  
  @method setSubEntity
  @private
  @param {String} entityProp
  @return {Promise}
   */

  Includer.prototype.setSubEntity = function(entityProp) {
    var repo, subId, subModel, typeInfo;
    typeInfo = this.modelProps.getTypeInfo(entityProp);
    subId = this.model[typeInfo.idPropName];
    if (subId == null) {
      return;
    }
    if (subModel = this.entityPool.get(typeInfo.model, subId)) {
      this.model.set(entityProp, subModel);
      return;
    }
    repo = this.createRepository(typeInfo.model);
    if (repo == null) {
      return;
    }
    if (repo.constructor.isSync) {
      subModel = repo.get(subId, {
        include: this.options
      });
      if (subModel != null) {
        this.model.set(entityProp, subModel);
      }
      return Promise.resolve(subModel);
    } else {
      if (!this.options.async) {
        return;
      }
      return repo.get(subId, {
        include: this.options
      }).then((function(_this) {
        return function(subModel) {
          return _this.model.set(entityProp, subModel);
        };
      })(this))["catch"](function(e) {});
    }
  };


  /**
  Get instance of repository.
  If not found, checks parent class's repository
  
  @method createRepository
  @return {BaseRepository}
   */

  Includer.prototype.createRepository = function(modelName) {
    var ParentClass, e;
    while (true) {
      try {
        return this.root.createRepository(modelName);
      } catch (_error) {
        e = _error;
        ParentClass = this.facade.getModel(modelName).getParent();
        if (!ParentClass.className) {
          return null;
        }
        modelName = ParentClass.getName();
      }
    }
  };

  return Includer;

})();

module.exports = Includer;
