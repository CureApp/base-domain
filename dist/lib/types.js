
/**
define various data type, including model and array of models

key: typeName (String)
value: type (String|Function)

@class TYPES
@module base-domain
 */
var REV_TYPES, TYPES, camelize, k, v;

TYPES = {
  ANY: 'any',
  STRING: 'string',
  NUMBER: 'number',
  BOOLEAN: 'boolean',
  OBJECT: 'object',
  ARRAY: 'array',
  DATE: 'date',
  BUFFER: 'buffer',
  GEOPOINT: 'geopoint',
  CREATED_AT: 'created',
  UPDATED_AT: 'updated'
};

REV_TYPES = {};

for (k in TYPES) {
  v = TYPES[k];
  REV_TYPES[v] = k;
}


/**
get type of single model name by model name

     model     =>   type
    "notebook" => "m<notebook>"

@method MODEL
@public
@static
@param {String} modelName
@param {String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
@return {String} type
 */

TYPES.MODEL = function(modelName, idPropName) {
  if (idPropName == null) {
    idPropName = camelize(modelName) + 'Id';
  }
  return "m<" + modelName + "," + idPropName + ">";
};


/**
get type of model name (array) by model name

     model     =>   type
    "notebook" => "a<notebook>"

@method MODELS
@public
@static
@param {String} modelName
@param {String} [idPropName] by default: xxxYyyIds when modelName is xxx-yyy
@return {String} type
 */

TYPES.MODELS = function(modelName, idPropName) {
  if (idPropName == null) {
    idPropName = camelize(modelName) + 'Ids';
  }
  return "a<" + modelName + "," + idPropName + ">";
};


/**
get information object by type

@method info
@public
@static
@param {String} type
@return {Object} info
@return {String} [info.name] type name
@return {String|null} [info.model] if model-related type, the name of the model
 */

TYPES.info = function(type) {
  var all, idPropName, m_or_a, match, modelName, ref, typeName;
  if (type == null) {
    return {
      name: null
    };
  }
  if (match = type.match(/([am])<([^,]+),([^>]+)>/)) {
    all = match[0], m_or_a = match[1], modelName = match[2], idPropName = match[3];
    typeName = m_or_a === 'm' ? 'MODEL' : 'MODELS';
    return {
      name: typeName,
      model: match[2],
      idPropName: idPropName
    };
  } else {
    return {
      name: (ref = REV_TYPES[type]) != null ? ref : null
    };
  }
};

camelize = function(str) {
  var i, substr;
  return ((function() {
    var j, len, ref, results;
    ref = str.split('-');
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

module.exports = TYPES;
