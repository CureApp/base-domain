'use strict'

DomainError = require './domain-error'

{ hyphenize } = require '../util'

getProto = Object.getPrototypeOf ? (obj) -> obj.__proto__

###*
parent class of model, factory, repository and service

gives them `this.facade` property

@class Base
@module base-domain
###
class Base
    Object.defineProperty @::, 'facade', get: -> @root.facade

    @isBaseDomainClass: true

    ###*
    Hyphenized name.
    The name should equal to the file name (without path and extension).
    If not set, facade will set the file name automatically.
    This property were not necessary if uglify-js would not mangle class name...

    @property {String} className
    @static
    @private
    ###
    @className: null


    constructor: (root) ->

        @setRoot(root)

        # add class to facade, if not registered.
        if @root
            facade = @facade
            if @constructor.className and not facade.hasClass @constructor.className
                facade.addClass @constructor.className, @constructor



    ###*
    @method setRoot
    @protected
    ###
    setRoot: (root) ->

        if not root?.constructor.isRoot
            console.error("""
                base-domain: [warning] constructor of '#{@constructor.name}' was not given RootInterface (e.g. facade).
            """)

            { latestInstance } = require('./facade')

            if latestInstance?
                console.error("""
                    @root is automatically set, value is the most recently created facade via Facade.createInstance().
                    ( class name: #{latestInstance.constructor.name} )
                """)
                root = latestInstance

            else
                console.error("""@root, @facade is unavailable.""")
                root = null

            console.error new Error().stack

        ###*
        @property {RootInterface} root
        ###
        Object.defineProperty @, 'root',
            value: root
            writable: true


    ###*
    Get facade

    @deprecated just use this.facade
    @method getFacade
    @return {Facade}
    ###
    getFacade: ->
        if not @root?
            throw @error 'base-domain:noFacadeAssigned', """'#{@constructor.name}' does not have @root.
            Give it via constructor or create instance via Facade.
            """

        @root.facade

    ###*
    Get module which this class belongs to

    @method getModule
    @return {BaseModule}
    ###
    getModule: ->
        @facade.getModule(@constructor.moduleName)


    ###*
    get parent class
    @method getParent
    @return {Function}
    ###
    @getParent: ->
        getProto(@::).constructor


    ###*
    get className

    @method getName
    @public
    @static
    @return {String}
    ###
    @getName: ->

        if not @className or @getParent().className is @className

            hyphenized = hyphenize @name

            console.error("""
                @className property is not defined at class #{@name}.
                It will automatically be set when required through Facade.
                You might have loaded this class not via Facade.
                We guess the name "#{hyphenized}" by the function name instead of @className.
                It would not work at mangled JS (uglify-js).
            """)

            console.error new Error().stack

            return hyphenize @name


        return @className


    ###*
    create instance of DomainError

    @method error
    @param {String} reason reason of the error
    @param {String} [message]
    @return {Error}
    ###
    error: (reason, message) ->

        new DomainError(reason, message)


    ###*
    Show indication message of deprecated method

    @method deprecated
    @protected
    @param {String} methodName
    @param {String} message
    @return {Error}
    ###
    deprecated: (methodName, message) ->
        try
            line = new Error().stack.split('\n')[3]
            console.error("Deprecated method: '#{methodName}'. #{message if message}\n", line)
        catch e

module.exports = Base
