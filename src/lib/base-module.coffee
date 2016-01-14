'use strict'

Util = require '../util'

###*
Module of DDD pattern.

@class BaseModule
@implements RootInterface
@module base-domain
###
class BaseModule

    constructor: (@name, @path, @facade) ->

    ###*
    is root (to identify RootInterface)
    @property {Boolean} isRoot
    @static
    ###
    @isRoot: true


    ###*
    Get facade

    @method getFacade
    @return {Facade}
    @chainable
    ###
    getFacade: -> @facade


    normalizeName: (modFullName) ->
        if not modFullName.match '/'
            return @name + '/' + modFullName
        return modFullName

    ###*
    create an instance of the given modFirstName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modFirstName
    @param {Object} obj
    @param {Object} [options]
    @param {RootInterface} [root]
    @return {BaseModel}
    ###
    createModel: (modFirstName, obj, options, root) ->
        # TODO


    ###*
    create a factory instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createFactory
    @param {String} modFirstName
    @return {BaseFactory}
    ###
    createFactory: (modFirstName, params...) ->
        modFirstName = @normalizeName(modFirstName)
        @facade.createFactory(modFirstName, params...)


    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modFirstName
    @return {BaseRepository}
    ###
    createRepository: (modFirstName, params...) ->
        modFirstName = @normalizeName(modFirstName)
        @facade.createRepository(modFirstName, params...)


    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} modFirstName
    @return {BaseService}
    ###
    createService: (modFirstName, params...) ->
        modFirstName = @normalizeName(modFirstName)
        @facade.createRepository(modFirstName, params...)




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
        # TODO


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
        # TODO


    ###*
    create a preferred service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredService
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseService}
    ###
    createPreferredService: (firstName, options = {}, params...) ->
        # TODO



    ###*
    read a file and returns class

    @method require
    @private
    @param {String} modFullName
    @return {Function}
    ###
    requireOwn: (fullName) ->

        try
            return Util.requireFile(@path + '/' + fullName)
        catch e
            return null # FIXME: no information of e is returned.


module.exports = BaseModule
