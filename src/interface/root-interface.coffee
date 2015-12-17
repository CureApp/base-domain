'use strict'

###*
interface of Aggregate Root

@class RootInterface
@module base-domain
###
class RootInterface

   # this file is just a concept and no implementation here.

    ###*
    is root (to identify RootInterface)
    @property {Boolean} isRoot
    @static
    ###

    ###*
    create a factory instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createFactory
    @param {String} modelName
    @return {BaseFactory}
    ###

    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modelName
    @return {BaseRepository}
    ###

    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} name
    @return {BaseRepository}
    ###

    ###*
    get facade

    @method getFacade
    @return {Facade}
    ###

    ###*
    create an instance of the given modelName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###

    ###*
    create a preferred repository instance
    3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createPreferredRepository
    @param {String} modelName
    @param {Object} [options]
    @param {Object} [options.noParent] if true, stop requiring parent class
    @return {BaseRepository}
    ###

    ###*
    create a preferred factory instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredFactory
    @param {String} modelName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseFactory}
    ###

    ###*
    create a preferred service instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredService
    @param {String} modelName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseService}
    ###

module.exports = RootInterface
