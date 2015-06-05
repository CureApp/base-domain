

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
    get anonymous factory class

    @method getAnonymousClass
    @param {String} modelName
    @return {Function}
    ###
    @getAnonymousClass: (modelName) ->

        class AnonymousFactory extends BaseFactory
            @modelName  : modelName
            @isAnonymous: true

        return AnonymousFactory


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

        ModelClass = @getModelClass()

        return obj if obj instanceof ModelClass

        obj = @beforeCreateFromObject obj

        if not obj? or typeof obj isnt 'object'
            return null


        model = new ModelClass()

        for own prop, value of obj

            @setValueToModel model, prop, value

        # check idPropName
        for entityProp in ModelClass.getEntityProps()
            continue if model[entityProp]

            typeInfo = model.getTypeInfo(entityProp)
            @fetchEntityProp(model, entityProp)

        return @afterCreateModel model


    ###*
    set value to model in creation

    @method setValueToModel
    @private
    ###
    setValueToModel: (model, prop, value) ->

        typeInfo = model.getTypeInfo(prop)

        switch typeInfo?.name

            when 'MODEL_LIST'
                @setSubModelListToModel(model, prop, value)

            when 'MODEL'
                @setSubModelToModel(model, prop, value)

            else
                # set normal props
                model.setNonEntityProp(prop, value)



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

        id = model[idPropName]
        subModel = repository.getByIdSync(id)
        model.setEntityProp(prop, subModel) if subModel


    ###*
    creates list and set it to the model

    @method setSubModelListToModel
    @private
    ###
    setSubModelListToModel: (model, prop, arr) ->

        typeInfo = model.getTypeInfo(prop)

        listFactory = @getFacade().createListFactory typeInfo.listName, typeInfo.model

        list = listFactory.createList(arr)

        model.setNonEntityProp(prop, list)

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
            model.setEntityProp(prop, value)
        else
            model.setNonEntityProp(prop, value)

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
