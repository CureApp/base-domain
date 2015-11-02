DomainError = require './domain-error'

{ hyphenize } = require '../util'

getProto = Object.getPrototypeOf ? (obj) -> obj.__proto__

###*
parent class of model, factory and repository.

gives them @getFacade() method.

@class Base
@module base-domain
###
class Base

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

        if not root?.constructor.isRoot
            console.error("""
                base-domain: [warning] constructor of '#{@constructor.name}' was not given RootInterface (e.g. facade).
                    @root, @getFacade() is unavailable.
            """)
            root = null

        ###*
        @property {RootInterface} root
        ###
        Object.defineProperty @, 'root',
            value: root
            writable: true

        # add class to facade, if not registered.
        if root
            facade = @getFacade()
            if @constructor.className and not facade.hasClass @constructor.className
                facade.addClass @constructor.className, @constructor


    ###*
    Get facade

    @method getFacade
    @return {Facade}
    ###
    getFacade: ->
        if not @root?
            throw @error 'base-domain:noFacadeAssigned', """'#{@constructor.name}' does not have @root.
            Give it via constructor or create instance via Facade.
            """

        @root.getFacade()

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

            try
                throw new Error()
            catch e
                console.error e.stack

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


module.exports = Base
