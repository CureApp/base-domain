'use strict'

###*
Module of DDD pattern.

@class BaseModule
@implements RootInterface
@module base-domain
###
class BaseModule

    constructor: (@name, @facade) ->

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
    @method attachModuleNameIfPossible
    @param {String} modFirstName
    @return {String}
    ###
    attachModuleNameIfPossible: (modFirstName) ->

        return modFirstName if modFirstName.match '/'

        return @constructor.moduleName + '/' + modFirstName


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
        # TODO

    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modFirstName
    @return {BaseRepository}
    ###
    createRepository: (modFirstName, params...) ->
        # TODO

    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} modFirstName
    @return {BaseService}
    ###
    createService: (modFirstName, params...) ->
        # TODO


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
    create a preferred factory|repository|service instance

    @method createPreferred
    @private
    @param {String} firstName
    @param {String} type factory|repository|service
    @param {Object} [options]
    @param {Object} [params] params pass to constructor of Repository, Factory or Service
    @param {RootInterface} root
    @return {BaseFactory}
    ###
    createPreferred: (firstName, type, options = {}, params, root) ->
        # TODO

    ###*
    @method getPreferredName
    @private
    @param {String} firstName
    @param {String} type repository|factory|service
    @return {String} modFullName
    ###
    getPreferredName: (firstName, type) ->
        # TODO



    ###*
    read a file and returns class

    @method require
    @private
    @param {String} modFullName
    @return {Function}
    ###
    require: (modFullName) ->
        # TODO


module.exports = Facade
