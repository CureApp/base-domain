
###*
type of model's property 

@class TypeInfo
@module base-domain
###
class TypeInfo

    constructor: (@name, options = {}) ->
        @[k] = v for k, v of options


    ###*
    check if the type is the given typeName

    @method equals
    @public
    @param {String} typeName
    @retrun {Boolean}
    ###
    equals: (typeName) -> @name is typeName

    ###*
    check if the type is not the given typeName

    @method notEquals
    @public
    @param {String} typeName
    @retrun {Boolean}
    ###
    notEquals: (typeName) -> @name isnt typeName


    ###*
    get type of single model name by model name

         model     =>   type
        "notebook" => "m<notebook>"

    @method createModelType
    @private
    @static
    @param {String} modelName
    @param {String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
    @return {TypeInfo} type
    ###
    @createModelType: (modelName, idPropName) -> 

        new TypeInfo 'MODEL',
            model      : modelName
            idPropName : idPropName ?  TypeInfo.camelize(modelName) + 'Id'


    ###*
    get type of model name (array) by model name

         model     =>   type
        "notebook" => "a<notebook>"

    @method createModelsType
    @private
    @static
    @param {String} modelName
    @param {String} [idPropName] by default: xxxYyyIds when modelName is xxx-yyy
    @return {TypeInfo} type
    ###
    @createModelsType: (modelName, idPropName) -> 
        new TypeInfo 'MODELS',
            model      : modelName
            idPropName : idPropName ? TypeInfo.camelize(modelName) + 'Ids'



    ###*
    TYPES defines various data type, including model and array of models

    key: typeName (String)
    value: type TypeInfo|Function(TypeInfo)

    @property TYPES
    @static
    ###

    @TYPES:
        ANY        : new TypeInfo 'ANY'
        STRING     : new TypeInfo 'STRING'
        NUMBER     : new TypeInfo 'NUMBER'
        BOOLEAN    : new TypeInfo 'BOOLEAN'
        OBJECT     : new TypeInfo 'OBJECT'
        ARRAY      : new TypeInfo 'ARRAY'
        DATE       : new TypeInfo 'DATE'
        BUFFER     : new TypeInfo 'BUFFER'
        GEOPOINT   : new TypeInfo 'GEOPOINT'
        CREATED_AT : new TypeInfo 'CREATED_AT'
        UPDATED_AT : new TypeInfo 'UPDATED_AT'
        MODEL      : TypeInfo.createModelType
        MODELS     : TypeInfo.createModelsType



    ###*
    converts hyphenation to camel case

        'shinout-no-macbook-pro => shinoutNoMacbookPro'

    @method camelize
    @private
    @static
    @param {String} hyphened
    @return {String} cameled
    ###
    @camelize: (hyphened) ->
       (for substr, i in hyphened.split('-')
           if i is 0
               substr
           else
               substr.charAt(0).toUpperCase() + substr.slice(1)
       ).join('')



module.exports = TypeInfo
