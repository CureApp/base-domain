
BaseModel = require './base-model'
EntityPool = require '../entity-pool'

###*
include submodels

@class Includer
@module base-domain
###
class Includer

    ###*
    @constructor
    @param {Object} options
    @param {Boolean} [options.async=true] get async values
    @param {Boolean} [options.recursive=false] recursively include or not
    @param {Boolean} [options.entityPool] entityPool, to detect circular references
    @param {Array(String)} [options.props] include only given props
    ###
    constructor: (@model, @options = {}) ->

        if not @options.entityPool?
            @entityPoolCreated = true
            @options.entityPool = new EntityPool

        { @entityPool } = @options

        @options.async ?= true

        @facade = @model.getFacade()

        @ModelClass = @model.constructor
        @modelProps = @facade.getModelProps(@ModelClass.getName())

        { @root } = @model

        @entityPool.set(@model) if @ModelClass.isEntity


    ###*
    include sub entities

    @method include
    @public
    @return {Promise}
    ###
    include: ->

        entityProps = @modelProps.entities

        if @options.props
            entityProps = (p for p in entityProps when p in @options.props)


        promises = []

        for entityProp in entityProps when not @model[entityProp]?

            subModelPromise = @setSubEntity(entityProp)

            promises.push subModelPromise if subModelPromise

        Promise.all(promises).then =>

            if @options.recursive
                return @doRecursively()

            if @entityPoolCreated
                @entityPool.clear()

            return @model


    ###*
    run include for each submodel

    @method doRecursively
    @private
    @return {Promise}
    ###
    doRecursively: ->

        promises = []

        for modelProp in @modelProps.models

            subModel = @model[modelProp]

            continue if subModel not instanceof BaseModel
            continue if subModel.included()

            includer = new Includer(subModel, @options)
            promises.push includer.include()

        return Promise.all(promises).then =>
            if @entityPoolCreated
                @entityPool.clear()
            return @model


    ###*
    load entity by entityProp and set it to @model

    @method setSubEntity
    @private
    @param {String} entityProp
    @return {Promise}
    ###
    setSubEntity: (entityProp) ->

        typeInfo = @modelProps.getTypeInfo entityProp

        subId = @model[typeInfo.idPropName]

        return if not subId?

        if subModel = @entityPool.get(typeInfo.model, subId)
            @model.set(entityProp, subModel)
            return

        repo = @createRepository(typeInfo.model)

        return if not repo?

        if repo.constructor.isSync
            subModel = repo.get(subId, include: @options)
            @model.set(entityProp, subModel) if subModel?
            return Promise.resolve subModel

        else
            return unless @options.async

            return repo.get(subId, include: @options).then (subModel) =>
                @model.set(entityProp, subModel)
            .catch (e) ->



    ###*
    Get instance of repository.
    If not found, checks parent class's repository

    @method createRepository
    @return {BaseRepository}
    ###
    createRepository: (modelName) ->

        loop
            try
                return @root.createRepository(modelName)

            catch e
                ParentClass = @facade.getModel(modelName).getCustomParent()

                return null if not ParentClass?

                modelName = ParentClass.getName()


module.exports = Includer
