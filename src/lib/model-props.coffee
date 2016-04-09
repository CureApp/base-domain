'use strict'
{ TYPES } = require './type-info'

###*
parses model properties and classifies them

@class ModelProps
@module base-domain
###
class ModelProps

    ###*
    @param {String} modelName
    @param {Object} properties
    @param {BaseModule} modl
    ###
    constructor: (@modelName, properties, modl) ->

        ###*
        property whose type is CREATED_AT
        @property {String} createdAt
        @public
        @readonly
        ###
        @createdAt = null

        ###*
        property whose type is UPDATED_AT
        @property {String} updatedAt
        @public
        @readonly
        ###
        @updatedAt = null

        ###*
        properties whose type is DATE, CREATED_AT and UPDATED_AT
        @property {Array(String)} dates
        @public
        @readonly
        ###
        @dates = []

        # private
        @subModelProps = []
        @typeInfoDic = {}
        @entityDic = {}


        @parse properties, modl


    ###*
    parse props by type

    @method parse
    @private
    ###
    parse: (properties, modl) ->

        for prop, typeInfo of properties
            @parseProp(prop, typeInfo, modl)
        return



    ###*
    parse one prop by type

    @method parseProp
    @private
    ###
    parseProp: (prop, typeInfo, modl) ->

        @typeInfoDic[prop] = typeInfo

        switch typeInfo.typeName

            when 'DATE'
                @dates.push prop

            when 'CREATED_AT'
                @createdAt = prop
                @dates.push prop

            when 'UPDATED_AT'
                @updatedAt = prop
                @dates.push prop

            when 'MODEL'
                @parseSubModelProp(prop, typeInfo, modl)

        return


    ###*
    parse submodel prop

    @method parseSubModelProp
    @private
    ###
    parseSubModelProp: (prop, typeInfo, modl) ->

        @subModelProps.push prop

        if not modl?

            console.error("""
                base-domain:ModelProps could not parse property info of '#{prop}'.
                (@TYPES.#{typeInfo.typeName}, model=#{typeInfo.model}.)
                Construct original model '#{@modelName}' with RootInterface.

                    new Model(obj, facade)
                    facade.createModel('#{@modelName}', obj)

            """)
            return

        if modl.getModel(typeInfo.model).isEntity

            @entityDic[prop] = true

            idTypeInfo = TYPES.ID modelProp: prop, entity: typeInfo.model, omit: typeInfo.omit
            @parseProp(typeInfo.idPropName, idTypeInfo, modl)

        return


    ###*
    get all prop names

    @method getAllProps
    @public
    @return {Array(String)}
    ###
    getAllProps: ->
        Object.keys @typeInfoDic


    ###*
    get all entity prop names

    @method getEntityProps
    @public
    @return {Array(String)}
    ###
    getEntityProps: ->
        Object.keys @entityDic


    ###*
    get all model prop names

    @method getSubModelProps
    @public
    @return {Array(String)}
    ###
    getSubModelProps: ->
        @subModelProps.slice()



    ###*
    check if the given prop is entity prop

    @method isEntity
    @public
    @param {String} prop
    @return {Boolean}
    ###
    isEntity: (prop) ->
        @entityDic[prop]?


    ###*
    check if the given prop is submodel's id

    @method isId
    @public
    @param {String} prop
    @return {Boolean}
    ###
    isId: (prop) ->
        @typeInfoDic[prop]?.typeName is 'ID'


    ###*
    get submodel prop of the given idPropName

    @method getModelPropByIdProp
    @public
    @param {String} idPropName
    @return {String} submodelProp
    ###
    getModelPropByIdProp: (idProp) ->
        @typeInfoDic[idProp]?.modelProp


    ###*
    check if the given prop is tmp prop

    @method isOmitted
    @public
    @param {String} prop
    @return {Boolean}
    ###
    isOmitted: (prop) ->
        !!@typeInfoDic[prop]?.omit


    ###*
    get prop name of id of entity prop

    @method getSubIdProp
    @public
    @param {String} prop
    @return {String} idPropName
    ###
    getSubIdProp: (entityProp) ->

        @typeInfoDic[entityProp]?.idPropName


    ###*
    get model name of model prop

    @method getSubModelProps
    @public
    @param {String} prop
    @return {String} model name
    ###
    getSubModelName: (prop) ->

        @typeInfoDic[prop]?.model


    ###*
    check if the prop is optional

    @method isOptional
    @public
    @param {String} prop
    @return {Boolean}
    ###
    isOptional: (prop) ->

        !!@typeInfoDic[prop]?.optional


    ###*
    get the default value of the prop

    @method getDefaultValue
    @public
    @param {String} prop
    @return {any} defaultValue
    ###
    getDefaultValue: (prop) ->

        @typeInfoDic[prop]?.default


module.exports = ModelProps
