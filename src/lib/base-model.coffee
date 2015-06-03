

TypeInfo = require './type-info'
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
    @TYPES: TypeInfo.TYPES

    ###*
    key-value pair representing property's name - type of the model

        firstName    : @TYPES.STRING
        lastName     : @TYPES.STRING
        age          : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        team         : @TYPES.MODEL 'team'
        hobbies      : @TYPES.MODELS 'hobby'
        info         : @TYPES.ANY

    see type-info.coffee for full options.

    @property properties
    @abstract
    @static
    @type Object
    ###
    @properties: {}


    ###*
    extend @properties of Parent class

    @example
        class Parent extends BaseModel
            @properties:
                prop1: @TYPES.STRING


        class ChildModel extends ParentModel

            @properties: @withParentProps
                prop2: @TYPES.NUMBER

        ChildModel.properties # prop1 and prop2


    @method withParentProps
    @protected
    @static
    @return {Object}
    ###
    @withParentProps: (props = {}) ->
        props[k] ?= v for k, v of @properties # @properties === parent's properties
        return props


    ###
    properties to cache, private.
    ###
    @_propOfCreatedAt: undefined 
    @_propOfUpdatedAt: undefined
    @_modelProps: undefined



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
            for prop, typeInfo of @properties
                if typeInfo.equals 'CREATED_AT'
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
            for prop, typeInfo of @properties
                if typeInfo.equals 'UPDATED_AT'
                    @_propOfUpdatedAt = prop
                    break

        return @_propOfUpdatedAt


    ###*
    get list of properties which contains relational model

    @method getModelProps
    @public
    @static
    @return {Array}
    ###
    @getModelProps: ->

        if not @_modelProps?

            @_modelProps = []
            for prop, typeInfo of @properties
                if typeInfo.model?
                    @_modelProps.push prop

        return @_modelProps



    ###*
    set value to prop
    @return {BaseModel} this
    ###
    set: (prop, value) ->
        if typeof prop is 'object'
            @set(k, v) for k, v of prop
            return @

        typeInfo = @constructor.properties[prop]

        if typeInfo?.model
            @setRelatedModel(prop, value)
        else
            @setNonModelProp(prop, value)

        return @


    ###*
    set model prop
    @return {BaseModel} this
    ###
    setNonModelProp: (prop, value) ->
        @[prop] = value



    ###*
    synchronize relation columns and relationId columns

    @param {Object} [options]
    @param {Boolean} [options.force]
    @method updateRelationIds
    ###
    updateRelationIds: (options = {})->

        for propName in @constructor.getModelProps()

            typeInfo = @constructor.properties[propName]

            modelName = typeInfo.model

            propValue = @[propName]

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

        @assertSubModelProp(prop, 'setRelatedModel(s)')

        typeInfo = @constructor.properties[prop]
        modelName = typeInfo.model

        @[prop] = submodel

        # id(s) are not added if submodel is not subclass of entity
        if not @isSubClassOfEntity modelName
            return @


        idPropName = typeInfo.idPropName

        if typeInfo.equals 'MODEL'
            @[idPropName] = submodel?.id
        else # if typeInfo.equals 'MODELS'
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
        @assertSubModelProp(prop, 'unsetRelatedModel(s)')

        typeInfo = @constructor.properties[prop]
        modelName = typeInfo.model
        idPropName = typeInfo.idPropName

        @[prop] = undefined

        if typeInfo.equals 'MODEL'
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
        @assertSubModelProp(prop, 'addRelatedModels')

        typeInfo = @constructor.properties[prop]
        modelName = typeInfo.model

        if typeInfo.notEquals 'MODELS'
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
    inherit value of anotherModel

    @method inherit
    @param {BaseModel} anotherModel
    @return {BaseModel} this
    ###
    inherit: (anotherModel) ->
        for own k, v of anotherModel
            if v?
                @[k] = v

        return @


    ###*
    create plain object without relational entities
    descendants of Entity are removed, but not descendants of BaseModel
    descendants of Entity in descendants of BaseModel are removed ( = recursive)

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        facade = @getFacade()

        plainObject = {}

        for own prop, value of @
            typeInfo = @constructor.properties[prop]

            # set non-model properties
            if not typeInfo?.model?
                plainObject[prop] = value
                continue


            # strip model if it is descendant of Entity
            if @isSubClassOfEntity typeInfo.model
                continue


            # strip submodel's relation
            if typeInfo.equals 'MODEL'
                if value instanceof BaseModel
                    plainObject[prop] = value.toPlainObject()
                else
                    plainObject[prop] = value

            else # typeInfo.equals 'MODELS'
                plainObject[prop] = 
                    for subData in value
                        if subData instanceof BaseModel
                            subData.toPlainObject()
                        else
                            subData


        return plainObject


    ###*
    include all relational models if not set

    @method includeAll
    @param {Object} [options]
    @param {Boolean|Object} [options.recursive] recursively include models or not. unstable.
    @return {Promise(BaseModel)} self
    ###
    include: (options = {}) ->
        facade = @getFacade()

        modelPool = options.modelPool ? {}

        if options.recursive
            modelName = @constructor.getModelName()

            modelPool[modelName] = {}
            modelPool[modelName][@id] = @ if @id?


        promises =
            for m in @constructor.getModelProps()
                do (modelProp = m) =>
                    propInfo = @constructor.properties[modelProp]

                    if not @[modelProp]? and (relId = @[propInfo.idPropName])? and @isSubClassOfEntity propInfo.model

                        repo = facade.createRepository(propInfo.model)

                        promise =
                            if Array.isArray relId
                                relIds = relId
                                objs = []
                                novelRelIds = []

                                for relId in relIds
                                    if modelPool[propInfo.model]?[relId]?
                                        objs.push modelPool[propInfo.model][relId]
                                    else
                                        novelRelIds.push relId

                                if objs.length is relIds.length
                                    Promise.resolve(objs)
                                else
                                    repo.query(where: id: inq: novelRelIds).then (results) ->
                                        objs = objs.concat results

                            else
                                if modelPool[propInfo.model]?[relId]?
                                    Promise.resolve(modelPool[propInfo.model][relId])
                                repo.get(relId)

                        promise.then (val) =>
                            @set modelProp, val
                        .catch (e) ->


        Promise.all(promises).then =>
            unless options.recursive
                return @

            subPromises = []

            for modelProp in @constructor.getModelProps()
                propInfo = @constructor.properties[modelProp]

                if propInfo.equals('MODELS') and Array.isArray @[modelProp]
                    for model in @[modelProp]
                        if model instanceof BaseModel
                            promise = model.include(recursive: true, modelPool: modelPool)
                            subPromises.push promise

                else
                    model = @[modelProp]
                    if model instanceof BaseModel
                        promise = model.include(recursive: true, modelPool: modelPool)
                        subPromises.push promise

            return Promise.all subPromises

        .then =>
            return @



    ###*
    assert given prop is model prop

    @method assertSubModelProp
    @private
    ###
    assertSubModelProp: (prop, method) ->

        typeInfo = @constructor.properties[prop]

        if not typeInfo? or not typeInfo.model
            throw @getFacade().error """
                #{@constructor.name}.#{method}(#{prop})
                #{prop} is not a prop for model.
            """

    @getModelName: ->
        @name.replace(/([A-Z])/g, (st)-> '-' + st.charAt(0).toLowerCase()).slice(1)


    ###*
    return if Model is subclass of Entity

    @method isSubClassOfEntity
    @private
    ###
    isSubClassOfEntity: (modelName) ->
        ModelClass = @getFacade().getModel modelName
        return ModelClass.isEntity





module.exports = BaseModel
