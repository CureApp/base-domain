'use strict'

Base  = require './base'
Entity = require './entity'
GeneralFactory = require './general-factory'
{ isPromise } = require('../util')

###*
Base repository class of DDD pattern.
Responsible for perpetuation of models.
BaseRepository has a client, which access to data resource (RDB, NoSQL, memory, etc...)

the parent "Base" class just simply gives `this.facade` property

@class BaseRepository
@extends Base
@module base-domain
###
class BaseRepository extends Base

    ###*
    model name to handle

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: null


    getModelName: ->
        @constructor.modelName ? @constructor.getName().slice(0, -'-repository'.length)


    ###*
    client accessing to data resource (RDB, NoSQL, memory, etc...)

    mock object is input by default.
    Extenders must set this property to achieve perpetuation

    @property client
    @abstract
    @protected
    @type ResourceClientInterface
    ###
    client: null


    ###*
    constructor

    @constructor
    @params {RootInterface} root
    @return
    ###
    constructor: (root) ->

        super(root)

        modelName = @getModelName()

        ###*
        factory of the entity.

        @property {FactoryInterface} factory
        ###
        @factory = GeneralFactory.create(modelName, @root)

        if (@factory.getModelClass()::) not instanceof Entity
            @error('base-domain:repositoryWithNonEntity', "cannot define repository to non-entity: '#{modelName}'")


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Class}
    ###
    getModelClass: ->
        @factory.getModelClass()



    ###*
    returns Promise or the result of given function
    @return {any}
    @protected
    ###
    resolve: (result, fn) ->

        if isPromise result
            return result.then (obj) => fn.call(@, obj)

        else
            return fn.call(@, result)


    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Entity|Promise(Entity)} entity (the same instance from input, if entity given,)
    ###
    save: (entity, options = {}) ->
        { client } = options
        delete options.client

        if entity not instanceof Entity
            entity = @factory.createFromObject entity, options

        client ?= @client

        # set "createdAt-compatible property when id is not set
        data = entity.toPlainObject()
        @appendTimeStamp(data)

        method =
            switch options.method
                when 'upsert', 'create'
                    options.method
                else
                    'upsert'

        @resolve client[method](data), (obj) ->

            newEntity = @createFromResult(obj, options)
            if @getModelClass().isImmutable
                return newEntity
            else
                return entity.inherit newEntity


    ###*
    get entity by id.

    @method get
    @public
    @param {String|Number} id
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Entity|Promise(Entity)} entity
    ###
    get: (id, options = {}) ->

        { client } = options
        delete options.client

        client ?= @client
        @resolve client.findById(id), (obj) ->
            @createFromResult(obj, options)


    ###*
    alias for get()

    @method getById
    @public
    @param {String|Number} id
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Entity|Promise(Entity)} entity
    ###
    getById: (id, options) ->
        @get(id, options)



    ###*
    get entities by id.

    @method getByIds
    @public
    @param {Array|(String|Number)} ids
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Array(Entity)|Promise(Array(Entity))} entities
    ###
    getByIds: (ids, options) ->

        results = (@get(id, options) for id in ids)

        existence = (val) -> val?

        if isPromise results[0]
            return Promise.all(results).then (models) -> models.filter existence
        else
            return results.filter existence

    ###*
    get all entities

    @method getAll
    @return {Array(Entity)|Promise(Array(Entity))} array of entities
    ###
    getAll: ->
        @query({})


    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Array(Entity)|Promise(Array(Entity))} array of entities
    ###
    query: (params, options = {}) ->

        { client } = options
        delete options.client

        client ?= @client
        @resolve client.find(params), (objs) ->
            @createFromQueryResults(params, objs, options)


    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Entity|Promise(Entity)} entity
    ###
    singleQuery: (params, options = {}) ->

        { client } = options
        delete options.client

        client ?= @client
        @resolve client.findOne(params), (obj) ->
            return @createFromResult(obj, options)



    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Boolean|Promise(Boolean)} isDeleted
    ###
    delete: (entity, options = {}) ->

        { client } = options
        delete options.client

        client ?= @client
        @resolve client.destroy(entity), ->
            return true


    ###*
    Update set of attributes.

    @method update
    @public
    @param {String|Number} id id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Entity|Promise(Entity)} updated entity
    ###
    update: (id, data, options = {}) ->

        { client } = options
        delete options.client

        if data instanceof Entity
            throw @error 'base-domain:updateWithModelInhihited', """
                update entity with BaseRepository#update() is not allowed.
                use BaseRepository#save(entity) instead
            """

        client ?= @client
        @appendTimeStamp(data, isUpdate = true)

        @resolve client.updateAttributes(id, data), (obj) ->
            return @createFromResult(obj, options)


    ###*
    add createdAt, updatedAt to given data
    - createdAt will not be overriden if already set.
    - updatedAt will be overriden for each time

    @method appendTimeStamp
    @protected
    @param {Object} data
    @param {Boolean} isUpdate true when updating
    @return {Object} data
    ###
    appendTimeStamp: (data, isUpdate = false) ->
        modelProps = @facade.getModelProps(@getModelName())

        propCreatedAt = modelProps.createdAt
        propUpdatedAt = modelProps.updatedAt

        now = new Date().toISOString()

        if propCreatedAt and not isUpdate
            data[propCreatedAt] ?= now

        if propUpdatedAt
            data[propUpdatedAt] = now

        return data


    ###*
    Create model instance from result from client

    @method createFromResult
    @protected
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel} model
    ###
    createFromResult: (obj, options) ->
        @factory.createFromObject(obj, options)


    ###*
    Create model instances from query results

    @method createFromQueryResults
    @protected
    @param {Object} params
    @param {Array(Object)} objs
    @param {Object} [options]
    @return {Array(BaseModel)} models
    ###
    createFromQueryResults: (params, objs, options) ->

         (@createFromResult(obj, options) for obj in objs)

module.exports = BaseRepository
