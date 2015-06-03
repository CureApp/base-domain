
BaseModel = require './base-model'

###*
list class of DDD pattern.

@class BaseList
@extends BaseModel
@module base-domain
###
class BaseList extends BaseModel

    @createAnonymous: (itemModelName, models = [])->

        class AnonymousList extends BaseList
            @itemModelName: itemModelName

        return new AnonymousList(models)

    ###*
    model name of the item

    @property itemModelName
    @static
    @protected
    @type String
    ###
    @itemModelName: ''


    ###*
    ids: get ids of items

    @property ids
    @type Array
    @public
    ###
    Object.defineProperty @::, 'ids',
        get: -> (item.id for item in @items)


    ###*
    items: array of models

    @property items
    @type Array
    ###
    constructor: (models = []) ->

        @items = models.slice().sort(@sort)


    ###*
    sort items in constructor

    @method sort
    @protected
    ###
    sort: (modelA, modelB) ->
        if modelA.id > modelB.id then 1 else -1


    ###*
    first item

    @method first
    @public
    ###
    first: ->
        if @items.length is 0
            return null

        return @items[0]


    ###*
    last item

    @method last
    @public
    ###
    last: ->
        if @items.length is 0
            return null

        return @items[@items.length - 1]


    ###*
    export models to Array

    @method toArray
    @public
    ###
    toArray: ->
        @items.slice()


module.exports = BaseList
