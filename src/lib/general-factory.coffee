
###*
general factory class

create instance of model

@class GeneralFactory
@implements FactoryInterface
@module base-domain
###
class GeneralFactory



    ###*
    create a factory.
    If specific factory is defined, return the instance.
    Otherwise, return instance of GeneralFactory.

    @method create
    @static
    @param {String} modelName
    @param {RootInterface} root
    @return {FactoryInterface}
    ###
    @create: (modelName, root) ->

        try
            root.createFactory(modelName)

        catch e
            return new GeneralFactory(modelName, root)



    ###*
    constructor

    @constructor
    @param {String} modelName
    @param {RootInterface} root 
    ###
    constructor: (@modelName, @root) ->
        @modelProps = @getModelClass().getModelProps()


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Function}
    ###
    getModelClass: ->
        @root.getModel(@modelName)


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

        model = @create()

        for own prop, value of obj
            @setValueToModel model, prop, value

        for prop in @modelProps.names()
            continue if model[prop]? or obj.hasOwnProperty prop
            @setEmptyValueToModel model, prop

        if options.include isnt null # skip @include when null is set. By default it's undefined, so @include will be executed
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

        switch @modelProps.getTypeInfo(prop)?.name

            when 'MODEL'
                model.set(prop, @createSubModel(prop, value))

            when 'MODEL_LIST', 'MODEL_DICT'
                model.set(prop, @createSubCollection(prop, value))

            else # set normal props
                model.set(prop, value)


    ###*
    set empty values to model in creation

    @method setEmptyValueToModel
    @private
    ###
    setEmptyValueToModel: (model, prop) ->

        switch @modelProps.getTypeInfo(prop).name

            when 'MODEL'
                if @modelProps.isEntity(prop)
                    return # if submodel is entity, load it at include() section

                else
                    model.set(prop, @createEmptyModel(prop))

            when 'MODEL_LIST', 'MODEL_DICT'
                model.set(prop, @createSubCollection(prop, []))

            else
                model.set(prop, undefined)


    ###*
    create collection by prop name and value

    @method createSubCollection
    @private
    @return {Collection}
    ###
    createSubCollection: (prop, value) ->

        typeInfo = @modelProps.getTypeInfo(prop)
        itemModelFactory = @constructor.create(typeInfo.itemModel, @root)

        return itemModelFactory.createCollection(typeInfo.model, value)


    ###*
    create submodel by prop name and value

    @method createSubModel
    @private
    ###
    createSubModel: (prop, value) ->

        subModelFactory = @constructor.create(@modelProps.getTypeInfo(prop).model, @root)
        SubModel = subModelFactory.getModelClass()

        return value if value instanceof SubModel

        return subModelFactory.createFromObject(value)


    ###*
    create empty model and set to the prop

    @method createEmptyModel
    @private
    ###
    createEmptyModel: (prop) ->

        typeInfo = @modelProps.getTypeInfo(prop)

        @constructor.create(typeInfo.model, @root).createEmpty()


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
    @public
    @param {String} collModelName model name of collection
    @param {any} val 
    @return {BaseDict} dict
    ###
    createCollection: (collModelName, val) ->

        return null if val is null

        CollectionFactory = require './collection-factory'

        new CollectionFactory(collModelName, @root).createFromObject val


    ###*
    create an empty model

    @protected
    @return {BaseModel}
    ###
    create: ->
        Model = @getModelClass()
        return new Model(null, @root)


module.exports = GeneralFactory
