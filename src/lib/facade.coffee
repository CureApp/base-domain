
require('es6-promise').polyfill()

{ copy } = require('copy-class')

{ camelize, requireFile } = require '../util'

GeneralFactory = require './general-factory'

getProto = Object.getPrototypeOf ? (obj) -> obj.__proto__

###*
Facade class of DDD pattern.

- create instance of factories
- create instance of repositories

@class Facade
@implements RootInterface
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
    key: modelName, value: MemoryResource

    @property {Object(MemoryResource)} memories
    ###

    ###*
    constructor

    @constructor
    @param {String} [options]
    @param {String} [options.dirname="."] path where domain definition files are included
    ###
    constructor: (options) ->
        @classes = {}
        @memories = {}
        @dirname = options.dirname ? '.'
        @init()


    # for base-domainify. keep it empty
    init: ->


    ###*
    get a model class

    @method getModel
    @param {String} modelName
    @return {Function}
    ###
    getModel: (getName) ->
        return @require(getName)



    ###*
    get a factory class

    ISSUE: user will never know load failure

    @method getFactory
    @param {String} name
    @return {Function}
    ###
    getFactory: (name) ->
        @require("#{name}-factory")


    ###*
    get a repository class

    @method getRepository
    @param {String} name
    @return {Class}
    ###
    getRepository: (name) ->
        @require("#{name}-repository")


    ###*
    create an instance of the given modelName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel}
    ###
    createModel: (modelName, obj, options) ->

        @createFactory(modelName).createFromObject(obj ? {}, options)


    ###*
    create a factory instance

    @method createFactory
    @param {String} modelName
    @params {RootInterface} root
    @return {BaseFactory}
    ###
    createFactory: (modelName, root) ->
        root = undefined if typeof root isnt 'object' # for backward compatibility

        try
            Factory = @getFactory(modelName)
            return new Factory(root)

        catch e
            return new GeneralFactory(modelName, root ? @)


    ###*
    create a repository instance

    @method createRepository
    @param {String} modelName
    @params {RootInterface} root
    @return {BaseRepository}
    ###
    createRepository: (modelName, root) ->

        Repository = @getRepository(modelName)
        return new Repository(root)



    ###*
    get or create a memory resource to save to @memories

    @method useMemoryResource
    @param {String} modelName
    @return {MemoryResource}
    ###
    useMemoryResource: (modelName) ->

        @memories[modelName] ?= new @constructor.MemoryResource()


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
                throw @error 'base-domain:classNameInvalid', """given class should be named '#{klass.getName()}',
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


    @Base                : require './base'
    @BaseModel           : require './base-model'
    @ValueObject         : require './value-object'
    @Entity              : require './entity'
    @AggregateRoot       : require './aggregate-root'
    @BaseList            : require './base-list'
    @BaseDict            : require './base-dict'
    @BaseFactory         : require './base-factory'
    @BaseRepository      : require './base-repository'
    @BaseSyncRepository  : require './base-sync-repository'
    @BaseAsyncRepository : require './base-async-repository'
    @LocalRepository     : require './local-repository'
    @DomainError         : require './domain-error'
    @MemoryResource      : require './memory-resource'


module.exports = Facade
