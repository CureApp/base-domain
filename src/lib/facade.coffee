'use strict'

Util = require '../util'

GeneralFactory = require './general-factory'
MasterDataResource = require '../master-data-resource'
ModelProps = require './model-props'
BaseModule = require './base-module'
CoreModule = require './core-module'

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
    Get facade

    @method getFacade
    @return {Facade}
    @chainable
    ###
    getFacade: -> @


    ###*
    Latest instance created via @createInstance()
    This instance will be attached base instances with no @root property.

    @property {Facade} latestInstance
    @static
    ###
    @latestInstance: null


    ###*
    create instance of Facade

    @method createInstance
    @static
    @param {Object} [options]
    @return {Facade}
    ###
    @createInstance: (options = {}) ->
        Constructor = @
        instance = new Constructor(options)
        Facade.latestInstance = instance
        return instance


    ###*
    constructor

    @constructor
    @param {String} [options]
    @param {String} [options.dirname="."] path where domain definition files are included
    @param {Object} [options.preferred={}]
    @param {Object} [options.preferred.repository] key: firstName, value: repository name used in facade.createPreferredRepository(firstName)
    @param {Object} [options.preferred.factory] key: firstName, value: factory name used in facade.createPreferredFactory(firstName)
    @param {Object} [options.preferred.service] key: firstName, value: service name used in facade.createPreferredService(firstName)
    @param {String|Array(String)} [options.preferred.module] module prefix attached to load preferred class
    @param {Boolean} [options.master] if true, MasterDataResource is enabled.
    ###
    constructor: (options = {}) ->

        Object.defineProperties @,
            nonExistingClassNames: value: {}
            classes   : value: {}
            modelProps: value: {}
            modules   : value: {}
            preferred : value:
                repository : Util.clone(options.preferred?.repository) ? {}
                factory    : Util.clone(options.preferred?.factory) ? {}
                service    : Util.clone(options.preferred?.service) ? {}
                module     : options.preferred?.module

        @dirname = options.dirname ? '.'

        for moduleName, path of Util.clone(options.modules ? {})
            @modules[moduleName] = new BaseModule(moduleName, path, @)
        throw @error('invalidModuleName', 'Cannot use "core" as a module name') if @modules.core

        @modules.core = new CoreModule(@dirname, @)

        if options.master
            ###*
            instance of MasterDataResource
            Exist only when "master" property is given to Facade's option

            @property {MasterDataResource} master
            @optional
            @readOnly
            ###
            @master = new MasterDataResource(@)

        @init()
        @master?.init()


    # for base-domainify and non-node-facade-generator. keep it empty
    init: ->

    # for base-domainify. keep it empty
    initWithPacked: (packed) ->
        { masterData, core, modules } = packed

        if masterData and not @master?
            @master = new MasterDataResource(@)

        @master?.init = -> @initWithData(masterData)

        for klassName, klass of core
            this.addClass(klassName, klass)

        for moduleName, klasses of modules
            for klassName, klass of klasses
                this.addClass(moduleName + '/' + klassName, klass)

        return @


    ###*
    get a model class

    @method getModel
    @param {String} firstName
    @return {Function}
    ###
    getModel: (firstName) ->
        return @require(firstName)


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
        GeneralFactory.createModel(modFirstName, obj, options, root ? @)


    ###*
    create a factory instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the factory

    @method createFactory
    @param {String} modFirstName
    @return {BaseFactory}
    ###
    createFactory: (modFirstName, params...) ->
        @__create(modFirstName, 'factory', params, @)


    ###*
    create a repository instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the repository

    @method createRepository
    @param {String} modFirstName
    @return {BaseRepository}
    ###
    createRepository: (modFirstName, params...) ->
        @__create(modFirstName, 'repository', params, @)


    ###*
    create a service instance
    2nd, 3rd, 4th ... arguments are the params to pass to the constructor of the service

    @method createService
    @param {String} modFirstName
    @return {BaseService}
    ###
    createService: (modFirstName, params...) ->
        @__create(modFirstName, 'service', params, @)


    __create: (modFirstName, type, params, root) ->

        modFullName = if type then modFirstName + '-' + type else modFirstName

        Class = ClassWithConstructor = @require(modFullName)

        while ClassWithConstructor.length is 0 and ClassWithConstructor isnt Object
            ClassWithConstructor = Util.getProto(ClassWithConstructor::).constructor

        while params.length < ClassWithConstructor.length - 1
            params.push undefined

        return new Class(params..., root ? @)


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

        @createPreferred(firstName, 'repository', options, params, @)


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

        options.noParent ?= true

        @createPreferred(firstName, 'factory', options, params, @)


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

        options.noParent ?= true

        @createPreferred(firstName, 'service', options, params, @)


    ###*
    create a preferred factory|repository|service instance

    @method createPreferred
    @private
    @param {String} modFirstName
    @param {String} type factory|repository|service
    @param {Object} [options]
    @param {Object} [params] params pass to constructor of Repository, Factory or Service
    @param {RootInterface} root
    @return {BaseFactory}
    ###
    createPreferred: (modFirstName, type, options = {}, params, root) ->

        originalFirstName = modFirstName

        for modFullName in @getPreferredNames(modFirstName, type)
            return @__create(modFullName, null, params, root) if @hasClass(modFullName)

        if not options.noParent
            ParentClass = @require(modFirstName).getParent()
            if ParentClass.className
                return @createPreferred(ParentClass.getName(), type, options, params, root)

        throw @error("preferred#{type}NotFound", "preferred #{type} of '#{originalFirstName}' is not found")


    ###*
    @method getPreferredNames
    @private
    @param {String} modFirstName
    @param {String} type repository|factory|service
    @return {String} modFullName
    ###
    getPreferredNames: (modFirstName, type) ->

        specific = @preferred[type][modFirstName]

        names = [@preferred.module, @moduleName(modFirstName), 'core'] # FIXME: make it unique
            .filter (v) -> v
            .map (moduleName) =>
                @getModule(moduleName).normalizeName(modFirstName + '-' + type)

        names.unshift specific if specific

        return names


    ###*
    read a file and returns class

    @method require
    @private
    @param {String} modFullName
    @return {Function}
    ###
    require: (modFullName_o) ->

        modFullName = @getModule().normalizeName(modFullName_o)

        return @classes[modFullName] if @classes[modFullName]?

        moduleName = @moduleName(modFullName)
        fullName   = @fullName(modFullName)

        if not @nonExistingClassNames[modFullName] # avoid searching non-existing files many times
            mod = @getModule(moduleName)
            throw @error('moduleNotFound', "module '#{moduleName}' is not found") if not mod?
            klass = mod.requireOwn(fullName)

        if not klass?
            @nonExistingClassNames[modFullName] = true

            modFullName = fullName # strip module name
            klass = @getModule().requireOwn(fullName)

        if not klass?
            @nonExistingClassNames[fullName] = true
            throw @error('modelNotFound', "model '#{modFullName_o}' is not found")

        @nonExistingClassNames[modFullName] = false
        @addClass modFullName, klass


    ###*
    @method getModule
    @param {String} moduleName
    @return {BaseModule}
    ###
    getModule: (moduleName = 'core') ->
        @modules[moduleName]


    ###*
    get moduleName from modFullName
    @method moduleName
    @private
    @param {String} modFullName
    @return {String}
    ###
    moduleName: (modFullName) ->
        if modFullName.match '/' then modFullName.split('/')[0] else 'core'


    ###*
    get fullName from modFullName
    @method fullName
    @private
    @param {String} modFullName
    @return {String}
    ###
    fullName: (modFullName) ->
        if modFullName.match '/' then modFullName.split('/')[1] else modFullName


    ###*
    Serialize the given object containing model information

    @method serialize
    @param {any} val
    @return {String}
    ###
    serialize: (val) ->
        Util.serialize val


    ###*
    Deserializes serialized string

    @method deserialize
    @param {String} str
    @return {any}
    ###
    deserialize: (str) ->
        Util.deserialize str, @


    ###*
    check existence of the class of the given name

    @method hasClass
    @param {String} modFullName
    @return {Function}
    ###
    hasClass: (modFullName) ->

        modFullName = @getModule().normalizeName(modFullName)

        return false if @nonExistingClassNames[modFullName]

        try
            @require(modFullName)
            return true
        catch e
            return false


    ###*
    add class to facade.
    the class is acquired by @require(modFullName)

    @method addClass
    @private
    @param {String} modFullName
    @param {Function} klass
    @return {Function}
    ###
    addClass: (modFullName, klass) ->

        modFullName = @getModule().normalizeName(modFullName)

        klass.className = modFullName
        klass.moduleName = @moduleName(modFullName)

        delete @nonExistingClassNames[modFullName]

        @classes[modFullName] = klass


    ###*
    Get ModelProps by firstName.
    ModelProps summarizes properties of this class

    @method getModelProps
    @param {String} modFullName
    @return {ModelProps}
    ###
    getModelProps: (modFullName) ->

        if not @modelProps[modFullName]?

            Model = @getModel(modFullName)

            @modelProps[modFullName] = new ModelProps(modFullName, Model.properties, @getModule(@moduleName modFullName))

        return @modelProps[modFullName]

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
    @param {Array(String)} [options.models=null] model firstNames to insert. default: all models
    @return {Promise(EntityPool)} inserted data
    ###
    insertFixtures: (options = {}) ->

        Fixture = require '../fixture'
        fixture = new Fixture(@, options)
        fixture.insert(options.models)


    @Base                : require './base'
    @BaseModel           : require './base-model'
    @BaseService         : require './base-service'
    @ValueObject         : require './value-object'
    @Entity              : require './entity'
    @AggregateRoot       : require './aggregate-root'
    @Collection          : require './collection'
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
