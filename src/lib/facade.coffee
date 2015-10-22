
require('es6-promise').polyfill()

{ copy } = require('copy-class')

{ camelize, requireFile } = require '../util'

GeneralFactory = require './general-factory'
MasterDataResource = require '../master-data-resource'

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
    is root (to identify RootInterface)
    @property {Boolean} isRoot
    @static
    ###
    @isRoot: true


    ###*
    create instance of Facade

    @method createInstance
    @static
    @param {Object} [options]
    @return {Facade}
    ###
    @createInstance: (options = {}) ->
        Constructor = @
        return new Constructor(options)


    ###*
    constructor

    @constructor
    @param {String} [options]
    @param {String} [options.dirname="."] path where domain definition files are included
    @param {Boolean} [options.master] if true, MasterDataResource is enabled.
    ###
    constructor: (options = {}) ->
        @classes = {}
        @dirname = options.dirname ? '.'

        if options.master

            masterPath = @dirname + '/master-data'

            ###*
            instance of MasterDataResource
            Exist only when "master" property is given to Facade's option

            @property {MasterDataResource} master
            @optional
            @readOnly
            ###
            @master = new MasterDataResource(masterPath)

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
    create an instance of the given modelName using obj
    if obj is null or undefined, empty object will be created.

    @method createModel
    @param {String} modelName
    @param {Object} obj
    @param {Object} [options]
    @param {RootInterface} [root]
    @return {BaseModel}
    ###
    createModel: (modelName, obj, options, root) ->
        GeneralFactory.createModel(modelName, obj, options, root ? @)


    ###*
    create a factory instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createFactory
    @param {String} modelName
    @return {BaseFactory}
    ###
    createFactory: (modelName, params...) ->
        @__createFactory(modelName, params..., @)

    __createFactory: (modelName, params..., root) ->

        Factory = @require("#{modelName}-factory")
        return new Factory(params..., root ? @)


    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modelName
    @return {BaseRepository}
    ###
    createRepository: (modelName, params...) ->
        @__createRepository(modelName, params..., @)

    __createRepository: (modelName, params..., root) ->

        Repository = @require("#{modelName}-repository")
        return new Repository(params..., root ? @)



    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} name
    @return {BaseRepository}
    ###
    createService: (name, params...) ->
        @__createService(name, params..., @)

    __createService: (name, params..., root) ->

        Service = @require("#{name}-service")

        return new Service(params..., root ? @)


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
        try
            klass = requireFile file
        catch e
            throw @error('modelNotFound', "model '#{name}' is not found")

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

    attaches getFacade() method to model intstances

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
    @BaseService         : require './base-service'
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
    @MasterRepository    : require './master-repository'
    @DomainError         : require './domain-error'
    @GeneralFactory      : require './general-factory'


module.exports = Facade
