
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

        return false if not id?

        id.toString() is @toString()


module.exports = Id
