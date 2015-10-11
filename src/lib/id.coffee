
###*
id

@class Id
@module base-domain
###
class Id

    constructor: (val) ->
        @val = val.toString()


    toString: ->
        @val.toString()


    toPlainObject: -> @toString()

    equals: (id) ->

        id.toString() is @toString()


module.exports = Id
