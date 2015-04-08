
copy = require('copy-class').copy

###*
Facade class of DDD pattern.

- create instance of factories
- create instance of repositories

@class Facade
@module base-domain
###
class Facade


    ###*
    create instance of Facade

    @method createInstance
    @static
    @param {Object} [options]
    @return {Facade}
    ###
    @createInstance: (options= {}) ->
        Constructor = @
        return new Constructor(options) 


    ###*
    constructor

    @constructor
    @param {String} [options]
    @param {String} [options.dirname="."] path where domain definition files are included
    ###
    constructor: (options) ->
        @classes = {}
        @dirname = options.dirname ? '.'



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
    @param {Object} [options]
    @return {DomainFactory}
    ###
    createFactory: (name, options)->
        @create("#{name}-factory", options)


    ###*
    create a repository instance

    @method createRepository
    @param {String} name
    @param {Object} [options]
    @return {DomainRepository}
    ###
    createRepository: (name, options)->
        @create("#{name}-repository", options)


    ###*
    read a file and returns class
    Attaches getFacade() method

    @method require
    @private
    @param {String} name
    @return {Class}
    ###
    require: (name)->
        return @classes[name] if @classes[name]?

        path = "#{@dirname}/#{name}"
        klass = require path


        if klass::getFacade is @constructor.Base::getFacade
            facade = @
            Class = copy(klass)
            Class::getFacade = -> facade
            @classes[name] = Class
        else
            @classes[name] = klass


    ###*
    read a file and returns the instance of the file's class

    @method create
    @private
    @param {String} name
    @param {Object} [options]
    @return {DomainFactory}
    ###
    create: (name, options)->
        DomainClass = @require(name)
        return new DomainClass(options)


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


    ###*
    insert fixture data
    (Node.js only)

    @method insertFixtures
    @param {Object} [options]
    @param {String} [options.dataDir='./data'] directory to have fixture data files
    @param {String} [options.tsvDir='./tsv'] directory to have TSV files
    @param {Array(String)} [options.models=null] model names to insert. default: all models
    @return {Promise(Object)} dataPool inserted data
    ###
    insertFixtures: (options = {}) ->

        Fixture = require './fixture'
        fixture = new Fixture(@, options)
        fixture.insert(options.models).then ->
            return fixture.dataPool




    @Base           : require './base'
    @BaseModel      : require './base-model'
    @Entity         : require './entity'
    @BaseFactory    : require './base-factory'
    @BaseRepository : require './base-repository'
    @DomainError    : require './domain-error'


module.exports = Facade
