

Base  = require './base'
ResourceClientInterface = require './resource-client-interface'

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
    client: new ResourceClientInterface()


    ###*
    constructor

    @constructor
    @param {Object} [options]
    @return
    ###
    constructor: (options) ->
        modelName = @constructor.modelName
        @factory = @getFacade().createFactory(modelName)


    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Promise<Entity>} entity (different instance from input)
    ###
    save: (entity, client) ->
        client ?= @client

        dataForSave = @createDataForSave(entity)

        client.upsert(dataForSave).then (obj) =>
            return @factory.createFromObject(obj, entity)

    ###*
    get object by ID.

    @method get
    @public
    @param {any} id
    @param {ResourceClientInterface} [client=@client]
    @return {Promise<Entity>} entity
    ###
    get: (id, client) ->
        client ?= @client
        client.findById(id).then (obj) =>
            return @factory.createFromObject(obj)



    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Promise<Array>} array of entities
    ###
    query: (params, client) ->
        client ?= @client
        client.find(params).then (objs) =>
            return (@factory.createFromObject(obj) for obj in objs)


    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {ResourceClientInterface} [client=@client]
    @return {Promise<Entity>} entity
    ###
    singleQuery: (params, client) ->
        client ?= @client
        client.findOne(params).then (obj) =>
            return @factory.createFromObject(obj)



    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {ResourceClientInterface} [client=@client]
    @return {Promise<Boolean>} isDeleted
    ###
    delete: (entity, client) ->
        client ?= @client
        client.destroyById(entity.id).then =>
            return true


    ###*
    Update set of attributes.

    @method update
    @public
    @param {any} id id of the entity to update
    @param {Object} data key-value pair to update
    @param {ResourceClientInterface} [client=@client]
    @return {Promise<Entity>} updated entity
    ###
    update: (id, data, client) ->
        client ?= @client
        dataForSave = @createDataForSave(data)

        client.updateAttributes(id, dataForSave).then (obj) =>
            return @factory.createFromObject(obj)


    ###*
    create object for save: relational models excluded

    @method createDataForSave
    @protected
    @param {Entity|Object} data
    @return {Object} data data for save
    ###
    createDataForSave: (data) ->

        return @factory.stripRelations(data)


module.exports = BaseRepository
