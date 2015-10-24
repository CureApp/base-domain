
Entity = require './entity'
MemoryResource = require '../memory-resource'

###*

@class AggregateRoot
@implements RootInterface
@extends Entity
@module base-domain
###
class AggregateRoot extends Entity

    ###*
    is root (to identify RootInterface)
    @property {Boolean} isRoot
    @static
    ###
    @isRoot: true

    ###*
    key: modelName, value: MemoryResource

    @property {Object(MemoryResource)} memories
    ###

    constructor: ->

        Object.defineProperty @, 'memories', value: {}

        super


    ###*
    create a factory instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createFactory
    @param {String} modelName
    @return {BaseFactory}
    ###
    createFactory: (modelName, params...) ->

        @getFacade().__createFactory(modelName, params..., @)


    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modelName
    @return {BaseRepository}
    ###
    createRepository: (modelName, params...) ->

        @getFacade().__createRepository(modelName, params..., @)


    ###*
    create an instance of the given modelName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###
    createModel: (modelName, obj, options) ->

        @getFacade().createModel modelName, obj, options, @


    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} name
    @return {BaseRepository}
    ###
    createService: (name, params...) ->

        @getFacade().__createService(modelName, params..., @)


    ###*
    get or create a memory resource to save to @memories
    Only called from LocalRepository

    @method useMemoryResource
    @param {String} modelName
    @return {MemoryResource}
    ###
    useMemoryResource: (modelName) ->

        @memories[modelName] ?= new MemoryResource()


    ###*
    create plain object without relational entities
    plainize memoryResources

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        plain = super

        plain.memories = {}

        for modelName, memoryResource of @memories
            plain.memories[modelName] = memoryResource.toPlainObject()

        return plain


    ###*
    set value to prop
    set memories

    @method set
    ###
    set: (k, memories) ->
        if k isnt 'memories'
            return super

        for modelName, plainMemory of memories
            @memories[modelName] = MemoryResource.restore(plainMemory)

        return @


module.exports = AggregateRoot
