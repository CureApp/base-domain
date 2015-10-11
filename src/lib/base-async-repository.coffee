

BaseRepository = require './base-repository'

###*
async repository
@class BaseAsyncRepository
@extends BaseRepository
@module base-domain
###
class BaseAsyncRepository extends BaseRepository

    @isSync: false

    ###*
    returns Promise

    @return {Promise}
    @protected
    ###
    resolve: (result, fn) ->

        return Promise.resolve(result).then (obj) => fn.call(@, obj)


    ###*
    get entities by ID.

    @method getByIds
    @public
    @param {Array} ids
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Array(Entity))} entities
    ###
    getByIds: (ids, client) ->

        Promise.all (@get(id, client) for id in ids)


    # following are all comments, for yuidoc

    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Entity)} entity (the same instance from input, if entity given,)
    ###

    ###*
    get object by ID.

    @method get
    @public
    @param {any} id
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Entity)} entity
    ###

    ###*
    alias for get()

    @method getById
    @public
    @param {any} id
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Entity)} entity
    ###

    ###*
    get all entities

    @method getAll
    @return {Promise(Array(Entity))} array of entities
    ###

    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Array(Entity))} array of entities
    ###

    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Entity)} entity
    ###

    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Boolean)} isDeleted
    ###

    ###*
    Update set of attributes.

    @method update
    @public
    @param {any} id id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Entity)} updated entity
    ###

module.exports = BaseAsyncRepository
