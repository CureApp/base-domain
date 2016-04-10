'use strict';
var ModelProps, TYPES;

TYPES = require('./type-info').TYPES;


/**
parses model properties and classifies them

@class ModelProps
@module base-domain
 */

ModelProps = (function() {

  /**
  @param {String} modelName
  @param {Object} properties
  @param {BaseModule} modl
   */
  function ModelProps(modelName, properties, modl) {
    this.modelName = modelName;

    /**
    property whose type is CREATED_AT
    @property {String} createdAt
    @public
    @readonly
     */
    this.createdAt = null;

    /**
    property whose type is UPDATED_AT
    @property {String} updatedAt
    @public
    @readonly
     */
    this.updatedAt = null;

    /**
    properties whose type is DATE, CREATED_AT and UPDATED_AT
    @property {Array(String)} dates
    @public
    @readonly
     */
    this.dates = [];
    this.subModelProps = [];
    this.typeInfoDic = {};
    this.entityDic = {};
    this.enumDic = {};
    this.parse(properties, modl);
  }


  /**
  parse props by type
  
  @method parse
  @private
   */

  ModelProps.prototype.parse = function(properties, modl) {
    var prop, typeInfo;
    for (prop in properties) {
      typeInfo = properties[prop];
      this.parseProp(prop, typeInfo, modl);
    }
  };


  /**
  parse one prop by type
  
  @method parseProp
  @private
   */

  ModelProps.prototype.parseProp = function(prop, typeInfo, modl) {
    this.typeInfoDic[prop] = typeInfo;
    switch (typeInfo.typeName) {
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
        this.parseSubModelProp(prop, typeInfo, modl);
        break;
      case 'ENUM':
        this.parseEnumProp(prop, typeInfo, modl);
    }
  };


  /**
  parse submodel prop
  
  @method parseSubModelProp
  @private
   */

  ModelProps.prototype.parseSubModelProp = function(prop, typeInfo, modl) {
    var idTypeInfo;
    this.subModelProps.push(prop);
    if (modl == null) {
      console.error("base-domain:ModelProps could not parse property info of '" + prop + "'.\n(@TYPES." + typeInfo.typeName + ", model=" + typeInfo.model + ".)\nConstruct original model '" + this.modelName + "' with RootInterface.\n\n    new Model(obj, facade)\n    facade.createModel('" + this.modelName + "', obj)\n");
      return;
    }
    if (modl.getModel(typeInfo.model).isEntity) {
      this.entityDic[prop] = true;
      idTypeInfo = TYPES.SUB_ID({
        modelProp: prop,
        entity: typeInfo.model,
        omit: typeInfo.omit
      });
      this.parseProp(typeInfo.idPropName, idTypeInfo, modl);
    }
  };


  /**
  parse enum prop
  
  @method parseEnumProp
  @private
   */

  ModelProps.prototype.parseEnumProp = function(prop, typeInfo, modl) {
    var i, j, len, numsByValue, value, values;
    values = typeInfo.values;
    if (!Array.isArray(values)) {
      throw new Error("Invalid definition of ENUM '" + prop + "' in model '" + this.modelName + "'. Values must be an array.");
    }
    numsByValue = {};
    for (i = j = 0, len = values.length; j < len; i = ++j) {
      value = values[i];
      if (typeof value !== 'string') {
        throw new Error("Invalid definition of ENUM '" + prop + "' in model '" + this.modelName + "'. Values must be an array of string.");
      }
      if (numsByValue[value] != null) {
        throw new Error("Invalid definition of ENUM '" + prop + "' in model '" + this.modelName + "'. Value '" + value + "' is duplicated.");
      }
      numsByValue[value] = i;
    }
    if (typeof typeInfo["default"] === 'string') {
      typeInfo["default"] = numsByValue[typeInfo["default"]];
    }
    if ((typeInfo["default"] == null) || (values[typeInfo["default"]] == null)) {
      throw new Error("Invalid default value '" + typeInfo["default"] + "' of ENUM '" + prop + "' in model '" + this.modelName + "'.");
    }
    typeInfo.numsByValue = numsByValue;
  };


  /**
  get all prop names
  
  @method getAllProps
  @public
  @return {Array(String)}
   */

  ModelProps.prototype.getAllProps = function() {
    return Object.keys(this.typeInfoDic);
  };


  /**
  get all entity prop names
  
  @method getEntityProps
  @public
  @return {Array(String)}
   */

  ModelProps.prototype.getEntityProps = function() {
    return Object.keys(this.entityDic);
  };


  /**
  get all model prop names
  
  @method getSubModelProps
  @public
  @return {Array(String)}
   */

  ModelProps.prototype.getSubModelProps = function() {
    return this.subModelProps.slice();
  };


  /**
  check if the given prop is entity prop
  
  @method isEntity
  @public
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isEntity = function(prop) {
    return this.entityDic[prop] != null;
  };


  /**
  check if the given prop is submodel's id
  
  @method isId
  @public
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isId = function(prop) {
    var ref;
    return ((ref = this.typeInfoDic[prop]) != null ? ref.typeName : void 0) === 'SUB_ID';
  };


  /**
  check if the given prop is enum
  
  @method isEnum
  @public
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isEnum = function(prop) {
    var ref;
    return ((ref = this.typeInfoDic[prop]) != null ? ref.typeName : void 0) === 'ENUM';
  };


  /**
  get value - enum pair
  
  @method isEnumDic
  @public
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.getEnumDic = function(prop) {
    var ref;
    return (ref = this.typeInfoDic[prop]) != null ? ref.numsByValue : void 0;
  };


  /**
  get entity prop of the given idPropName
  
  @method getEntityPropByIdProp
  @public
  @param {String} idPropName
  @return {String} submodelProp
   */

  ModelProps.prototype.getEntityPropByIdProp = function(idProp) {
    var ref;
    return (ref = this.typeInfoDic[idProp]) != null ? ref.modelProp : void 0;
  };


  /**
  check if the given prop is tmp prop
  
  @method isOmitted
  @public
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isOmitted = function(prop) {
    var ref;
    return !!((ref = this.typeInfoDic[prop]) != null ? ref.omit : void 0);
  };


  /**
  get prop name of id of entity prop
  
  @method getIdPropByEntityProp
  @public
  @param {String} prop
  @return {String} idPropName
   */

  ModelProps.prototype.getIdPropByEntityProp = function(entityProp) {
    var ref;
    return (ref = this.typeInfoDic[entityProp]) != null ? ref.idPropName : void 0;
  };


  /**
  get model name of model prop
  
  @method getSubModelProps
  @public
  @param {String} prop
  @return {String} model name
   */

  ModelProps.prototype.getSubModelName = function(prop) {
    var ref;
    return (ref = this.typeInfoDic[prop]) != null ? ref.model : void 0;
  };


  /**
  check if the prop is optional
  
  @method isOptional
  @public
  @param {String} prop
  @return {Boolean}
   */

  ModelProps.prototype.isOptional = function(prop) {
    var ref;
    return !!((ref = this.typeInfoDic[prop]) != null ? ref.optional : void 0);
  };


  /**
  get the default value of the prop
  
  @method getDefaultValue
  @public
  @param {String} prop
  @return {any} defaultValue
   */

  ModelProps.prototype.getDefaultValue = function(prop) {
    var ref;
    return (ref = this.typeInfoDic[prop]) != null ? ref["default"] : void 0;
  };


  /**
  get the valid enum value from input
  
  @method getValidEnum
  @public
  @param {String} prop
  @param {String|Number} value
  @return {Number} value
   */

  ModelProps.prototype.getValidEnum = function(prop, value) {
    var typeInfo;
    typeInfo = this.typeInfoDic[prop];
    if ((typeInfo != null ? typeInfo.values : void 0) == null) {
      return false;
    }
    if (typeof value === 'string' && (typeInfo.numsByValue[value] != null)) {
      return typeInfo.numsByValue[value];
    }
    if (typeof value === 'number' && (typeInfo.values[value] != null)) {
      return value;
    }
    return typeInfo["default"];
  };

  return ModelProps;

})();

module.exports = ModelProps;
