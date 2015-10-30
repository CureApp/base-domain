
Collection = require './collection'

###*
dictionary-structured data model

@class BaseDict
@extends Collection
@module base-domain
###
class BaseDict extends Collection

    ###*
    get unique key from item

    @method key
    @static
    @protected
    ###
    @key: (item) -> item.id


    ###*
    the number of items

    @property {Number} itemLength
    @public
    ###
    Object.defineProperty @::, 'itemLength',
        get: ->
            Object.keys(@items).length


    ###*
    items: dictionary of keys - models

    @property items
    @type Objects
    ###

    ###*
    @constructor
    @params {any} props
    @params {RootInterface} root
    ###
    constructor: (props = {}, root) ->

        Object.defineProperty @, 'items',
            value: {}
            enumerable: true

        super(props, root)


    ###*
    check if the model has submodel of the given key or not

    @method has
    @public
    @param {String|Number} key
    @return {Boolean}
    ###
    has: (key) ->
        @items[key]?

    ###*
    check if the model contains the given submodel or not

    @method contains
    @public
    @param {BaseModel} item
    @return {Boolean}
    ###
    contains: (item) ->
        key = @constructor.key item
        sameKeyItem = @get(key)
        sameKeyItem?.equals item


    ###*
    turn on/off the value

    @method toggle
    @param {BaseModel} item
    ###
    toggle: (item) ->
        key = @constructor.key item
        if @has key
            @remove item
        else
            @add item


    ###*
    return submodel of the given key

    @method get
    @public
    @param {String|Number} key
    @return {BaseModel}
    ###
    get: (key) ->
        @items[key]

    ###*
    add item to @items

    @method addItem
    @protected
    @param {BaseModel} item
    ###
    addItem: (item) ->

        key = @constructor.key item
        @items[key] = item


    ###*
    remove submodel from items
    both acceptable, keys and submodels

    @method remove
    @public
    @param {BaseModel|String|Number} item
    ###
    remove: (args...) ->

        ItemClass = @getItemModelClass()

        for arg in args
            if arg instanceof ItemClass
                key = @constructor.key(arg)
            else
                key = arg

            delete @items[key]

        return


    ###*
    removes all items and ids

    @method clear
    ###
    clear: ->

        for key of @items
            delete @items[key]
        super

        return

    ###*
    export models to Array

    @method toArray
    @public
    ###
    toArray: ->
        (item for key, item of @items)


module.exports = BaseDict
