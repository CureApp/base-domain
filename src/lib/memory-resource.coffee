
Util = require '../util'

###*
sync memory storage, implements ResourceClientInterface

@class MemoryResource
@implements ResourceClientInterface
###
class MemoryResource

    constructor: ->
        @currentIdNum = 1
        @pool = {}


    ###*
    Generate id

    @method create
    @public
    @param {Object} data
    @return {String}
    ###
    generateId: ->

        id = @currentIdNum

        while @pool[id]?
            id = ++@currentIdNum

        return id.toString()



    ###*
    Create new instance of Model class, saved in database

    @method create
    @public
    @param {Object} data
    @return {Object}
    ###
    create: (data = {}) ->
        data.id ?= @generateId()

        @pool[data.id] = Util.clone data


    ###*
    Update or insert a model instance
    The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.

    @method upsert
    @public
    @param {Object} data
    @return {Object}
    ###
    upsert: (data = {}) ->
        return @create data


    ###*
    Find object by ID.

    @method findById
    @public
    @param {String} id
    @return {Object}
    ###
    findById: (id) ->
        Util.clone @pool[id]




    ###*
    Find all model instances that match filter specification.

    @method find
    @public
    @param {Object} filter
    @return {Array(Object)}
    ###
    find: (filter = {}) ->

        { where } = filter

        return (Util.clone(obj) for id, obj of @pool) if not where

        throw new Error '"find" method with "where" is currently unimplemented.'

    ###*
    Find one model instance that matches filter specification. Same as find, but limited to one result

    @method findOne
    @public
    @param {Object} filter
    @return {Object}
    ###
    findOne: (filter) ->

        @find(filter)[0]



    ###*
    Destroy model instance

    @method destroyById
    @public
    @param {Object} data
    ###
    destroy: (data) ->
        delete @pool[data?.id]


    ###*
    Destroy model instance with the specified ID.

    @method destroyById
    @public
    @param {String} id
    ###
    destroyById: (id) ->
        delete @pool[id]


    ###*
    Update set of attributes.

    @method updateAttributes
    @public
    @param {Object} data
    @return {Object}
    ###
    updateAttributes: (id, data) ->
        pooledData = @pool[id]
        throw new Error("id #{id} is not found") if pooledData
            for k, v of data
                pooledData[k] = v

        @pool[id] = pooledData

        return Util.clone pooledData


module.exports = MemoryResource
