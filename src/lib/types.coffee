

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
    CREATED_AT : 'date:c'
    UPDATED_AT : 'date:u'

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
@return {String} type
###
TYPES.MODEL = (modelName) -> "m<#{modelName}>"


###*
get type of model name (array) by model name

     model     =>   type
    "notebook" => "a<notebook>"

@method MODELS
@public
@static
@param {String} modelName
@return {String} type
###
TYPES.MODELS = (modelName) -> "a<#{modelName}>"



###*
get information object by type

@method info
@public
@static
@param {String} type
@return {Object} info
@return {String} [info.name] type name
@return {String|null} [info.model] if model-related type, the name of the model 
@return {String|null} [info.subtype] if date-related type, CREATE or UPDATE is in it

###
TYPES.info = (type) ->

    return name: null unless type?


    if match = type.match /([am])<([^>]+)>/
        [all, m_or_a, modelName] = match

        typeName = if m_or_a is 'm' then 'MODEL' else 'MODELS'

        return {
            name: typeName
            model: match[2]
        }

    else if match = type.match /date:([UC])/
        u_or_c = match[1]

        return {
            name: 'date'
            subtype: if u_or_c is 'u' then 'UPDATE' else 'CREATE'
        }

    else
        return name: (REV_TYPES[type] ? null)


module.exports = TYPES
