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


    ###*
    Get module

    @method getModule
    @return {BaseModule}
    ###
    getModule: -> @


    normalizeName: (name) ->
        if not name.match '/'
            return @name + '/' + name
        return name

    stripName: (name) ->
        len = @name.length + 1
        if name.slice(0, len) is @name + '/'
            return name.slice(len)

        return name



    ###*
    get a model class in the module

    @method getModel
    @param {String} firstName
    @return {Function}
    ###
    getModel: (firstName) ->
        @facade.require @normalizeName firstName

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
        modFirstName = @normalizeName(modFirstName)
        @facade.createModel(modFirstName, obj, options, @)


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
        @facade.createService(modFirstName, params...)


    ###*
    create a preferred repository instance
    3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createPreferredRepository
    @param {String} modFirstName
    @param {Object} [options]
    @param {Object} [options.noParent] if true, stop requiring parent class
    @return {BaseRepository}
    ###
    createPreferredRepository: (modFirstName, options, params...) ->
        modFirstName = @normalizeName(modFirstName)
        @facade.createPreferredRepository(modFirstName, options, params...)


    ###*
    create a preferred factory instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredFactory
    @param {String} modFirstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseFactory}
    ###
    createPreferredFactory: (modFirstName, options = {}, params...) ->
        modFirstName = @normalizeName(modFirstName)
        @facade.createPreferredFactory(modFirstName, options, params...)


    ###*
    create a preferred service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredService
    @param {String} modFirstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseService}
    ###
    createPreferredService: (modFirstName, options = {}, params...) ->
        modFirstName = @normalizeName(modFirstName)
        @facade.createPreferredService(modFirstName, options, params...)


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
