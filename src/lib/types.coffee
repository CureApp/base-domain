

###*
define various data type, including model and array of models

key: typeName (String)
value: type (String|Function)

@class TYPES
@module base-domain
###

TYPES =
    ANY        : 'any'
    STRING     : 'string'
    NUMBER     : 'number'
    BOOLEAN    : 'boolean'
    OBJECT     : 'object'
    ARRAY      : 'array'
    DATE       : 'date'
    BUFFER     : 'buffer'
    GEOPOINT   : 'geopoint'
    CREATED_AT : 'created'
    UPDATED_AT : 'updated'

REV_TYPES = {}
REV_TYPES[v] = k for k, v of TYPES


###*
get type of single model name by model name

     model     =>   type
    "notebook" => "m<notebook>"

@method MODEL
@public
@static
@param {String} modelName
@param {String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
@return {String} type
###
TYPES.MODEL = (modelName, idPropName) -> 
    idPropName ?= camelize(modelName) + 'Id'
    "m<#{modelName},#{idPropName}>"


###*
get type of model name (array) by model name

     model     =>   type
    "notebook" => "a<notebook>"

@method MODELS
@public
@static
@param {String} modelName
@param {String} [idPropName] by default: xxxYyyIds when modelName is xxx-yyy
@return {String} type
###
TYPES.MODELS = (modelName, idPropName) -> 
    idPropName ?= camelize(modelName) + 'Ids'
    "a<#{modelName},#{idPropName}>"



###*
get information object by type

@method info
@public
@static
@param {String} type
@return {Object} info
@return {String} [info.name] type name
@return {String|null} [info.model] if model-related type, the name of the model 

###
TYPES.info = (type) ->

    return name: null unless type?


    if match = type.match /([am])<([^,]+),([^>]+)>/
        [all, m_or_a, modelName, idPropName] = match

        typeName = if m_or_a is 'm' then 'MODEL' else 'MODELS'

        return {
            name: typeName
            model: match[2]
            idPropName: idPropName
        }

    else
        return name: (REV_TYPES[type] ? null)



# 'shinout-no-macbook-pro => shinoutNoMacbookPro'
camelize = (str) ->
   (for substr, i in str.split('-')
       if i is 0
           substr
       else
           substr.charAt(0).toUpperCase() + substr.slice(1)
   ).join('')



module.exports = TYPES
