
###*
general factory class

create instance of model

@class GeneralFactory
@module base-domain
###
class GeneralFactory


    ###*
    constructor

    @constructor
    @param {String} modelName
    @param {Facade} facade
    ###
    constructor: (@modelName, @facade) ->


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Function}
    ###
    getModelClass: ->
        @facade.getModel(@modelName)


    ###*
    create empty model instance

    @method createEmpty
    @public
    @return {BaseModel}
    ###
    createEmpty: -> @createFromObject({})

    ###*
    create instance of model class by plain object

    for each prop, values are set by Model#set(prop, value)

    @method createFromObject
    @public
    @param {Object} obj
    @param {Object} [options={}]
    @param {Object} [options.include] options to pass to Includer
    @param {Object} [options.include.async=false] include submodels asynchronously
    @param {Boolean} [options.include.recursive=false] recursively include or not
    @param {Array(String)} [options.include.props] include submodels of given props
    @return {BaseModel} model
    ###
    createFromObject: (obj, options = {}) ->

        ModelClass = @getModelClass()

        return obj if obj instanceof ModelClass

        if not obj? or typeof obj isnt 'object'
            return null

        model = new ModelClass()

        for own prop, value of obj
            @setValueToModel model, prop, value

        propInfo = ModelClass.getPropInfo()

        for prop of propInfo.dic
            continue if model[prop]? or obj.hasOwnProperty prop
            @setEmptyValueToModel model, prop, propInfo

        @include(model, options.include)

        return model


    ###*
    include submodels

    @method include
    @private
    @param {BaseModel} model
    @param {Object} [includeOptions]
    @param {Object} [includeOptions.async=false] include submodels asynchronously
    @param {Boolean} [options.include.recursive=false] recursively include or not
    @param {Array(String)} [includeOptions.props] include submodels of given props
    ###
    include: (model, includeOptions = {}) ->

        includeOptions.async ?= false

        return if not includeOptions

        model.include includeOptions


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
                    return # if submodel is entity, load it at include() section

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
        subModelFactory = @facade.createFactory(subModelName)
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

        subModelFactory = @facade.createFactory(subModelName)
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
        subModelFactory = @facade.createFactory(subModelName)
        dictModelName = typeInfo.dictName

        dict = subModelFactory.createDict(dictModelName, value)

        model.setNonEntityProp prop, dict

        return


    ###*
    create empty non-entity model and set to the prop

    @method createEmptyNonEntityProp
    @private
    ###
    createEmptyNonEntityProp: (model, prop, typeInfo) ->

        factory = @facade.createFactory typeInfo.model
        submodel = factory.createEmpty()
        model.setNonEntityProp(prop, submodel)


    ###*
    create model list

    @method createList
    @public
    @param {String} listModelName model name of list
    @param {any} val
    @return {BaseList} list
    ###
    createList: (listModelName, val) ->

        @createCollection listModelName, val 


    ###*
    create model dict

    @method createDict
    @public
    @param {String} dictModelName model name of dict
    @param {any} val 
    @return {BaseDict} dict
    ###
    createDict: (dictModelName, val) ->

        @createCollection dictModelName, val


    ###*
    create collection

    @method createCollection
    @private
    @param {String} collModelName model name of collection
    @param {any} val 
    @return {BaseDict} dict
    ###
    createCollection: (collModelName, val) ->

        return null if val is null

        CollectionFactory = require './collection-factory'

        new CollectionFactory(collModelName, @facade).createFromObject val


module.exports = GeneralFactory
