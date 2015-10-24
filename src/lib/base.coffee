DomainError = require './domain-error'

{ hyphenize } = require '../util'

{ EventEmitter } = require 'events'

###*
parent class of model, factory and repository.

gives them @getFacade() method.

@class Base
@module base-domain
###
class Base extends EventEmitter


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
            if not facade.hasClass @constructor.getName()
                facade.addClass @constructor


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
    emit event at next tick
    @method emitNext
    ###
    emitNext: (args...) ->
        process.nextTick => @emit args...


    ###*
    get parent class if it is not BaseClass
    @method getCustomParent
    @return {Function}
    ###
    @getCustomParent: ->
        Facade = require './facade'
        ParentClass = @__super__

        if Facade.isBaseClass ParentClass
            return null

        return ParentClass



    ###*
    ClassName -> class-name
    the name must compatible with file name

    @method getName
    @public
    @static
    @return {String}
    ###
    @getName: -> hyphenize @name


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
