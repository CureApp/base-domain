var TypeInfo, camelize;

camelize = require('../util').camelize;


/**
type of model's property 

@class TypeInfo
@module base-domain
 */

TypeInfo = (function() {
  var k, ref, v;

  function TypeInfo(name, options) {
    var k, v;
    this.name = name;
    if (options == null) {
      options = {};
    }
    for (k in options) {
      v = options[k];
      this[k] = v;
    }
  }


  /**
  check if the type is the given typeName
  
  @method equals
  @public
  @param {String} typeName
  @return {Boolean}
   */

  TypeInfo.prototype.equals = function(typeName) {
    return this.name === typeName;
  };


  /**
  check if the type is not the given typeName
  
  @method notEquals
  @public
  @param {String} typeName
  @return {Boolean}
   */

  TypeInfo.prototype.notEquals = function(typeName) {
    return this.name !== typeName;
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
  get TypeInfo as MODEL_LIST
  
  @method createModelListType
  @private
  @static
  @param {String} itemModelName
  @param {String} [options.name] name of list model, by default: xxx-yyy-list when itemModelName is xxx-yyy
  @return {TypeInfo} type
   */

  TypeInfo.createModelListType = function(itemModelName, options) {
    var ref;
    if (options == null) {
      options = {};
    }
    if (typeof options === 'string') {
      options = {
        name: options
      };
    }
    return new TypeInfo('MODEL_LIST', {
      itemModel: itemModelName,
      model: (ref = options.name) != null ? ref : itemModelName + "-list"
    });
  };


  /**
  get TypeInfo as MODEL_DICT
  
  @method createModelDictType
  @private
  @static
  @param {String} itemModelName
  @param {String} [options.name] name of dict model, by default: xxx-yyy-dict when itemModelName is xxx-yyy
  @return {TypeInfo} type
   */

  TypeInfo.createModelDictType = function(itemModelName, options) {
    var ref;
    if (options == null) {
      options = {};
    }
    if (typeof options === 'string') {
      options = {
        name: options
      };
    }
    return new TypeInfo('MODEL_DICT', {
      itemModel: itemModelName,
      model: (ref = options.name) != null ? ref : itemModelName + "-dict"
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


  /*
  these hacky codes makes
      @TYPES.TMP
  an object and also a function
   */

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
    ANY: new TypeInfo('ANY'),
    STRING: new TypeInfo('STRING'),
    NUMBER: new TypeInfo('NUMBER'),
    BOOLEAN: new TypeInfo('BOOLEAN'),
    OBJECT: new TypeInfo('OBJECT'),
    ARRAY: new TypeInfo('ARRAY'),
    DATE: new TypeInfo('DATE'),
    BUFFER: new TypeInfo('BUFFER'),
    GEOPOINT: new TypeInfo('GEOPOINT'),
    CREATED_AT: new TypeInfo('CREATED_AT'),
    UPDATED_AT: new TypeInfo('UPDATED_AT'),
    MODEL: TypeInfo.createModelType,
    MODEL_LIST: TypeInfo.createModelListType,
    MODEL_DICT: TypeInfo.createModelDictType,
    TMP: TypeInfo.createTemporaryType
  };

  return TypeInfo;

})();

module.exports = TypeInfo;
