

###*
Facade class of DDD pattern.

Singleton. Use createInstance()/getInstance() to create/get instance

- create instance of factories
- create instance of repositories

@class BaseFactory
@extends Base
@module base-domain
###
class Facade

    @instance: null


    ###*
    create instance of Facade if not created yet
    singleton.

    @method createInstance
    @static
    @param {Object} [options]
    @return {Facade}
    ###
    @createInstance: (options= {}) ->
        if @instance?
            throw new Error("""instance of Facade is already created.
                               Call DomainFacade::getInstance() instead.""")
        @instance = new Facade(options) 



    ###*
    constructor

    @constructor
    @param {String} [options]
    @param {String} [options.dirname="."] path where domain definition files are included
    ###
    constructor: (options) ->

        @dirname = options.dirname ? '.'



    ###*
    get instance of Facade if already created

    @method getInstance
    @static
    @return {Facade}
    ###
    @getInstance: ->
        @instance ? throw new Error("""instance of Facade is not created yet.
                                       Call DomainFacade::createInstance() instead.""")



    ###*
    get a model class

    @method getModel
    @param {String} name
    @return {Class}
    ###
    getModel: (name)->
        return @require(name)


    ###*
    get a factory class

    @method getFactory
    @param {String} name
    @return {Class}
    ###
    getFactory: (name)->
        return @require("#{name}-factory")


    ###*
    get a repository class

    @method getRepository
    @param {String} name
    @return {Class}
    ###
    getRepository: (name)->
        return @require("#{name}-repository")


    ###*
    create a factory instance

    @method createFactory
    @param {String} name
    @return {DomainFactory}
    ###
    createFactory: (name)->
        @create("#{name}-factory")


    ###*
    create a repository instance

    @method createRepository
    @param {String} name
    @return {DomainRepository}
    ###
    createRepository: (name)->
        @create("#{name}-repository")


    ###*
    read a file and returns class

    @method require
    @param {String} name
    @return {Class}
    ###
    require: (name)->

        path = "#{@dirname}/#{name}"
        require path


    ###*
    read a file and returns the instance of the file's class

    @method create
    @param {String} name
    @param {Object} params コンストラクタの第一引数に渡す値
    @return {DomainFactory}
    ###
    create: (name)->
        DomainClass = @require(name)
        return new DomainClass()


    ###*
    create instance of DomainError


    @method error
    @param {String} reason reason of the error
    @param {String} [message]
    @return {DomainError}
    ###
    error: (reason, message)->

        DomainError = @constructor.DomainError
        return new DomainError(reason, message)


    ###*
    check if given object is instance of DomainError

    @method isDomainError
    @param {Error} e
    @return {Boolean}
    ###
    isDomainError: (e)->

        DomainError = @constructor.DomainError
        return e instanceof DomainError



    @Base           : require './base'
    @BaseModel      : require './base-model'
    @Entity         : require './entity'
    @BaseFactory    : require './base-factory'
    @BaseRepository : require './base-repository'
    @DomainError    : require './domain-error'


module.exports = Facade
