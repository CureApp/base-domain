

Base  = require './base'
TYPES = require './types'

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
    key-value pair of prop name -> type info  when prop is model/models

    @property modelProperties
    @protected
    @type Object
    ###

    ###*
    constructor

    @constructor
    @return
    ###
    constructor: ->
        @modelProperties = {}

        propertyInfo = @getModelClass().properties

        for prop, type of propertyInfo
            typeInfo = TYPES.info(type)
            if typeInfo.model
                @modelProperties[prop] = typeInfo



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
        return @afterCreateModel model



    ###*
    create instance of model class by plain object

    for each prop, values are modified by @modifyValueByPropName()

    @method createFromObject
    @public
    @param {Object} obj
    @return {BaseModel} model
    ###
    createFromObject: (obj) ->

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

        return @afterCreateModel model


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

        propertyInfo = @getModelClass().properties

        if typeInfo = @modelProperties[prop]

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



    ###*
    create plain object without relational models

    FIXME: this method should not be in "factory"

    @method stripRelations
    @param {Entity|Object} data
    @return {Object} strippedData data without relational models
    ###
    stripRelations: (data) ->

        strippedData = {}

        for own key, value of data
            # exclude model properties
            if @modelProperties[key]?
                continue
            strippedData[key] = value

        return strippedData




module.exports = BaseFactory
