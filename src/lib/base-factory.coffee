

Base  = require './base'
TYPES = require './types'
Entity = require './entity'

###*
Base factory class of DDD pattern.

create instance of model

the parent "Base" class just simply gives a @getFacade() method.

@class BaseFactory
@extends Base
@module base-domain
###
class BaseFactory extends Base

    ###*
    model name to handle

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: null


    ###*
    constructor

    @constructor
    ###
    constructor: ->



    ###*
    get model class this factory handles

    @method getModelClass
    @return {Class}
    ###
    getModelClass: ->
        modelName = @constructor.modelName
        @getFacade().getModel(modelName)


    ###*
    create empty model instance

    @method createEmptyModel
    @return {BaseModel}
    ###
    createEmptyModel: ->
        ModelClass = @getModelClass()
        model = new ModelClass()
        model[prop] = undefined for prop of ModelClass.properties
        return @afterCreateModel model


    ###*
    create instance of model class by plain object

    for each prop, values are modified by @modifyValueByPropName()

    @method createFromObject
    @public
    @param {Object} obj
    @param {BaseModel} baseModel fallback properties
    @return {BaseModel} model
    ###
    createFromObject: (obj, baseModel) ->

        obj = @beforeCreateFromObject obj

        if not obj? or typeof obj isnt 'object'
            return null


        ModelClass = @getModelClass()
        model = new ModelClass()

        for own prop, value of obj

            if prop is 'id'
                model.id = @modifyIdValue value

            else
                model[prop] = @modifyValueByPropName(prop, value)

        if baseModel
            for prop of ModelClass.properties
                if not model[prop]?
                    model[prop] ?= baseModel[prop]
        else
            model[prop] ?= undefined for prop of ModelClass.properties


        model = @afterCreateModel model

        # add xxxId, xxxIds
        model.updateRelationIds()

        return model



    ###*
    modify plain object before @createFromObject(obj)

    @method beforeCreateFromObject
    @protected
    @abstract
    @param {Object} obj
    @return {Object} obj
    ###
    beforeCreateFromObject: (obj) ->

        return obj

    ###*
    modify model after createFromObject(obj), createEmptyModel()

    @method afterCreateModel
    @protected
    @abstract
    @param {BaseModel} model
    @return {BaseModel} model
    ###
    afterCreateModel: (model) ->

        return model



    ###*
    modify value of prop of plain object by property name

    @method modifyValueByNonModelPropName
    @protected
    @param {String} prop name
    @param {any} value
    @return {any} value modified value
    ###
    modifyValueByPropName: (prop, value) ->

        Model = @getModelClass()

        typeInfo = Model.getPropertyInfo(prop)

        if typeInfo?.model

            subModelFactory = @getFacade().createFactory(typeInfo.model)
            SubModel = subModelFactory.getModelClass()

            # if prop is array of models
            if typeInfo.name is 'MODELS' and Array.isArray value
                return (for subObj in value
                    if subObj instanceof SubModel
                        subObj
                    else
                        subModelFactory.createFromObject(subObj)
                )

            # if prop is model
            else if typeInfo.name is 'MODEL'
                if value instanceof SubModel
                    return value
                else
                    return subModelFactory.createFromObject(value)

        return @modifyValueByNonModelPropName(prop, value)


    ###*
    modify non-model value of prop of plain object by property name

    By default, value is not modified.
    This means that even if property info suggests the value should be number, casting to number won't be occurred.
    This let-it-be policy is for flexibility.
    You can modify values by implementing this method in subclass.

    @method modifyValueByNonModelPropName
    @protected
    @abstract
    @param {String} prop name
    @param {any} value
    @return {any} value modified value
    ###
    modifyValueByNonModelPropName: (prop, value) ->

        return value


    ###*
    modify id value from plain object and set it to model
    Do nothing by default.

    @method modifyIdValue
    @protected
    @param {any} id
    @return {any} id modified id
    ###
    modifyIdValue: (idValue) ->

        return idValue





module.exports = BaseFactory
