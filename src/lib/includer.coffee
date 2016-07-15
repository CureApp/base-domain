'use strict'

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
    @param {Array(String)} [options.noParentRepos] array of modelNames which needs "noParent" option when calling root.createPreferredRepository()
    @param {Array(String)} [options.props] include only given props
    ###
    constructor: (@model, @options = {}) ->

        if not @options.entityPool?
            @entityPoolCreated = true
            @options.entityPool = new EntityPool

        { @entityPool } = @options

        @options.async ?= true

        @facade = @model.facade

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

        entityProps = @modelProps.getEntityProps()

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

        for modelProp in @modelProps.getSubModelProps()

            subModel = @model[modelProp]

            continue if subModel not instanceof BaseModel
            continue if subModel.included()

            promises.push subModel.include(@options)

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

        subIdProp = @modelProps.getIdPropByEntityProp(entityProp)

        subId = @model[subIdProp]

        return if not subId?

        subModelName = @modelProps.getSubModelName(entityProp)

        if subModel = @entityPool.get(subModelName, subId)
            @model.set(entityProp, subModel)
            return

        repo = @createPreferredRepository(subModelName)

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


    createPreferredRepository: (modelName) ->

        options = {}

        if Array.isArray(@options.noParentRepos) and modelName in @options.noParentRepos
            options.noParent ?= true

        try
            return @root.createPreferredRepository(modelName, options)
        catch e
            return null


module.exports = Includer
