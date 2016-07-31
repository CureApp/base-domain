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

        ModelClass = @model.constructor
        @modelProps = @model.facade.getModelProps(ModelClass.getName())

        { @syncs, @asyncs, @repos } = @splitEntityProps()


    splitEntityProps: ->
        repos = {}
        syncs = []
        asyncs = []

        entityProps = @modelProps.getEntityProps()
        if @options.props
            entityProps = (p for p in entityProps when p in @options.props)

        for entityProp in entityProps when @isNotIncludedProp(entityProp)
            subModelName = @modelProps.getSubModelName(entityProp)
            repo = @createPreferredRepository(subModelName)
            repos[entityProp] = repo
            if repo.constructor.isSync
                syncs.push entityProp
            else
                asyncs.push entityProp

        return { syncs: syncs, asyncs: asyncs, repos: repos }



    ###*
    include sub entities

    @method include
    @public
    @return {Promise}
    ###
    include: (createNew = false) ->
        if @model.constructor.isEntity
            modelName = @model.constructor.getName()
            if @entityPool.get(modelName, @model.id)
                return Promise.resolve(@model)
            @entityPool.set(@model)

        model = @includeSync(createNew)
        if not @options.async or @asyncs.length is 0
            return Promise.resolve(model)

        # if already frozen
        if @model.constructor.isImmutable and not createNew and Object.isFrozen(@model)
            console.error('frozen model.')
            return Promise.resolve(model)

        newAsyncProps = {}
        promises = @asyncs.map (prop) =>
            @getSubModel(prop, true).then (subModel) =>
                return if not subModel?
                @entityPool.set(subModel)
                newAsyncProps[prop] = subModel

        return Promise.all(promises).then => @applyNewProps(newAsyncProps, createNew)


    getSubModel: (prop, isAsync) ->
        subIdProp = @modelProps.getIdPropByEntityProp(prop)
        subModelName = @modelProps.getSubModelName(prop)
        subId = @model[subIdProp]

        if subModel = @entityPool.get(subModelName, subId)
            return if isAsync then Promise.resolve(subModel) else subModel

        return @repos[prop].get(@model[subIdProp], include: @options)


    includeSync: (createNew = false) ->
        newProps = {}
        @syncs.forEach (prop) =>
            subModel = @getSubModel(prop, false)
            return if not subModel?
            @entityPool.set(subModel)
            newProps[prop] = subModel

        return @applyNewProps(newProps, createNew)


    isNotIncludedProp: (entityProp) ->
        subIdProp = @modelProps.getIdPropByEntityProp(entityProp)
        return not @model[entityProp]? && @model[subIdProp]?



    applyNewProps: (newProps, createNew) ->
        if createNew
            return @model.$set(newProps)
        else
            return @model.set(newProps)


    createPreferredRepository: (modelName) ->

        options = {}

        if Array.isArray(@options.noParentRepos) and modelName in @options.noParentRepos
            options.noParent ?= true

        try
            return @model.root.createPreferredRepository(modelName, options)
        catch e
            return null


module.exports = Includer
