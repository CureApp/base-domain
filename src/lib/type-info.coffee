'use strict'

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
    default value
    @property {any} default
    ###

    ###*
    flag not to include this prop after 'toPlainObject()'
    @property {Boolean} omit
    ###

    ###*
    Creates a function which returns TypeInfo

    @method createType
    @private
    @static
    @param {String} typeName
    @return {Function(TypeInfo)}
    ###
    @createType: (typeName) ->

        fn = (options) ->

            if not options?.hasOwnProperty('default') and not options?.hasOwnProperty('omit')
                options = default: options

            return new TypeInfo typeName, options

        fn.typeName = typeName

        return fn


    ###*
    get TypeInfo as MODEL

    @method createModelType
    @private
    @static
    @param {String} modelName
    @param {Options|String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
    @return {TypeInfo} type
    ###
    @createModelType: (modelName, options = {}) ->

        if typeof options is 'string'
            options = idPropName: options

        options.model = modelName
        options.idPropName ?= camelize(modelName, true) + 'Id'

        new TypeInfo 'MODEL', options


    ###*
    get TypeInfo as MODEL

    @method createEnumType
    @private
    @static
    @param {Array(String)} values
    @param {Object|String} [idPropName] by default: xxxYyyId when modelName is xxx-yyy
    @return {TypeInfo} type
    ###
    @createEnumType: (values, options = {}) ->

        if typeof options isnt 'object'
            options = default: options

        options.values = values

        new TypeInfo 'ENUM', options



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
        SUB_ID     : @createType 'SUB_ID'
        MODEL      : @createModelType
        ENUM       : @createEnumType


module.exports = TypeInfo
