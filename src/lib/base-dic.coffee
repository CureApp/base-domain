
BaseModel = require './base-model'

###*
dictionary-structured data model

@class BaseDic
@extends BaseModel
@module base-domain
###
class BaseDic extends BaseModel

    ###*
    model name of the item

    @property itemModelName
    @static
    @protected
    @type String
    ###
    @itemModelName: ''

    ###*
    get unique key from item

    @method key
    @static
    @protected
    ###
    @key: (item) -> item.id


    ###*
    creates child class of BaseDic

    @method getAnonymousClass
    @params {String} itemModelName
    @return {Function} child class of BaseDic
    ###
    @getAnonymousClass: (itemModelName) ->

        class AnonymousDic extends BaseDic
            @itemModelName: itemModelName
            @isAnonymous: true

        return AnonymousDic


    ###*
    ids: get ids of items

    @property ids
    @type Array
    @public
    ###
    Object.defineProperty @::, 'ids',
        get: ->
            return null if not @constructor.containsEntity()
            return (item.id for key, item of @items)

    ###*
    items: dictionary of keys - models 

    @property items
    @type Objects
    ###

    ###*
    loaded: is data loaded or not

    @property loaded
    @type Boolean
    ###

    ###*
    itemFactory: instance of factory which creates item models

    @property itemFactory
    @type BaseFactory
    ###

    ###*
    @constructor
    ###
    constructor: (props = {}) ->

        # loaded and listeners are hidden properties
        _itemFactory = null
        Object.defineProperties @, 
            items       : value: {}, enumerable: true
            loaded      : value: false, writable: true
            listeners   : value: []
            itemFactory : get: ->
                _itemFactory ?= @getFacade().createFactory(@constructor.itemModelName, true)

        if props.items
            @setItems props.items

        if props.ids
            @setIds props.ids

        super(props)


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
        item is sameKeyItem


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
    add new submodel to item(s)

    @method get
    @public
    @param {BaseModel} item
    ###
    add: (items...) ->
        ItemClass = @getFacade().getModel @constructor.itemModelName
        for prevKey, item of items when item instanceof ItemClass
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
        ItemClass = @getFacade().getModel @constructor.itemModelName

        for arg in args
            if arg instanceof ItemClass
                key = @constructor.key(arg)
            else
                key = arg

            delete @items[key]

        return



    ###*
    set ids.

    @method setIds
    @param {Array(String|Number)} ids 
    ###
    setIds: (ids = []) ->

        return if not @constructor.containsEntity()

        @loaded = false
        ItemRepository = @getFacade().getRepository(@constructor.itemModelName)

        repo = new ItemRepository()

        if ItemRepository.storeMasterTable and ItemRepository.loaded()

            subModels = (repo.getByIdSync(id) for id in ids)
            @setItems(subModels)

        else
            repo.query(where: id: inq: ids).then (subModels) =>
                @setItems(subModels)

        return @


    ###*
    set items from dic object
    update to new key

    @method setItems
    @param {Object|Array} models
    ###
    setItems: (models = {}) ->

        items = (item for prevKey, item of models)
        @add items...

        @loaded = true
        @emitLoaded()
        return @


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
    export models to Array

    @method toArray
    @public
    ###
    toArray: ->
        (item for key, item of @items)


    ###*
    create plain dic.
    if this dic contains entities, returns their ids
    if this dic contains non-entity models, returns their plain objects 

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        plain = super()

        if @constructor.containsEntity()
            plain.ids = @ids
            delete plain.items

        else
            plainItems = []
            for key, item of @items
                if typeof item.toPlainObject is 'function'
                    plainItems[key] = item.toPlainObject()
                else
                    plainItems[key] = item

            plain.items = plainItems

        return plain


    ###*
    on addEventlisteners for 'loaded'

    @method on
    @public
    ###
    on: (evtname, fn) ->
        return if evtname isnt 'loaded'

        if @loaded
            process.nextTick fn
        else if typeof fn is 'function'
            @listeners.push fn
        return


    ###*
    tell listeners emit loaded
    @method emitLoaded
    @private
    ###
    emitLoaded: ->
        while fn = @listeners.shift()
            process.nextTick fn
        return

module.exports = BaseDic
