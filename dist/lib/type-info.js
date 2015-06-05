
/**
type of model's property 

@class TypeInfo
@module base-domain
 */
var TypeInfo;

TypeInfo = (function() {
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
      idPropName: idPropName != null ? idPropName : TypeInfo.camelize(modelName) + 'Id'
    });
  };


  /**
  get TypeInfo as MODEL_LIST
  
  @method createModelListType
  @private
  @static
  @param {String} modelName
  @param {String} [options.idPropName] by default: xxxYyyIds when modelName is xxx-yyy
  @param {String} [options.name] name of list model, by default: xxx-yyy-list when modelName is xxx-yyy
  @return {TypeInfo} type
   */

  TypeInfo.createModelListType = function(modelName, options) {
    var ref, ref1;
    if (options == null) {
      options = {};
    }
    return new TypeInfo('MODEL_LIST', {
      model: modelName,
      idPropName: (ref = options.idPropName) != null ? ref : TypeInfo.camelize(modelName) + 'Ids',
      listName: (ref1 = options.name) != null ? ref1 : modelName + "-list"
    });
  };


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
    MODEL_LIST: TypeInfo.createModelListType
  };


  /**
  converts hyphenation to camel case
  
      'shinout-no-macbook-pro => shinoutNoMacbookPro'
  
  @method camelize
  @private
  @static
  @param {String} hyphened
  @return {String} cameled
   */

  TypeInfo.camelize = function(hyphened) {
    var i, substr;
    return ((function() {
      var j, len, ref, results;
      ref = hyphened.split('-');
      results = [];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        substr = ref[i];
        if (i === 0) {
          results.push(substr);
        } else {
          results.push(substr.charAt(0).toUpperCase() + substr.slice(1));
        }
      }
      return results;
    })()).join('');
  };

  return TypeInfo;

})();

module.exports = TypeInfo;
