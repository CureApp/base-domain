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
        ###
        @createdAt = null

        ###*
        property whose type is UPDATED_AT
        @property {String} updatedAt
        ###
        @updatedAt = null

        ###*
        properties whose type is MODEL
        @property {Array(String)} models
        ###
        @models = []

        ###*
        properties whose type is MODEL and the model extends Entity
        @property {Array(String)} entities
        ###
        @entities = []

        ###*
        properties whose type is DATE, CREATED_AT and UPDATED_AT
        @property {Array(String)} dates
        ###
        @dates = []

        ###*
        properties whose type is MODEL and the model does not extend Entity
        @property {Array(String)} valueObjects
        ###
        @valueObjects = []

        # private
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

        @models.push prop

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

            @entities.push prop
            @entityDic[prop] = true

            idTypeInfo = TYPES.ID modelProp: prop, entity: typeInfo.model, omit: typeInfo.omit
            @parseProp(typeInfo.idPropName, idTypeInfo, modl)

        else
            @valueObjects.push prop

        return


    names: ->
        Object.keys @typeInfoDic


    ###*
    check if the given prop is entity prop

    @method isEntity
    @param {String} prop
    @return {Boolean}
    ###
    isEntity: (prop) ->
        @entityDic[prop]?


    ###*
    check if the given prop is submodel's id

    @method isId
    @param {String} prop
    @return {Boolean}
    ###
    isId: (prop) ->
        @typeInfoDic[prop]?.typeName is 'ID'


    ###*
    get submodel prop of the given idPropName

    @method modelPropOf
    @param {String} idPropName
    @return {String} submodelProp
    ###
    modelPropOf: (idPropName) ->
        @typeInfoDic[idPropName]?.modelProp


    ###*
    check if the given prop is tmp prop

    @method checkOmit
    @param {String} prop
    @return {Boolean}
    ###
    checkOmit: (prop) ->
        !!@typeInfoDic[prop]?.omit


    getSubIdProp: (prop) ->

        @typeInfoDic[prop]?.idPropName


    getSubModelName: (prop) ->

        @typeInfoDic[prop]?.model


    isOptional: (prop) ->

        !!@typeInfoDic[prop]?.optional


    getDefaultValue: (prop) ->

        @typeInfoDic[prop]?.default


module.exports = ModelProps
