
###*
    generates array which emits "added" and "removed" events
    "added" event emits added items as an array
    "removed" event emits removed items as an array
###
class EventedArrayGenerator

    ###*
    generate empty array with event props

    @method generate
    @public
    @static
    @param {Object} thisOfListeners "this" of listener functions
    @return {Array} arr
    ###
    @generate: (thisOfListeners) ->
        arr = []
        generator = new EventedArrayGenerator(arr, thisOfListeners)
        return generator.appendProps()


    constructor: (@arr, @thisOfListeners) ->


    ###*
    append event props to given array

    @method generate
    @private
    @param {Array} arr
    @param {Object} thisOfListeners "this" of listener functions
    @return {Array} arr
    ###
    appendProps: ->
        @defineEventProps()
        @enableHookToBangMethods()

        return @arr


    ###*
    define props related to event-handling

    @method defineEventProps
    @private
    ###
    defineEventProps: ->

        Object.defineProperties @arr,

            listeners       : value : {}
            thisOfListeners : value : @thisOfListeners
            emit            : value : EventedMethods.emit
            on              : value : EventedMethods.on



    ###*
    enable Array's bang methods to emit event

    @method enableHookToBangMethods
    @private
    ###
    enableHookToBangMethods: ->

        bangMethodNames = [
            'pop'
            'push'
            'shift'
            'unshift'
            'splice'
        ]

        for bangMethodName in bangMethodNames

            Object.defineProperty @arr, bangMethodName, value: EventedMethods[bangMethodName]


###*
    "this" of these functions is array
###
class EventedMethods

    @emit: (name, param) ->
        try
            for fn in (@listeners[name] ? []) when typeof fn is 'function'
                fn.call(@thisOfListeners, param)
        catch e


    @on: (name, fn) ->
        @listeners[name] ?= []
        @listeners[name].push fn

    @push: (args...) ->
        ret = Array::push.apply(@, args)
        @emit('added', args)
        return ret

    @pop: ->
        popped = Array::pop.apply(@)
        @emit('removed', [popped])
        return popped

    @shift: ->
        shifted = Array::shift.apply(@)
        @emit('removed', [shifted])
        return shifted


    @unshift: (args...) ->
        ret = Array::unshift.apply(@, args)
        @emit('added', args)
        return ret


    @splice: (args...) ->
        removed = Array::splice.apply(@, args)
        @emit('removed', removed)
        @emit('added', args.slice(2))

        return removed


EventedArrayGenerator.EventedMethods = EventedMethods

module.exports = EventedArrayGenerator
