
Entity = require './entity'
MemoryResource = require './memory-resource'

###*

@class AggregateRoot
@implements RootInterface
@extends Entity
###
class AggregateRoot extends Entity

    ###*
    key: modelName, value: MemoryResource

    @property {Object(MemoryResource)} memories
    ###

    constructor: ->

        Object.defineProperty @, 'memories', value: {}

        super

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
    get a model class

    @method getModel
    @param {String} modelName
    @return {Function}
    ###
    getModel: (modelName) ->

        @getFacade().getModel modelName


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


    ###*
    get or create a memory resource to save to @memories

    @method useMemoryResource
    @param {String} modelName
    @return {MemoryResource}
    ###
    useMemoryResource: (modelName) ->

        @memories[modelName] ?= MemoryResource()



module.exports = AggregateRoot
