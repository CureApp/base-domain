

Base  = require './base'
ResourceClientInterface = require './resource-client-interface'

###*
Base repository class of DDD pattern.
Responsible for perpetuation of models.
BaseRepository has a client, which access to data resource (RDB, NoSQL, memory, etc...)

the parent "Base" class just simply gives a @facade property.

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
    ###
    constructor: ->
        super()
        modelName = @constructor.modelName
        @factory = @facade.createFactory(modelName)


    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity} entity
    @return {Promise<Entity>} entity (different instance from input)
    ###
    save: (entity) ->
        @client.upsert(entity).then (obj) =>
            return @factory.createFromObject(obj)


    ###*
    get object by ID.

    @method get
    @public
    @param {any} id
    @return {Promise<Entity>} entity
    ###
    get: (id) ->
        @client.findById(entity).then (obj) =>
            return @factory.createFromObject(obj)



    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @return {Promise<Array>} array of entities
    ###
    query: (params) ->
        @client.find(params).then (objs) =>
            return (@factory.createFromObject(obj) for obj in objs)


    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @return {Promise<Entity>} entity
    ###
    singleQuery: (params) ->
        @client.findOne(params).then (obj) =>
            return @factory.createFromObject(obj)



    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @return {Promise<Boolean>} isDeleted
    ###
    delete: (entity) ->
        @client.destroyById(entity.id).then =>
            return true


    ###*
    Update set of attributes.

    @method update
    @public
    @param {any} id id of the entity to update
    @param {Object} data key-value pair to update
    @return {Promise<Entity>} updated entity
    ###
    update: (id, data) ->
        @client.updateAttributes(id, data).then (obj) =>
            return @factory.createFromObject(obj)


module.exports = BaseRepository
