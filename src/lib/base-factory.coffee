

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
        @createFromObject({})


    ###*
    create instance of model class by plain object

    for each prop, values are set by Model#set(prop, value)

    @method createFromObject
    @public
    @param {Object} obj
    @param {BaseModel} baseModel fallback properties
    @return {BaseModel} model
    ###
    createFromObject: (obj) ->

        obj = @beforeCreateFromObject obj

        if not obj? or typeof obj isnt 'object'
            return null


        ModelClass = @getModelClass()

        propInfo = ModelClass.getPropertyInfo()
        facade = @getFacade()

        model = new ModelClass()
        model[prop] ?= undefined for prop of ModelClass.properties

        for own prop, value of obj

            typeInfo = propInfo[prop]

            # creates submodels
            if typeInfo?.model

                subModelFactory = facade.createFactory(typeInfo.model)
                SubModel = subModelFactory.getModelClass()

                # if prop is array of models
                if typeInfo.name is 'MODELS' and Array.isArray value
                    subModels = (for subObj in value
                        if subObj instanceof SubModel
                            subObj
                        else
                            subModelFactory.createFromObject(subObj)
                    )
                    model.setRelatedModels(prop, subModels)
                    continue

                # if prop is model
                else if typeInfo.name is 'MODEL'
                    if value instanceof SubModel
                        model.setRelatedModel(prop, value)

                    else
                        subModel = subModelFactory.createFromObject(value)
                        model.setRelatedModel(prop, subModel)
                    continue
            else
                model.setNonModelProp(prop, value)

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



module.exports = BaseFactory
