
/**
parses model properties and classifies them

@class ModelProps
@module base-domain
 */
var ModelProps;

ModelProps = (function() {
  function ModelProps(properties, facade) {

    /**
    property whose type is CREATED_AT
    @property {String} createdAt
     */
    this.createdAt = null;

    /**
    property whose type is UPDATED_AT
    @property {String} updatedAt
     */
    this.updatedAt = null;

    /**
    properties whose type is MODEL, MODEL_LIST, MODEL_DICT
    @property {Array(String)} models
     */
    this.models = [];

    /**
    properties whose type is MODEL and the model extends Entity
    @property {Array(String)} entities
     */
    this.entities = [];

    /**
    properties whose type is DATE, CREATED_AT and UPDATED_AT
    @property {Array(String)} dates
     */
    this.dates = [];

    /**
    properties whose type is MODEL and the model does not extend Entity
    @property {Array(String)} nonEntities
     */
    this.nonEntities = [];

    /**
    key value pairs of (property => TypeInfo)
    @property {Object(TypeInfo)} dic
     */
    this.dic = {};
    this.entityDic = {};
    this.modelDic = {};
    this.tmpDic = {};
    this.idDic = {};
    this.build(properties, facade);
  }


  /**
  classify each prop by type
  
  @method build
  @private
   */

  ModelProps.prototype.build = function(properties, facade) {
    var prop, typeInfo;
    for (prop in properties) {
      typeInfo = properties[prop];
      this.dic[prop] = typeInfo;
      if (typeInfo.tmp) {
        this.tmpDic[prop] = true;
      }
      switch (typeInfo.name) {
        case 'DATE':
          this.dates.push(prop);
          break;
        case 'CREATED_AT':
          this.createdAt = prop;
          this.dates.push(prop);
          break;
        case 'UPDATED_AT':
          this.updatedAt = prop;
          this.dates.push(prop);
          break;
        case 'MODEL':
        case 'MODEL_LIST':
        case 'MODEL_DICT':
          this.models.push(prop);
          this.modelDic[prop] = true;
          if (facade.getModel(typeInfo.model).isEntity) {
            this.entities.push(prop);
            this.entityDic[prop] = true;
            this.idDic[typeInfo.idPropName] = prop;
          } else {
            this.nonEntities.push(prop);
          }
      }
    }
  };

  ModelProps.prototype.names = function() {
    return Object.keys(this.dic);
  };

  ModelProps.prototype.types = function() {
    var prop, ref, results, typeInfo;
    ref = this.dic;
    results = [];
    for (prop in ref) {
      typeInfo = ref[prop];
      results.push(typeInfo);
    }
    return results;
  };


  /**
  check if the given prop is entity prop
  
  @method isEntity
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isEntity = function(prop) {
    return this.entityDic[prop] != null;
  };


  /**
  check if the given prop is submodel's id
  
  @method isId
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isId = function(prop) {
    return this.idDic[prop] != null;
  };


  /**
  get submodel prop of the given idPropName
  
  @method submodelOf
  @param {String} idPropName
  @return {String} submodelProp
   */

  ModelProps.prototype.submodelOf = function(idPropName) {
    return this.idDic[idPropName];
  };


  /**
  get typeInfo by prop
  
  @method getTypeInfo
  @param {String} prop
  @return {TypeInfo}
   */

  ModelProps.prototype.getTypeInfo = function(prop) {
    return this.dic[prop];
  };


  /**
  check if the given prop is model prop
  
  @method isModel
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isModel = function(prop) {
    return this.modelDic[prop] != null;
  };


  /**
  check if the given prop is tmp prop
  
  @method isTmp
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isTmp = function(prop) {
    return this.tmpDic[prop] != null;
  };

  return ModelProps;

})();

module.exports = ModelProps;
