

TYPES = require './types'
Base  = require './base'


###*
Base model class of DDD pattern.

the parent "Base" class just simply gives a @getFacade() method.


@class BaseModel
@extends Base
@module base-domain
###
class BaseModel extends Base

    @isEntity: false

    ###*
    key-value pair representing typeName - type

    use for definition of @properties for each extender

    @property TYPES
    @protected
    @final
    @static
    @type Object
    ###
    @TYPES: TYPES

    ###*
    key-value pair representing property's name - type of the model

        firstName    : @TYPES.STRING
        lastName     : @TYPES.STRING
        age          : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        team         : @TYPES.MODEL 'team'
        hobbies      : @TYPES.MODELS 'hobby'
        info         : @TYPES.ANY

    see types.coffee for full options.

    @property properties
    @abstract
    @static
    @type Object
    ###
    @properties: {}


    @getModelProperties: ->


    ###
    properties to cache, private.
    ###
    @_propsInfo: undefined
    @_propOfCreatedAt: undefined 
    @_propOfUpdatedAt: undefined


    ###*
    get key-value pair representing property's name - type info of the model
    if prop name is given, returns the info

    @method getPropertyInfo
    @public
    @static
    @param {String} prop
    @return {Object}
    ###
    @getPropertyInfo: (prop) ->

        if not @_propsInfo?

            @_propsInfo = {}
            for _prop, type of @properties
                typeInfo = @TYPES.info(type)
                @_propsInfo[_prop] = typeInfo

        if prop
            return @_propsInfo[prop]
        else
            return @_propsInfo 


    ###*
    get prop name whose type is CREATED_AT
    notice: only one prop should be enrolled to CREATED_AT

    @method getPropOfCreatedAt
    @public
    @static
    @return {String} propName
    ###
    @getPropOfCreatedAt: ->

        if @_propOfCreatedAt is undefined
            @_propOfCreatedAt = null 
            for prop, type of @properties
                if type is @TYPES.CREATED_AT
                    @_propOfCreatedAt = prop
                    break

        return @_propOfCreatedAt



    ###*
    get prop name whose type is UPDATED_AT
    notice: only one prop should be enrolled to UPDATED_AT

    @method getPropOfUpdatedAt
    @public
    @static
    @return {String} propName
    ###
    @getPropOfUpdatedAt: ->

        if @_propOfUpdatedAt is undefined
            @_propOfUpdatedAt = null
            for prop, type of @properties
                if type is @TYPES.UPDATED_AT
                    @_propOfUpdatedAt = prop
                    break

        return @_propOfUpdatedAt


    ###*
    create plain object without relational entities
    descendants of Entity are removed, but not descendants of BaseModel
    descendants of Entity in descendants of BaseModel are removed ( = recursive)

    FIXME: this method should not be in "factory"

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        propInfoMap = @constructor.getPropertyInfo()
        facade = @getFacade()

        plainObject = {}

        for own prop, value of @
            typeInfo = propInfoMap[prop]

            # set non-model properties
            if not typeInfo?.model?
                plainObject[prop] = value
                continue


            # strip model if it is descendant of Entity
            if @isSubClassOfEntity typeInfo.model
                continue


            # strip submodel's relation
            if typeInfo.name is 'MODEL'
                plainObject[prop] = value.toPlainObject()

            else # typeInfo.name is 'MODELS'
                plainObject[prop] = 
                    for subData in value
                        subData.toPlainObject()

        return plainObject


    ###*
    synchronize relation columns and relationId columns

    @param {Object} [options]
    @param {Boolean} [options.force]
    @method updateRelationIds
    ###
    updateRelationIds: (options = {})->

        for propName, typeInfo of @constructor.getPropertyInfo()

            modelName = typeInfo.model
            continue if not modelName

            propValue = @[propName]

            # should be subclass of entity
            if not @isSubClassOfEntity modelName
                continue

            @setRelatedModel(propName, propValue)

        return @


    ###*
    set related model(s)

    @method setRelatedModel
    @param {String} prop property name of the related model
    @param {Entity|Array<Entity>} submodel
    @return {BaseModel} this
    ###
    setRelatedModel: (prop, submodel) ->

        @assertEntityProp(prop, 'setRelatedModel(s)')

        typeInfo = @constructor.getPropertyInfo(prop)
        modelName = typeInfo.model
        idPropName = typeInfo.idPropName

        # when idProp is set and no submodel given, do nothing
        # call "unsetRelatedModel" to unset idProp
        if @[idPropName]? and not submodel?
            return @

        @[prop] = submodel

        if typeInfo.name is 'MODEL'
            @[idPropName] = submodel?.id
        else
            @[idPropName] = 
                if submodel
                    (sub.id for sub in submodel)
                else
                    []

        return @


    ###*
    alias for setRelatedModel

    @method setRelatedModels
    ###
    setRelatedModels: (prop, submodels) -> @setRelatedModel(prop, submodels)



    ###*
    unset related model(s)

    @param {String} prop property name of the related models
    @return {BaseModel} this
    @method setRelatedModels
    ###
    unsetRelatedModel: (prop) ->
        @assertEntityProp(prop, 'unsetRelatedModel(s)')

        typeInfo = @constructor.getPropertyInfo(prop)
        modelName = typeInfo.model
        idPropName = typeInfo.idPropName

        @[prop] = undefined

        if typeInfo.name is 'MODEL'
            @[idPropName] = undefined
        else
            @[idPropName] = []

        return @


    ###*
    alias for unsetRelatedModel

    @method unsetRelatedModels
    ###
    unsetRelatedModels: (prop, submodels) -> @unsetRelatedModel(prop, submodels)


    ###*
    add related models

    @param {String} prop property name of the related models
    @return {BaseModel} this
    @method addRelatedModels
    ###
    addRelatedModels: (prop, submodels...) ->
        @assertEntityProp(prop, 'addRelatedModels')

        typeInfo = @constructor.getPropertyInfo(prop)
        modelName = typeInfo.model

        if typeInfo.name isnt 'MODELS'
            throw @getFacade().error """
                #{@constructor.name}.addRelatedModels(#{prop})
                #{prop} is not a prop for models.
            """
        idPropName = typeInfo.idPropName
        @[prop] ?= []
        @[prop].push submodel for submodel in submodels
        @[idPropName] ?= []
        @[idPropName].push submodel.id for submodel in submodels

        return @



    ###*
    assert given prop is entity prop

    @method assertEntityProp
    @private
    ###
    assertEntityProp: (prop, method) ->

        typeInfo = @constructor.getPropertyInfo(prop)

        if not typeInfo? or not typeInfo.model
            throw @getFacade().error """
                #{@constructor.name}.#{method}(#{prop})
                #{prop} is not a prop for model.
            """

        modelName = typeInfo.model

        # should be subclass of entity
        if not @isSubClassOfEntity modelName
            throw @getFacade().error """
                #{@constructor.name}.#{method}(#{prop})
                #{prop} is a prop for model, but not subclass of Entity.
            """
        return




    ###*
    return if Model is subclass of Entity

    @method isSubClassOfEntity
    @private
    ###
    isSubClassOfEntity: (modelName) ->
        ModelClass = @getFacade().getModel modelName
        return ModelClass.isEntity




module.exports = BaseModel
