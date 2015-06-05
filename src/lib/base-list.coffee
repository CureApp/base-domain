
BaseModel = require './base-model'

###*
list class of DDD pattern.

@class BaseList
@extends BaseModel
@module base-domain
###
class BaseList extends BaseModel

    ###*
    model name of the item

    @property itemModelName
    @static
    @protected
    @type String
    ###
    @itemModelName: ''


    ###*
    creates child class of BaseList

    @method getAnonymousClass
    @params {String} itemModelName
    @return {Function} child class of BaseList
    ###
    @getAnonymousClass: (itemModelName) ->


        class AnonymousList extends BaseList
            @itemModelName: itemModelName

        return AnonymousList


    ###*
    ids: get ids of items

    @property ids
    @type Array
    @public
    ###
    Object.defineProperty @::, 'ids',
        get: ->
            return null if not @constructor.containsEntity()
            return (item.id for item in @items)

    ###*
    items: array of models

    @property items
    @type Array
    ###

    ###*
    loaded: is data loaded or not

    @property loaded
    @type Boolean
    ###

    ###*
    @constructor
    @param {Array|Promise} models
    ###
    constructor: (models = []) ->

        if typeof models.then is 'function' # is thenable

            @loaded = false
            @items = []

            models.then (items) =>
                @items = items.slice().sort(@sort)
                @loaded = true

        else
            @items = models.slice().sort(@sort)
            @loaded = true


    ###*
    returns item is Entity

    @method containsEntity
    @static
    @public
    @return {Boolean}
    ###
    @containsEntity: ->
        return @getFacade().getModel(@itemModelName).isEntity


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


    ###*
    create plain list.
    if this list contains entities, returns their ids
    if this list contains non-entity models, returns their plain objects 

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        if @constructor.containsEntity()
            return ids: @ids

        else
            plainItems = []
            for item in @items
                if typeof item.toPlainObject is 'function'
                    plainItems.push item.toPlainObject()
                else
                    plainItems.push item

            return items: plainItems


module.exports = BaseList
