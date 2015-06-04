

Base  = require './base'

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
    @_ModelClass: undefined
    getModelClass: ->
        @_ModelClass ?= @getFacade().getModel(@constructor.modelName)


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

        model = new ModelClass()
        model[prop] ?= undefined for prop in ModelClass.getPropInfo().list

        for own prop, value of obj

            @setValueToModel model, prop, value

        # check idPropName
        for relModelProp in ModelClass.getModelProps()
            continue if model[relModelProp]

            typeInfo = model.getTypeInfo(relModelProp)

            if @getFacade().getModel(typeInfo.model).isEntity

                @fetchEntityProp(model, relModelProp)

        return @afterCreateModel model


    ###*
    fetch submodel(s) by id
    available only when repository of submodel implements 'getByIdSync'
    (MasterRepository implements one)

    @method fetchEntityProp
    @private
    ###
    fetchEntityProp: (model, prop) ->

        typeInfo = model.getTypeInfo(prop)

        idPropName = typeInfo.idPropName

        try
            Repository = @getFacade().getRepository typeInfo.model
            return if not Repository.storeMasterTable

            repository = new Repository()
            return if not repository.getByIdSync
        catch e
            return

        if typeInfo.equals 'MODELS'

            ids = model[idPropName]
            return if not Array.isArray ids

            subModels = []
            for id in ids
                subModel = repository.getByIdSync(id)
                return if not subModel # TODO: throws 'invalid id' error?
                subModels.push subModel

            model.setEntityProps(prop, subModels)

        else # if typeInfo.equals 'MODEL'

            id = model[idPropName]
            subModel = repository.getByIdSync(id)
            model.setEntityProp(prop, subModel) if subModel


    ###*
    set value to model in creation

    @method setValueToModel
    @private
    ###
    setValueToModel: (model, prop, value) ->

        typeInfo = model.getTypeInfo(prop)

        switch typeInfo?.name

            when 'MODELS'
                @setSubModelArrToModel(model, prop, value)

            when 'MODEL'
                @setSubModelToModel(model, prop, value)

            else
                # set normal props
                model.setNonEntityProp(prop, value)


    ###*
    set submodels (array) to the prop

    @method setSubModelArrToModel
    @private
    ###
    setSubModelArrToModel: (model, prop, arr) ->
        if not Array.isArray arr
            model.setNonEntityProp(prop, arr)
            return

        subModelName = model.getTypeInfo(prop).model

        useAnonymousFactory = on # if no factory is declared, altered one is used 
        subModelFactory = @getFacade().createFactory(subModelName, useAnonymousFactory)

        SubModel = subModelFactory.getModelClass()

        subModels = (for subObj in arr
            if subObj instanceof SubModel
                subObj
            else
                subModelFactory.createFromObject(subObj)
        )

        if SubModel.isEntity
            model.setEntityProps(prop, subModels)

        else
            model.setNonEntityProp(prop, subModels)

        return


    ###*
    set submodel to the prop

    @method setSubModelToModel
    @private
    ###
    setSubModelToModel: (model, prop, value) ->

        subModelName = model.getTypeInfo(prop).model

        useAnonymousFactory = on # if no factory is declared, altered one is used 
        subModelFactory = @getFacade().createFactory(subModelName, useAnonymousFactory)
        SubModel = subModelFactory.getModelClass()

        if value not instanceof SubModel
            value = subModelFactory.createFromObject(value)

        if SubModel.isEntity
            model.setEntityProps(prop, value)
        else
            model.setNonEntityProps(prop, value)

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
