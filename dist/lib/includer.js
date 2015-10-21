var BaseModel, Includer,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseModel = require('./base-model');


/**
include submodels

@class Includer
@module base-domain
 */

Includer = (function() {

  /**
  @constructor
   */
  function Includer(model1, modelPool) {
    this.model = model1;
    this.modelPool = modelPool != null ? modelPool : {};
    this.ModelClass = this.model.constructor;
    this.modelProps = this.ModelClass.getModelProps();
    this.root = this.model.root;
    if (this.ModelClass.isEntity) {
      this.cache(this.ModelClass.getName(), this.model);
    }
  }


  /**
  include sub entities
  
  @method include
  @public
  @param {Object} options
  @param {Boolean} [async=true] get async values
  @param {Boolean} [recursive=false] recursively include or not
  @param {Array(String)} [props] include only given props
  @return {Promise}
   */

  Includer.prototype.include = function(options) {
    var base, entityProp, entityProps, i, len, p, promises, subModelPromise;
    this.options = options != null ? options : {};
    if ((base = this.options).async == null) {
      base.async = true;
    }
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
    var i, includer, len, modelProp, promises, ref, subModel;
    promises = [];
    ref = this.modelProps.models;
    for (i = 0, len = ref.length; i < len; i++) {
      modelProp = ref[i];
      subModel = this.model[modelProp];
      if (!(subModel instanceof BaseModel)) {
        continue;
      }
      includer = new Includer(subModel, this.modelPool);
      promises.push(includer.include(this.options));
    }
    return Promise.all(promises).then((function(_this) {
      return function() {
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
    if (subModel = this.cached(typeInfo.model, subId)) {
      this.model.set(entityProp, subModel);
      return;
    }
    repo = this.createRepository(typeInfo.model);
    if (repo == null) {
      return;
    }
    if (repo.constructor.isSync) {
      subModel = repo.get(subId);
      this.model.set(entityProp, subModel);
      return Promise.resolve(subModel);
    } else {
      if (!this.options.async) {
        return;
      }
      return repo.get(subId).then((function(_this) {
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
        ParentClass = this.root.getModel(modelName).getCustomParent();
        if (ParentClass == null) {
          return null;
        }
        modelName = ParentClass.getName();
      }
    }
  };


  /**
  cache model
  
  @method cache
  @private
  @param {String} modelName
  @param {Entity} model
   */

  Includer.prototype.cache = function(modelName, model) {
    var base;
    if ((base = this.modelPool)[modelName] == null) {
      base[modelName] = {};
    }
    this.modelPool[modelName][model.id] = model;
  };


  /**
  get cached model
  
  @method cached
  @private
  @param {String} modelName
  @param {String|Number} id
  @return {Entity} model
   */

  Includer.prototype.cached = function(modelName, id) {
    var ref;
    return (ref = this.modelPool[modelName]) != null ? ref[id] : void 0;
  };

  return Includer;

})();

module.exports = Includer;
