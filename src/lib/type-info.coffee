
{ camelize } = require '../util'

###*
type of model's property

@class TypeInfo
@module base-domain
###
class TypeInfo

    constructor: (@typeName, options = {}) ->
        @[k] = v for k, v of options



    ###*
    Creates a function which returns TypeInfo

    @method createType
    @private
    @static
    @param {String} typeName
    @return {Function(TypeInfo)}
    ###
    @createType: (typeName) ->

        fn = (defaultValue) ->

            if defaultValue?.default?
                defaultValue = defaultValue.default

            return new TypeInfo typeName, default: defaultValue

        fn.typeName = typeName

        return fn


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

    # the following hacky codes makes @TYPES.TMP an object and also a function
    TypeInfo.createTemporaryType[k] = v for k, v of TypeInfo.createTemporaryType()



    ###*
    TYPES defines various data type, including model and array of models

    key: typeName (String)
    value: type TypeInfo|Function(TypeInfo)

    @property TYPES
    @static
    ###
    @TYPES:
        ANY        : @createType 'ANY'
        STRING     : @createType 'STRING'
        NUMBER     : @createType 'NUMBER'
        BOOLEAN    : @createType 'BOOLEAN'
        OBJECT     : @createType 'OBJECT'
        ARRAY      : @createType 'ARRAY'
        DATE       : @createType 'DATE'
        BUFFER     : @createType 'BUFFER'
        GEOPOINT   : @createType 'GEOPOINT'
        CREATED_AT : @createType 'CREATED_AT'
        UPDATED_AT : @createType 'UPDATED_AT'
        MODEL      : @createModelType
        TMP        : @createTemporaryType


module.exports = TypeInfo
