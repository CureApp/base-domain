
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

    @property length
    @type number
    @public
    ###
    Object.defineProperty @::, 'length',
        get: ->
            @items.length


    ###*
    items: array of models

    @property items
    @type Array
    ###

    ###*
    @constructor
    @params {any} props
    @params {RootInterface} root
    ###
    constructor: (props = {}, root) ->

        Object.defineProperty @, 'items',
            value: []
            enumerable: true

        super(props, root)



    ###*
    @method addItems
    @param {Array(BaseModel|Object)} items
    @protected
    ###
    addItems: (items) ->

        super
        @items.sort(@sort) if @sort


    ###*
    add item to @items

    @method addItem
    @protected
    @param {BaseModel} item
    ###
    addItem: (item) ->

        @items.push item


    ###*
    clear all models

    @method clear
    ###
    clear: ->
        @items.pop() for i in [0...@length]
        return


    ###*
    remove item by index

    @method remove
    @param {Number} index
    ###
    remove: (index) -> @items.splice(index, 1)



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
    first: -> @items[0]

    ###*
    last item

    @method last
    @public
    ###
    last: -> @items[@length - 1]

    ###*
    export models to Array

    @method toArray
    @public
    ###
    toArray: -> @items.slice()




module.exports = BaseList
