
###*
sync memory storage

@class MemoryResource
@implements SyncResourceClientInterface
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
        @pool[data.id] = data
        return data


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
        @pool[id]




    ###*
    Find all model instances that match filter specification.

    @method find
    @public
    @param {Object} filter
    @return {Array(Object)}
    ###
    find: (filter) ->
        throw new Error '"find" method is unimplemented.'

    ###*
    Find one model instance that matches filter specification. Same as find, but limited to one result

    @method findOne
    @public
    @param {Object} filter
    @return {Object}
    ###
    findOne: (filter) ->
        throw new Error '"findOne" method is unimplemented.'


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

        return pooledData


module.exports = MemoryResource
