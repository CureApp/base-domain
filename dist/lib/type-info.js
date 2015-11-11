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
    MODEL: TypeInfo.createModelType
  };

  return TypeInfo;

})();

module.exports = TypeInfo;
