'use strict';
var TypeInfo, camelize;

camelize = require('../util').camelize;


/**
type of model's property

@class TypeInfo
@module base-domain
 */

TypeInfo = (function() {
  function TypeInfo(typeName1, options) {
    var k, v;
    this.typeName = typeName1;
    if (options == null) {
      options = {};
    }
    for (k in options) {
      v = options[k];
      this[k] = v;
    }
  }


  /**
  default value
  @property {any} default
   */


  /**
  flag not to include this prop after 'toPlainObject()'
  @property {Boolean} omit
   */


  /**
  Creates a function which returns TypeInfo
  
  @method createType
  @private
  @static
  @param {String} typeName
  @return {Function(TypeInfo)}
   */

  TypeInfo.createType = function(typeName) {
    var fn;
    fn = function(options) {
      if (!(options != null ? options.hasOwnProperty('default') : void 0) && !(options != null ? options.hasOwnProperty('omit') : void 0)) {
        options = {
          "default": options
        };
      }
      return new TypeInfo(typeName, options);
    };
    fn.typeName = typeName;
    return fn;
  };


  /**
  get TypeInfo as MODEL
  
  @method createModelType
  @private
  @static
  @param {String} modelName
  @param {Options|String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
  @return {TypeInfo} type
   */

  TypeInfo.createModelType = function(modelName, options) {
    if (options == null) {
      options = {};
    }
    if (typeof options === 'string') {
      options = {
        idPropName: options
      };
    }
    options.model = modelName;
    if (options.idPropName == null) {
      options.idPropName = camelize(modelName, true) + 'Id';
    }
    return new TypeInfo('MODEL', options);
  };


  /**
  get TypeInfo as MODEL
  
  @method createEnumType
  @private
  @static
  @param {Array(String)} values
  @param {Object|String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
  @return {TypeInfo} type
   */

  TypeInfo.createEnumType = function(values, options) {
    var i, j, len, numsByValue, typeInfo, value;
    if (options == null) {
      options = {};
    }
    if (typeof options !== 'object') {
      options = {
        "default": options
      };
    }
    options.values = values;
    typeInfo = new TypeInfo('ENUM', options);
    if (!Array.isArray(values)) {
      throw new Error("Invalid definition of ENUM. Values must be an array.");
    }
    numsByValue = {};
    for (i = j = 0, len = values.length; j < len; i = ++j) {
      value = values[i];
      if (typeof value !== 'string') {
        throw new Error("Invalid definition of ENUM. Values must be an array of string.");
      }
      if (numsByValue[value] != null) {
        throw new Error("Invalid definition of ENUM. Value '" + value + "' is duplicated.");
      }
      numsByValue[value] = i;
    }
    if (typeof typeInfo["default"] === 'string') {
      if (numsByValue[typeInfo["default"]] == null) {
        throw new Error("Invalid default value '" + typeInfo["default"] + "' of ENUM.");
      }
      typeInfo["default"] = numsByValue[typeInfo["default"]];
    }
    if ((typeInfo["default"] != null) && (values[typeInfo["default"]] == null)) {
      throw new Error("Invalid default value '" + typeInfo["default"] + "' of ENUM.");
    }
    typeInfo.numsByValue = numsByValue;
    return typeInfo;
  };


  /**
  TYPES defines various data type, including model and array of models
  
  key: typeName (String)
  value: type TypeInfo|Function(TypeInfo)
  
  @property TYPES
  @static
   */

  TypeInfo.TYPES = {
    ANY: TypeInfo.createType('ANY'),
    STRING: TypeInfo.createType('STRING'),
    NUMBER: TypeInfo.createType('NUMBER'),
    BOOLEAN: TypeInfo.createType('BOOLEAN'),
    OBJECT: TypeInfo.createType('OBJECT'),
    ARRAY: TypeInfo.createType('ARRAY'),
    DATE: TypeInfo.createType('DATE'),
    BUFFER: TypeInfo.createType('BUFFER'),
    GEOPOINT: TypeInfo.createType('GEOPOINT'),
    CREATED_AT: TypeInfo.createType('CREATED_AT'),
    UPDATED_AT: TypeInfo.createType('UPDATED_AT'),
    SUB_ID: TypeInfo.createType('SUB_ID'),
    MODEL: TypeInfo.createModelType,
    ENUM: TypeInfo.createEnumType
  };

  return TypeInfo;

})();

module.exports = TypeInfo;
