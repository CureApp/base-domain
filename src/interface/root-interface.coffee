'use strict'

###*
interface of Aggregate Root

Followings are the meanings of argument name of files in detail.
Let's see difference with two file examples.
- A: core/post-submission-service
- B: server/diary-factory

- firstName:    A => post-submission,         B => diary
- fullName:     A => post-submission-service, B => diary-factory
- modFirstName: A => core/post-submission          | post-submission,         B => server/diary
- modFullName:  A => core/post-submission-service, | post-submission-service, B => server/diary-factory

"mod" requires module name except "core" module, which can be omitted


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
    @param {String} modFirstName
    @return {BaseFactory}
    ###

    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modFirstName
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
    get module the class belongs to

    @method getModule
    @return {BaseModule}
    ###

    ###*
    create an instance of the given modFirstName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modFirstName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###

    ###*
    create a preferred repository instance
    3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createPreferredRepository
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent] if true, stop requiring parent class
    @return {BaseRepository}
    ###

    ###*
    create a preferred factory instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredFactory
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseFactory}
    ###

    ###*
    create a preferred service instance
    3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createPreferredService
    @param {String} firstName
    @param {Object} [options]
    @param {Object} [options.noParent=true] if true, stop requiring parent class
    @return {BaseService}
    ###

module.exports = RootInterface
