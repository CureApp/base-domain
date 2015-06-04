

TypeInfo = require './type-info'
PropInfo = require './prop-info'
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
    ModelName -> model-name

    @private
    ###
    @getModelName: ->
        @name.replace(/([A-Z])/g, (st)-> '-' + st.charAt(0).toLowerCase()).slice(1)


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
    @protected
    @type Object
    ###
    @properties: {}


    ###*
    get an instance of PropInfo, which summarizes properties of this class

    @method getPropInfo
    @public
    @return {PropInfo}
    ###
    @_pi: null
    @getPropInfo: ->
        @_pi ?= new PropInfo @properties, @getFacade()


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


    ###*
    get list of properties which contains entity

    @method getEntityProps
    @public
    @static
    @return {Array}
    ###
    @getEntityProps: ->
        @getPropInfo().entityProps

    ###*
    get list of properties which contains relational model

    @method getModelProps
    @public
    @static
    @return {Array}
    ###
    @getModelProps: ->
        @getPropInfo().modelProps


    ###*
    @constructor
    ###
    constructor: (obj) ->

        @[prop] ?= undefined for prop of @constructor.properties
        @set obj if obj



    getTypeInfo: (prop) ->
        @constructor.getPropInfo().props[prop]


    ###*
    set value to prop
    @return {BaseModel} this
    ###
    set: (prop, value) ->
        if typeof prop is 'object'
            @set(k, v) for k, v of prop
            return @

        typeInfo = @getTypeInfo prop

        if typeInfo?.model and @isSubClassOfEntity(typeInfo.model)
            @setEntityProp(prop, value)
        else
            @setNonEntityProp(prop, value)

        return @


    ###*
    set model prop
    @return {BaseModel} this
    ###
    setNonEntityProp: (prop, value) ->
        @[prop] = value



    ###*
    synchronize relation columns and relationId columns

    @param {Object} [options]
    @param {Boolean} [options.force]
    @method updateRelationIds
    ###
    updateRelationIds: (options = {})->

        for propName in @constructor.getEntityProps()

            typeInfo = @getTypeInfo propName

            modelName = typeInfo.model

            propValue = @[propName]

            @setEntityProp(propName, propValue)

        return @


    ###*
    set related model(s)

    @method setEntityProp
    @param {String} prop property name of the related model
    @param {Entity|Array<Entity>} submodel
    @return {BaseModel} this
    ###
    setEntityProp: (prop, submodel) ->

        typeInfo = @getTypeInfo prop
        modelName = typeInfo.model

        @[prop] = submodel

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
    alias for setEntityProp

    @method setEntityProps
    ###
    setEntityProps: (prop, submodels) -> @setEntityProp(prop, submodels)



    ###*
    unset related model(s)

    @param {String} prop property name of the related models
    @return {BaseModel} this
    @method unsetEntityProp
    ###
    unsetEntityProp: (prop) ->

        typeInfo = @getTypeInfo prop
        modelName = typeInfo.model
        idPropName = typeInfo.idPropName

        @[prop] = undefined

        if typeInfo.equals 'MODEL'
            @[idPropName] = undefined
        else
            @[idPropName] = []

        return @


    ###*
    alias for unsetEntityProp

    @method unsetEntityProps
    ###
    unsetEntityProps: (prop, submodels) -> @unsetEntityProp(prop, submodels)


    ###*
    add related models

    @param {String} prop property name of the related models
    @return {BaseModel} this
    @method addRelatedModels
    ###
    addRelatedModels: (prop, submodels...) ->

        typeInfo = @getTypeInfo prop
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
            typeInfo = @getTypeInfo prop

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
            for m in @constructor.getEntityProps()
                do (modelProp = m) =>
                    propInfo = @getTypeInfo modelProp

                    if not @[modelProp]? and (relId = @[propInfo.idPropName])?

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
                propInfo = @getTypeInfo modelProp

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
    return if Model is subclass of Entity

    @method isSubClassOfEntity
    @private
    ###
    isSubClassOfEntity: (modelName) ->
        ModelClass = @getFacade().getModel modelName
        return ModelClass.isEntity



module.exports = BaseModel
