
require('es6-promise').polyfill()
copy = require('copy-class').copy

{ camelize, requireFile } = require './util'


getProto = Object.getPrototypeOf ? (obj) -> obj.__proto__

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
    @return {Function}
    ###
    getFactory: (name, useAnonymousWhenFailed = off) ->
        try
            return @require("#{name}-factory")
        catch e
            throw e if not useAnonymousWhenFailed

            AnonymousFactory = Facade.BaseFactory.getAnonymousClass(name)

            @addClass("#{name}-factory", AnonymousFactory, true)


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
    @return {BaseFactory}
    ###
    createFactory: (name, useAnonymousWhenFailed = off) ->
        FactoryClass = @getFactory(name, useAnonymousWhenFailed)
        return new FactoryClass()


    ###*
    create a repository instance

    @method createRepository
    @param {String} name
    @param {Object} [options]
    @return {BaseRepository}
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

        file = "#{@dirname}/#{name}"
        klass = requireFile file

        @addClass name, klass


    ###*
    check existence of the class of the given name

    @method hasClass
    @param {String} name
    @return {Function}
    ###
    hasClass: (name) ->
        try
            @require(name)
            return true
        catch e
            return false


    ###*
    add copied class to facade.
    the class is acquired by @require(name)

    attaches getFacade() method (for both class and instance)

    @method addClass
    @private
    @param {String} name
    @param {Function} klass
    @param {Boolean} skipNameValidation validate class name is compatible with the name to register
    @return {Function}
    ###
    addClass: (name, klass, skipNameValidation = false) ->

        if skipNameValidation
            camelCasedName = camelize name

        else
            if klass.getName() isnt name
                throw @error """given class should be named '#{klass.getName()}',
                                but '#{name}' given."""
            camelCasedName = klass.name

        ParentClass = getProto(klass::).constructor

        if @constructor.isBaseClass ParentClass
            Class = copy(klass, camelCasedName)
        else
            CopiedParentClass = @require ParentClass.getName()
            Class = copy(klass, camelCasedName, CopiedParentClass)

        facade = @
        Class.getFacade  = -> facade
        Class::getFacade = -> facade
        @classes[name] = Class


    ###*
    read a file and returns the instance of the file's class

    @method create
    @private
    @param {String} name
    @param {Object} [options]
    @return {BaseFactory}
    ###
    create: (name, options) ->
        DomainClass = @require(name)
        return new DomainClass(options)


    ###*
    create instance of DomainError

    @method error
    @param {String} reason reason of the error
    @param {String} [message]
    @return {Error}
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

    ###*
    check the given class is registered in facade

    @method isBaseClass
    @static
    @param {Function} klass
    @return {Boolean}
    ###
    @isBaseClass: (klass) ->
        (klass is @[klass.name]) or
        (klass is @DomainError) or
        (@[klass.name]?.toString() is klass.toString())

    ###*
    registers the given class as a base class

    @method registerBaseClass
    @static
    @param {Function} klass
    ###
    @registerBaseClass: (klass) -> @[klass.name] = klass


    @Base               : require './base'
    @BaseModel          : require './base-model'
    @ValueObject        : require './value-object'
    @Entity             : require './entity'
    @BaseList           : require './base-list'
    @BaseDict           : require './base-dict'
    @BaseFactory        : require './base-factory'
    @ListFactory        : require './list-factory'
    @DictFactory        : require './dict-factory'
    @BaseRepository     : require './base-repository'
    @BaseSyncRepository : require './base-sync-repository'
    @MasterRepository   : require './master-repository'
    @DomainError        : require './domain-error'
    @MemoryResource     : require './memory-resource'


module.exports = Facade
