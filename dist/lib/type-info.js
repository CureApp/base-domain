var TypeInfo, camelize;

camelize = require('../util').camelize;


/**
type of model's property

@class TypeInfo
@module base-domain
 */

TypeInfo = (function() {
  var k, ref, v;

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
  Creates a function which returns TypeInfo
  
  @method createType
  @private
  @static
  @param {String} typeName
  @return {Function(TypeInfo)}
   */

  TypeInfo.createType = function(typeName) {
    var fn;
    fn = function(defaultValue) {
      if ((defaultValue != null ? defaultValue["default"] : void 0) != null) {
        defaultValue = defaultValue["default"];
      }
      return new TypeInfo(typeName, {
        "default": defaultValue
      });
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
  @param {String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
  @return {TypeInfo} type
   */

  TypeInfo.createModelType = function(modelName, idPropName) {
    return new TypeInfo('MODEL', {
      model: modelName,
      idPropName: idPropName != null ? idPropName : camelize(modelName, true) + 'Id'
    });
  };


  /**
  get TypeInfo as temporary value
  
  @method createTemporaryType
  @private
  @static
  @param {String} typeName
  @return {TypeInfo} type
   */

  TypeInfo.createTemporaryType = function(typeName, options) {
    if (typeName == null) {
      typeName = 'ANY';
    }
    if (options == null) {
      options = {};
    }
    options.tmp = true;
    return new TypeInfo(typeName, options);
  };

  ref = TypeInfo.createTemporaryType();
  for (k in ref) {
    v = ref[k];
    TypeInfo.createTemporaryType[k] = v;
  }


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
    MODEL: TypeInfo.createModelType,
    TMP: TypeInfo.createTemporaryType
  };

  return TypeInfo;

})();

module.exports = TypeInfo;
