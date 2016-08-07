'use strict'

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
    @param {Array(String|Number)} ids
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Array(Entity))} entities
    ###
    getByIds: (ids, options) ->

        Promise.all((@get(id, options) for id in ids)).then (models) ->
            models.filter (model) -> model?


    # following are all comments, for yuidoc

    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Entity)} entity (the same instance from input, if entity given,)
    ###

    ###*
    get object by id.

    @method get
    @public
    @param {String|Number} id
    @param {ResourceClientInterface} [client=@client]
    @return {Promise(Entity)} entity
    ###

    ###*
    alias for get()

    @method getById
    @public
    @param {String|Number} id
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Entity)} entity
    ###

    ###*
    get diff from perpetuation layer

    @method getDiff
    @public
    @param {Entity} entity
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Object)} diff
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
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
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
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Boolean)} isDeleted
    ###

    ###*
    Update set of attributes.

    @method update
    @public
    @param {String|Number} id of the entity to update
    @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Entity)} updated entity
    ###

    ###*
    Update set of attributes and returns newly-updated props (other than `props`)

    @method updateProps
    @public
    @param {Entity} entity
    @param {Object} props key-value pair to update (notice: this must not be instance of Entity)
    @param {Object} [options]
    @param {ResourceClientInterface} [options.client=@client]
    @return {Promise(Object)} updated props
    ###
module.exports = BaseAsyncRepository
