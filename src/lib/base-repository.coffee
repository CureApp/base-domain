

Base  = require './base'
Entity = require './entity'

###*
Base repository class of DDD pattern.
Responsible for perpetuation of models.
BaseRepository has a client, which access to data resource (RDB, NoSQL, memory, etc...)

the parent "Base" class just simply gives a @getFacade() method.

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
    @params {ResourceClientInterface} client
    @params {RootInterface} root
    @return
    ###
    constructor: (root) ->

        super(root)

        modelName = @constructor.modelName ? @constructor.getName().slice(0, -'-repository'.length)

        @factory = @root.createFactory(modelName)


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

        if result instanceof Promise
            return result.then (obj) => fn.call(@, obj)

        else
            return fn.call(@, result)


    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Entity|Promise(Entity)} entity (the same instance from input, if entity given,)
    ###
    save: (entity, client) ->
        if entity not instanceof Entity
            entity = @factory.createFromObject entity

        client ?= @client

        # set "createdAt-compatible property when id is not set
        data = entity.toPlainObject()
        @appendTimeStamp(data)

        @resolve client.upsert(data), (obj) ->

            newEntity = @factory.createFromObject(obj)
            entity.inherit newEntity


    ###*
    get entity by id.

    @method get
    @public
    @param {String|Number} id
    @param {ResourceClientInterface} [client=@client]
    @return {Entity|Promise(Entity)} entity
    ###
    get: (id, client) ->
        client ?= @client
        @resolve client.findById(id), (obj) ->
            return @factory.createFromObject(obj)


    ###*
    alias for get()

    @method getById
    @public
    @param {String|Number} id
    @param {ResourceClientInterface} [client=@client]
    @return {Entity|Promise(Entity)} entity
    ###
    getById: (id, client) ->
        @get(id, client)



    ###*
    get entities by id.

    @method getByIds
    @public
    @param {Array|(String|Number)} ids
    @param {ResourceClientInterface} [client=@client]
    @return {Array(Entity)|Promise(Array(Entity))} entities
    ###
    getByIds: (ids, client) ->

        results = (@get(id, client) for id in ids)

        existence = (val) -> val?

        if results[0] instanceof Promise
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
    @param {ResourceClientInterface} [client=@client]
    @return {Array(Entity)|Promise(Array(Entity))} array of entities
    ###
    query: (params, client) ->
        client ?= @client
        @resolve client.find(params), (objs) ->
            return (@factory.createFromObject(obj) for obj in objs)


    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Entity|Promise(Entity)} entity
    ###
    singleQuery: (params, client) ->
        client ?= @client
        @resolve client.findOne(params), (obj) ->
            return @factory.createFromObject(obj)



    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Boolean|Promise(Boolean)} isDeleted
    ###
    delete: (entity, client) ->
        client ?= @client
        @resolve client.destroy(entity), ->
            return true


    ###*
    Update set of attributes.

    @method update
    @public
    @param {String|Number} id id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {ResourceClientInterface} [client=@client]
    @return {Entity|Promise(Entity)} updated entity
    ###
    update: (id, data, client) ->
        if data instanceof Entity
            throw @error 'base-domain:updateWithModelInhihited', """
                update entity with BaseRepository#update() is not allowed.
                use BaseRepository#save(entity) instead
            """

        client ?= @client
        @appendTimeStamp(data, isUpdate = true)

        @resolve client.updateAttributes(id, data), (obj) ->
            return @factory.createFromObject(obj)


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
        Model = @getModelClass()

        propCreatedAt = Model.getModelProps().createdAt
        propUpdatedAt = Model.getModelProps().updatedAt

        now = new Date().toISOString()

        if propCreatedAt and not isUpdate
            data[propCreatedAt] ?= now

        if propUpdatedAt
            data[propUpdatedAt] = now

        return data


module.exports = BaseRepository
