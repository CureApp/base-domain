'use strict'

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
    @param {String} modFirstName
    @return {BaseFactory}
    ###
    createFactory: (modFirstName, params...) ->

        @facade.__create(modFirstName, 'factory', params, @)


    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modFirstName
    @return {BaseRepository}
    ###
    createRepository: (modFirstName, params...) ->

        @facade.__create(modFirstName, 'repository', params, @)


    ###*
    create an instance of the given modFirstName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modFirstName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###
    createModel: (modFirstName, obj, options) ->

        @facade.createModel modFirstName, obj, options, @


    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} modFirstName
    @return {BaseRepository}
    ###
    createService: (modFirstName, params...) ->

        @facade.__create(modFirstName, 'service', params, @)


    ###*
    create a preferred repository instance
    3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createPreferredRepository
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent] if true, stop requiring parent class
    @return {BaseRepository}
    ###
    createPreferredRepository: (firstName, options, params...) ->

        @facade.createPreferred(firstName, 'repository', options, params, @)


    ###*
    create a preferred factory instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredFactory
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseFactory}
    ###
    createPreferredFactory: (firstName, options = {}, params...) ->

        options.noParent ?= true

        @facade.createPreferred(firstName, 'factory', options, params, @)


    ###*
    create a preferred service instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredService
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseService}
    ###
    createPreferredService: (firstName, options = {}, params...) ->

        options.noParent ?= true

        @facade.createPreferred(firstName, 'service', options, params, @)


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
