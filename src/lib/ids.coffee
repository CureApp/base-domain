

Id = require './id'

###*
ids

@class Ids
@extends Array
@implements Id
@module base-domain
###
class Ids extends Array

    constructor: (ids) ->

        for id in ids
            id = new Id(id) if id not instanceof Id
            @push id


    toPlainObject: ->

        (item.toString() for item in @)

    equals: (ids) ->

        @toString() is @ids.toString()


module.exports = Ids
