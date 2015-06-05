
/**
include submodels
 */
var Includer;

Includer = (function() {

  /**
  @constructor
   */
  function Includer(model1, modelPool) {
    this.model = model1;
    this.modelPool = modelPool != null ? modelPool : {};
    this.ModelClass = this.model.constructor;
    if (this.ModelClass.isEntity) {
      this.cache(this.ModelClass.getModelName(), this.model);
    }
  }


  /**
  include sub entities
  
  @method include
  @public
  @param {Object} options
  @param {Boolean} [recursive=false] recursively include or not
  @return {Promise}
   */

  Includer.prototype.include = function(options) {
    var entityProp, entityProps, i, len, promises, subModelPromise;
    if (options == null) {
      options = {};
    }
    entityProps = this.ModelClass.getEntityProps();
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
        if (options.recursive) {
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
    var BaseModel, i, includer, len, modelProp, promises, subModel, subModelProps;
    promises = [];
    subModelProps = this.ModelClass.getModelProps({
      includeList: true
    });
    BaseModel = this.model.getFacade().constructor.BaseModel;
    for (i = 0, len = subModelProps.length; i < len; i++) {
      modelProp = subModelProps[i];
      subModel = this.model[modelProp];
      if (!(subModel instanceof BaseModel)) {
        continue;
      }
      includer = new Includer(subModel, this.modelPool);
      promises.push(includer.include({
        recursive: true
      }));
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
    var propInfo, repo, sub, subId;
    propInfo = model.getTypeInfo(entityProp);
    subId = this.model[propInfo.idPropName];
    if (subId == null) {
      return;
    }
    if (sub = this.cached(propInfo.model, subId)) {
      this.model.set(entityProp, sub);
      return;
    }
    repo = this.model.getFacade().createRepository(propInfo.model);
    return repo.get(subId).then((function(_this) {
      return function(subModel) {
        return _this.model.set(entityProp, subModel);
      };
    })(this))["catch"](function(e) {});
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
