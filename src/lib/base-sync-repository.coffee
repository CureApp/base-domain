

BaseRepository = require './base-repository'

###*
sync repository
@class BaseSyncRepository
@extends BaseRepository
@module base-domain
###
class BaseSyncRepository extends BaseRepository

    @isSync: true

    ###*
    returns the result of the function

    @return {any}
    @protected
    ###
    resolve: (result, fn) ->

        return fn.call(@, result)


    ###*
    get entities by ID.

    @method getByIds
    @public
    @param {Array(String|Number)} ids
    @param {ResourceClientInterface} [client=@client]
    @return {Array(Entity)} entities
    ###
    getByIds: (ids, client) ->

        (@get(id, client) for id in ids).filter (model) -> model?


    # following are all comments, for yuidoc

    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Entity} entity (the same instance from input, if entity given,)
    ###

    ###*
    get object by id.

    @method get
    @public
    @param {String|Number} id
    @param {ResourceClientInterface} [client=@client]
    @return {Entity} entity
    ###

    ###*
    alias for get()

    @method getById
    @public
    @param {String|Number} id
    @param {ResourceClientInterface} [client=@client]
    @return {Entity} entity
    ###

    ###*
    get all entities

    @method getAll
    @return {Array(Entity)} array of entities
    ###

    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Array(Entity)} array of entities
    ###

    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Entity|} entity
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
    @return {Boolean} isDeleted
    ###
    delete: (entity, client) ->
        client ?= @client
        @resolve client.destroy(entity), ->
            return true


    ###*
    Update set of attributes.

    @method update
    @public
    @param {String|Number} id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {ResourceClientInterface} [client=@client]
    @return {Entity} updated entity
    ###
    update: (id, data, client) ->
        if data instanceof Entity
            throw @getFacade().error """
                update entity with BaseRepository#update() is not allowed.
                use BaseRepository#save(entity) instead
            """

        client ?= @client
        @appendTimeStamp(data, isUpdate = true)

        @resolve client.updateAttributes(id, data), (obj) ->
            return @factory.createFromObject(obj)


module.exports = BaseSyncRepository
