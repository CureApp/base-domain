

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
    name of dict model to create dict of @modelName

    @property dictModelName
    @static
    @protected
    @type String
    ###
    @dictModelName: null


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
    @return {Function}
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
    createEmpty: -> @createFromObject({})

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

        propInfo = ModelClass.getPropInfo()

        for prop of propInfo.dic
            continue if model[prop]? or obj.hasOwnProperty prop
            @setEmptyValueToModel model, prop, propInfo

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

            when 'MODEL_DICT'
                @setSubModelDictToModel(model, prop, value)

            else # set normal props
                model.setNonEntityProp(prop, value)


    ###*
    set empty values to model in creation

    @method setEmptyValueToModel
    @private
    ###
    setEmptyValueToModel: (model, prop, propInfo) ->

        typeInfo = propInfo.getTypeInfo(prop)

        switch typeInfo.name

            when 'MODEL'
                if propInfo.isEntityProp(prop)
                    @fetchEntityProp(model, prop, typeInfo) # trying to get entity by id

                else
                    @createEmptyNonEntityProp(model, prop, typeInfo)

            when 'MODEL_LIST'
                @setSubModelListToModel(model, prop, [])

            when 'MODEL_DICT'
                @setSubModelDictToModel(model, prop, {})

            else
                model[prop] = undefined



    ###*
    creates list and set it to the model

    @method setSubModelListToModel
    @private
    ###
    setSubModelListToModel: (model, prop, value) ->

        typeInfo = model.getTypeInfo(prop)
        subModelName = typeInfo.model
        subModelFactory = @getFacade().createFactory(subModelName, on)
        listModelName = typeInfo.listName

        list = subModelFactory.createList(listModelName, value)

        model.setNonEntityProp prop, list

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
    set submodel dict to the prop

    @method setSubModelToModel
    @private
    ###
    setSubModelDictToModel: (model, prop, value) ->

        typeInfo = model.getTypeInfo(prop)
        subModelName = typeInfo.model
        subModelFactory = @getFacade().createFactory(subModelName, on)
        dictModelName = typeInfo.dictName

        dict = subModelFactory.createDict(dictModelName, value)

        model.setNonEntityProp prop, dict

        return


    ###*
    fetch submodel(s) by id
    available only when repository of submodel implements 'getByIdSync'
    (MasterRepository implements one)

    @method fetchEntityProp
    @private
    ###
    fetchEntityProp: (model, prop, typeInfo) ->

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
    create empty non-entity model and set to the prop

    @method createEmptyNonEntityProp
    @private
    ###
    createEmptyNonEntityProp: (model, prop, typeInfo) ->

        factory = @getFacade().createFactory typeInfo.model, true
        submodel = factory.createEmpty()
        model.setNonEntityProp(prop, submodel)


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
    create model list

    @method createList
    @public
    @param {String} listModelName model name of list
    @param {any} obj
    @return {BaseList} list
    ###
    createList: (listModelName, obj) ->

        return null if obj is null

        ListFactory = @getFacade().constructor.ListFactory

        listFactory = ListFactory.create(listModelName, @)
        return listFactory.createFromObject obj


    ###*
    create model dict

    @method createDict
    @public
    @param {String} dictModelName model name of dict
    @param {any} obj
    @return {BaseDict} dict
    ###
    createDict: (dictModelName, obj) ->

        return null if obj is null

        DictFactory = @getFacade().constructor.DictFactory

        dictFactory = DictFactory.create(dictModelName, @)
        return dictFactory.createFromObject obj


module.exports = BaseFactory
