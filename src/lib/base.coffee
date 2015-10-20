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


    ###*
    @property {RootInterface} root
    ###
    constructor: (root) ->

        Object.defineProperty @, 'root',
            value: root ? @getFacade()
            writable: true


    ###*
    get facade

    the implementation is in Facade#requre()


    @method getFacade
    @return {Facade}
    ###
    getFacade : ->
        throw new DomainError 'base-domain:facadeNotRegistered', """
            Facade is not created yet, or you required domain classes not from Facade.
            Require domain classes, instances by

                facade.getModel()
                facade.createModel()
                facade.createFactory()
                facade.createRepository()

            to attach getFacade() method to them.
        """

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
