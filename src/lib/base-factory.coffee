

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

        model = new ModelClass()
        model[prop] ?= undefined for prop of ModelClass.properties

        for own prop, value of obj

            typeInfo = propInfo[prop]
            @setValueToModel model, prop, value, typeInfo

        # check idPropName
        for relModelProp in ModelClass.getModelProps()

            typeInfo = propInfo[relModelProp]
            if not model[relModelProp]? and ModelClass.isEntity
                @fetchSubModel(model, relModelProp, typeInfo)

        return @afterCreateModel model


    ###*
    fetch submodel(s) by id
    available only when repository of submodel implements 'getByIdSync'
    (MasterRepository implements one)

    @method fetchSubModel
    @private
    ###
    fetchSubModel: (model, prop, typeInfo) ->

        idPropName = typeInfo.idPropName

        try
            repository = @getFacade().createRepository typeInfo.model
        catch e
            return

        return if not repository.getByIdSync

        if typeInfo.name is 'MODELS'

            ids = model[idPropName]
            return if not Array.isArray ids

            subModels = []
            for id in ids
                subModel = repository.getByIdSync(id)
                return if not subModel # TODO: throws 'invalid id' error?
                subModels.push subModel

            model.setRelatedModels(prop, subModels)

        else # if typeInfo.name is 'MODEL'

            id = model[idPropName]
            subModel = repository.getByIdSync(id)
            model.setRelatedModel(prop, subModel) if subModel


    ###*
    set value to model in creation

    @method setValueToModel
    @private
    ###
    setValueToModel: (model, prop, value, typeInfo) ->

        if subModelName = typeInfo?.model

            # creates submodels
            if typeInfo.name is 'MODELS' and Array.isArray value
                @setSubModelArrToModel(model, prop, value, subModelName)
                return

            # creates submodel
            if typeInfo.name is 'MODEL'
                @setSubModelToModel(model, prop, value, subModelName)
                return


        # set normal props
        model.setNonModelProp(prop, value)
        return



    ###*
    set submodels (array) to the prop

    @method setSubModelArrToModel
    @private
    ###
    setSubModelArrToModel: (model, prop, arr, subModelName) ->

        subModelFactory = @getFacade().createFactory(subModelName)

        SubModel = subModelFactory.getModelClass()

        subModels = (for subObj in arr
            if subObj instanceof SubModel
                subObj
            else
                subModelFactory.createFromObject(subObj)
        )

        model.setRelatedModels(prop, subModels)

        return



    ###*
    set submodel to the prop

    @method setSubModelToModel
    @private
    ###
    setSubModelToModel: (model, prop, value, subModelName) ->

        subModelFactory = @getFacade().createFactory(subModelName)
        SubModel = subModelFactory.getModelClass()

        if value instanceof SubModel
            model.setRelatedModel(prop, value)

        else
            subModel = subModelFactory.createFromObject(value)
            model.setRelatedModel(prop, subModel)

        return




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
