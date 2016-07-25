'use strict'

Collection = require './collection'

###*
list class of DDD pattern.

@class BaseList
@extends Collection
@module base-domain
###
class BaseList extends Collection


    ###*
    the number of items

    @property itemLength
    @type number
    @public
    ###
    Object.defineProperty @::, 'itemLength',
        get: ->
            return 0 if not @loaded()
            @items.length


    ###*
    items: array of models

    @property {Array} items
    ###

    ###*
    @constructor
    @params {any} props
    @params {RootInterface} root
    ###
    constructor: (props = {}, root) ->

        super(props, root)


    ###*
    @method initItems
    @protected
    ###
    initItems: ->
        @items = []



    ###*
    @method addItems
    @param {Array(BaseModel|Object)} items
    @protected
    ###
    addItems: (items) ->

        super
        if @sort
            @items.sort(@sort)
            if @isItemEntity
                @ids = (item.id for item in @items)


    ###*
    add item to @items

    @method addItem
    @protected
    @param {BaseModel} item
    ###
    addItem: (item) ->
        @items.push item


    ###*
    remove item by index

    @method remove
    @param {Number} index
    ###
    remove: (index) ->

        return if not @loaded()

        @items.splice(index, 1)
        @ids.splice(index, 1) if @isItemEntity


    ###*
    remove item by index and create a new model

    @method $remove
    @param {Number} index
    @return {Baselist} newList
    ###
    $remove: (index) ->

        throw @error('NotLoaded') if not @loaded()

        newItems = @toArray()
        newItems.splice(index, 1)
        return @copyWith(items: newItems)


    ###*
    sort items in constructor

    @method sort
    @protected
    @abstract
    @param modelA
    @param modelB
    @return {Number}
    ###
    #sort: (modelA, modelB) ->


    ###*
    first item

    @method first
    @public
    ###
    first: ->
        return undefined if not @loaded()
        @items[0]

    ###*
    last item

    @method last
    @public
    ###
    last: ->
        return undefined if not @loaded()
        @items[@length - 1]


    ###*
    get item by index

    @method getByIndex
    @public
    ###
    getByIndex: (idx) ->
        return undefined if not @loaded()
        @items[idx]

    ###*
    get item by index

    @method getItem
    @public
    ###
    getItem: (idx) ->
        @items[idx] || throw @error('IndexNotFound')


    ###*
    export models to Array

    @method toArray
    @public
    ###
    toArray: ->
        return [] if not @loaded()
        @items.slice()




module.exports = BaseList
