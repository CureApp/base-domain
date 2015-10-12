
Entity = require './entity'
MemoryResource = require './memory-resource'

###*

@class AggregateRoot
@implements RootInterface
@extends Entity
###
class AggregateRoot extends Entity

    @descendants: []

    constructor: ->
        super

        @clients = {}

        for modelName in @constructor.descendants
            @clients[modelName] = new MemoryResource()

        @root = @


    ###*
    create a factory instance

    @method createFactory
    @param {String} modelName
    @return {BaseFactory}
    ###
    createFactory: (modelName) ->

        @getFacade().createFactory(modelName, @)


    ###*
    create a repository instance

    @method createRepository
    @param {String} modelName
    @return {BaseRepository}
    ###
    createRepository: (modelName) ->

        @getFacade().createRepository(modelName, @)


    ###*
    create an instance of the given modelName using obj

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###
    createModel: (modelName, obj, options) ->

        @createFactory(modelName).createFromObject(obj, options)



module.exports = AggregateRoot
