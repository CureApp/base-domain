

Base  = require './base'
Entity = require './entity'

###*
Base repository class of DDD pattern.
Responsible for perpetuation of models.
BaseSyncRepository has a sync client, which access to data resource.
Sync client accesses to resources synchronously.

@class BaseSyncRepository
@extends Base
@module base-domain
###
class BaseSyncRepository extends Base

    ###*
    model name to handle

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: null



    ###*
    sync client accessing to data resource

    mock object is input by default.
    Extenders must set this property to achieve perpetuation

    @property client
    @abstract
    @protected
    @type SyncResourceClientInterface
    ###
    client: null


    ###*
    constructor

    @constructor
    @return
    ###
    constructor: ->
        modelName = @constructor.modelName ? @constructor.getName().slice(0, -'-repository'.length)

        facade = @getFacade()

        useAnonymousFactory = on
        @factory = facade.createFactory(modelName, useAnonymousFactory)


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Class}
    ###
    getModelClass: ->
        modelName = @constructor.modelName ? @constructor.getName().slice(0, -'-repository'.length)
        @getFacade().getModel(modelName)



    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {SyncResourceClientInterface} [client=@client]
    @return {Entity} entity (the same instance from input, if entity given,)
    ###
    save: (entity, client) ->
        if entity not instanceof Entity
            entity = @factory.createFromObject entity

        client ?= @client

        # set "createdAt-compatible property when id is not set
        data = entity.toPlainObject()
        @appendTimeStamp(data)

        obj = client.upsert(data)
        newEntity = @factory.createFromObject(obj)
        return entity.inherit newEntity


    ###*
    get object by ID.

    @method get
    @public
    @param {any} id
    @param {SyncResourceClientInterface} [client=@client]
    @return {Entity} entity
    ###
    get: (id, client) ->
        client ?= @client
        obj = client.findById(id)
        return @factory.createFromObject(obj)


    ###*
    alias for get()

    @method getById
    @public
    @param {any} id
    @param {SyncResourceClientInterface} [client=@client]
    @return {Entity} entity
    ###
    getById: (id, client) ->
        @get(id, client)


    ###*
    alias for get()

    @method getByIdSync
    @public
    @param {any} id
    @param {SyncResourceClientInterface} [client=@client]
    @return {Entity} entity
    ###
    getByIdSync: (id, client) ->
        @get(id, client)


    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @param {SyncResourceClientInterface} [client=@client]
    @return {Array(Entity)} array of entities
    ###
    query: (params, client) ->
        client ?= @client
        objs = client.find(params)
        return (@factory.createFromObject(obj) for obj in objs)


    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {SyncResourceClientInterface} [client=@client]
    @return {Entity} entity
    ###
    singleQuery: (params, client) ->
        client ?= @client
        obj = client.findOne(params)
        return @factory.createFromObject(obj)



    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {SyncResourceClientInterface} [client=@client]
    @return {Boolean} isDeleted
    ###
    delete: (entity, client) ->
        client ?= @client
        client.destroy(entity)
        return true


    ###*
    Update set of attributes.

    @method update
    @public
    @param {any} id id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {SyncResourceClientInterface} [client=@client]
    @return {Entity} updated entity
    ###
    update: (id, data, client) ->
        if data instanceof Entity
            throw @getFacade().error """
                update entity with BaseSyncRepository#update() is not allowed.
                use BaseSyncRepository#save(entity) instead
            """

        client ?= @client
        @appendTimeStamp(data, isUpdate = true)

        obj = client.updateAttributes(id, data)
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

        propCreatedAt = Model.getPropInfo().createdAt
        propUpdatedAt = Model.getPropInfo().updatedAt

        now = new Date().toISOString()

        if propCreatedAt and not isUpdate
            data[propCreatedAt] ?= now

        if propUpdatedAt
            data[propUpdatedAt] = now

        return data


module.exports = BaseSyncRepository
