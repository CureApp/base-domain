
###*
interface of client accessing to resource synchronously.
Used in BaseSyncRepository

@class SyncResourceClientInterface
@module base-domain
###
class SyncResourceClientInterface

    constructor: (@memory) ->


    ###*
    Create new instance of Model class, saved in database

    @method create
    @public
    @param {Object} data
    @return {Object}
    ###
    create: (data = {}) ->
        @memory.create data


    ###*
    Update or insert a model instance
    The update will override any specified attributes in the request data object. It won’t remove  existing ones unless the value is set to null.

    @method upsert
    @public
    @param {Object} data
    @return {Object}
    ###
    upsert: (data = {}) ->
        @memory.upsert data


    ###*
    Find object by ID.

    @method findById
    @public
    @param {String} id
    @return {Object}
    ###
    findById: (id) ->
        @memory.findById id


    ###*
    Find all model instances that match filter specification.

    @method find
    @public
    @param {Object} filter
    @return {Array(Object)}
    ###
    find: (filter) ->
        @memory.find filter

    ###*
    Find one model instance that matches filter specification. Same as find, but limited to one result

    @method findOne
    @public
    @param {Object} filter
    @return {Object}
    ###
    findOne: (filter) ->
        @memory.findOne filter


    ###*
    Destroy model instance

    @method destroyById
    @public
    @param {Object} data
    ###
    destroy: (data) ->
        @memory.destroy data


    ###*
    Destroy model instance with the specified ID.

    @method destroyById
    @public
    @param {String} id
    ###
    destroyById: (id) ->
        @memory.destroyById id


    ###*
    Update set of attributes.

    @method updateAttributes
    @public
    @param {Object} data
    @return {Object}
    ###
    updateAttributes: (id, data) ->
        @memory.updateAttributes id, data

module.exports = SyncResourceClientInterface
