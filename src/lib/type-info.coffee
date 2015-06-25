
{ camelize } = require './util'

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
    @return {Boolean}
    ###
    equals: (typeName) -> @name is typeName

    ###*
    check if the type is not the given typeName

    @method notEquals
    @public
    @param {String} typeName
    @return {Boolean}
    ###
    notEquals: (typeName) -> @name isnt typeName


    ###*
    get TypeInfo as MODEL

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
            idPropName : idPropName ?  camelize(modelName, true) + 'Id'


    ###*
    get TypeInfo as MODEL_LIST

    @method createModelListType
    @private
    @static
    @param {String} modelName
    @param {String} [options.idPropName] by default: xxxYyyIds when modelName is xxx-yyy
    @param {String} [options.name] name of list model, by default: xxx-yyy-list when modelName is xxx-yyy
    @return {TypeInfo} type
    ###
    @createModelListType: (modelName, options = {}) -> 
        if typeof options is 'string'
            options = name: options

        new TypeInfo 'MODEL_LIST',
            model      : modelName
            listName   : options.name ? "#{modelName}-list"


    ###*
    get TypeInfo as MODEL_DIC

    @method createModelDicType
    @private
    @static
    @param {String} modelName
    @param {String} [options.idPropName] by default: xxxYyyIds when modelName is xxx-yyy
    @param {String} [options.name] name of dic model, by default: xxx-yyy-dic when modelName is xxx-yyy
    @param {String} [options.key] function to get key from item. default: returns item.id
    @return {TypeInfo} type
    ###
    @createModelDicType: (modelName, options = {}) ->
        if typeof options is 'string'
            options = name: options

        else if typeof options is 'function'
            options = key: options

        new TypeInfo 'MODEL_DIC',
            model      : modelName
            dicName    : options.name ? "#{modelName}-dic"
            getKey     : options.key


    ###*
    get TypeInfo as temporary value

    @method createTemporaryType
    @private
    @static
    @param {String} typeName
    @return {TypeInfo} type
    ###
    @createTemporaryType: (typeName = 'ANY', options = {}) ->

        options.tmp = true

        new TypeInfo typeName, options

    ###
    these hacky codes makes
        @TYPES.TMP
    an object and also a function
    ###
    TypeInfo.createTemporaryType[k] = v for k, v of TypeInfo.createTemporaryType()



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
        MODEL_LIST : TypeInfo.createModelListType
        MODEL_DIC  : TypeInfo.createModelDicType
        TMP        : TypeInfo.createTemporaryType



module.exports = TypeInfo
