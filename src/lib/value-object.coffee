

Util = require '../util'

BaseModel = require './base-model'

###*
Base model class without "id" column, rather than a set of values

@class ValueObject
@extends BaseModel
@module base-domain
###
class ValueObject extends BaseModel

    @isEntity: false

    ###*
    check equality

    @method equals
    @param {ValueObject} vo
    @return {Boolean}
    ###
    equals: (vo) ->
        super(vo) and Util.deepEqual(@, vo)


module.exports = ValueObject
