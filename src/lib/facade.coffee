
require('es6-promise').polyfill()
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
        @init()


    # for base-domainify. keep it empty
    init: ->


    ###*
    load master tables

    @method loadMasterTables
    @return {Promise}
    ###
    loadMasterTables: (modelNames...) ->
        Promise.all (@getRepository(modelName).load?() for modelName in modelNames)


    ###*
    get a model class

    @method getModel
    @param {String} name
    @return {Class}
    ###
    getModel: (name) ->
        return @require(name)


    ###*
    get a factory class

    ISSUE: user will never know load failure

    @method getFactory
    @param {String} name
    @param {Boolean} [useAnonymousWhenFailed=false]
    @return {Class}
    ###
    getFactory: (name, useAnonymousWhenFailed = off) ->
        try
            return @require("#{name}-factory")
        catch e
            throw e if not useAnonymousWhenFailed

            class AnonymousFactory extends Facade.BaseFactory
                @modelName  : name
                @isAnonymous: true

            @addClass("#{name}-factory", AnonymousFactory)


    ###*
    get a repository class

    @method getRepository
    @param {String} name
    @return {Class}
    ###
    getRepository: (name) ->
        return @require("#{name}-repository")


    ###*
    create a factory instance

    @method createFactory
    @param {String} name
    @param {Boolean} [useAnonymousWhenFailed=false]
    @return {DomainFactory}
    ###
    createFactory: (name, useAnonymousWhenFailed = off) ->
        FactoryClass = @getFactory(name, useAnonymousWhenFailed)
        return new FactoryClass()



    ###*
    create a repository instance

    @method createRepository
    @param {String} name
    @param {Object} [options]
    @return {DomainRepository}
    ###
    createRepository: (name, options) ->
        @create("#{name}-repository", options)


    ###*
    read a file and returns class

    @method require
    @private
    @param {String} name
    @return {Function}
    ###
    require: (name) ->
        return @classes[name] if @classes[name]?

        path = "#{@dirname}/#{name}"
        klass = require path

        @addClass name, klass


    ###*
    set klass to dictionary
    attaches getFacade() method

    @method addClass
    @private
    @param {String} name
    @param {Function} klass
    @param {Boolean} skipCompare skip comparing getFacade() function
    @return {Function}

    FIXME: the 3rd arg "skipCompare" is set only by browserified code
    because browserified classes don't have the same getFacade() method as Base
    ###
    addClass: (name, klass, skipCompare = false) ->

        if skipCompare or klass::getFacade is @constructor.Base::getFacade
            facade = @
            Class = copy(klass)
            Class.getFacade  = -> facade
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
    create: (name, options) ->
        DomainClass = @require(name)
        return new DomainClass(options)


    ###*
    create instance of DomainError

    @method error
    @param {String} reason reason of the error
    @param {String} [message]
    @return {DomainError}
    ###
    error: (reason, message) ->

        DomainError = @constructor.DomainError
        return new DomainError(reason, message)


    ###*
    check if given object is instance of DomainError

    @method isDomainError
    @param {Error} e
    @return {Boolean}
    ###
    isDomainError: (e) ->

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




    @Base             : require './base'
    @BaseModel        : require './base-model'
    @Entity           : require './entity'
    @BaseList         : require './base-list'
    @BaseFactory      : require './base-factory'
    @BaseRepository   : require './base-repository'
    @MasterRepository : require './master-repository'
    @DomainError      : require './domain-error'


module.exports = Facade
