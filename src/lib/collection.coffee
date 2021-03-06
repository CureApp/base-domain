'use strict'

ValueObject = require './value-object'
EntityPool = require '../entity-pool'
BaseModel = require './base-model'
Util = require '../util'

###*
collection model of one model

@class Collection
@extends ValueObject
@module base-domain
###
class Collection extends ValueObject

    ###*
    model name of the item

    @property itemModelName
    @static
    @protected
    @type String
    ###
    @itemModelName: null


    ###*
    the number of items (or ids when @isItemEntity is true)

    @property {Number} length
    @public
    ###
    Object.defineProperty @::, 'length',
        get: ->
            if @isItemEntity
                return @ids.length
            else
                return @itemLength



    ###*
    items (submodel collection)

    @property {Object} items
    @abstract
    ###


    ###*
    @constructor
    @params {any} props
    @params {RootInterface} root
    ###
    constructor: (props = {}, root) ->

        @setRoot(root)

        if not @constructor.itemModelName?
            throw @error 'base-domain:itemModelNameRequired', "@itemModelName is not set, in class #{@constructor.name}"

        _itemFactory = null
        isItemEntity = @facade.getModel(@constructor.itemModelName).isEntity

        Object.defineProperties @,

            ###*
            item factory
            Created only one time. Be careful that @root is not changed even the collection's root is changed.

            @property {FactoryInterface} itemFactory
            ###
            itemFactory:
                get: -> _itemFactory ?= require('./general-factory').create(@constructor.itemModelName, @root)

            isItemEntity:
                value: isItemEntity, writable: false


        @clear()

        if props.ids? and props.items
            { ids } = props
            delete props.ids
            super(props, root)
            props.ids = ids
        else
            super(props, root)


    ###*
    Get the copy of ids
    @return {Array(String)} ids
    ###
    getIds: ->
        return undefined if not @isItemEntity

        return @ids?.slice()


    ###*
    set value to prop
    @return {BaseModel} this
    ###
    set: (k, v) ->
        switch k
            when 'items'
                @setItems v
            when 'ids'
                @setIds v
            else
                super
        return @


    ###*
    add new submodel to item(s)

    @method add
    @public
    @param {BaseModel|Object} ...items
    ###
    add: (items...) ->
        @addItems(items)


    ###*
    add submodels and create new collection

    @method add
    @public
    @param {BaseModel|Object} ...items
    @return {Collection}
    ###
    $add: (items...) ->
        newItems = @toArray().concat(items)
        return @copyWith(items: newItems)


    ###*
    @method addItems
    @param {Object|Array(BaseModel|Object)} items
    @protected
    ###
    addItems: (items = []) ->

        @initItems() if not @loaded()

        factory = @itemFactory

        for key, item of items
            @addItem(factory.createFromObject item)

        if @isItemEntity
            @ids = (item.id for item in @toArray())


    ###*
    add item to @items

    @method addItem
    @protected
    @abstract
    @param {BaseModel} item
    ###
    addItem: (item) ->


    ###*
    clear and set ids.

    @method setIds
    @param {Array(String|Number)} ids
    @chainable
    ###
    setIds: (ids = []) ->

        return if not @isItemEntity
        return if not Array.isArray ids

        @clear()
        @ids = ids


    ###*
    clear and add items

    @method setItems
    @param {Object|Array(BaseModel|Object)} items
    ###
    setItems: (items = []) ->

        @clear()
        @addItems(items)

        return @


    ###*
    removes all items and ids

    @method clear
    ###
    clear: ->
        delete @items
        if @isItemEntity
            @ids = []

    ###*
    removes all items and create a new collection

    @method clear
    ###
    $clear: ->
        @copyWith(items: [])


    ###*
    export items to Array

    @method toArray
    @public
    @abstract
    @return {Array}
    ###
    toArray: ->


    ###*
    Execute given function for each item

    @method forEach
    @public
    @param {Function} fn
    @param {Object} _this
    ###
    forEach: (fn, _this) ->
        @map(fn, _this)
        return

    ###*
    Execute given function for each item
    returns an array of the result

    @method map
    @public
    @param {Function} fn
    @param {Object} _this
    @return {Array}
    ###
    map: (fn, _this) ->
        _this ?= @
        return [] if typeof fn isnt 'function'
        (fn.call(_this, item) for item in @toArray())


    ###*
    Filter items with given function

    @method filter
    @public
    @param {Function} fn
    @param {Object} _this
    @return {Array}
    ###
    filter: (fn, _this) ->
        _this ?= @
        return @toArray() if typeof fn isnt 'function'
        @toArray().filter(fn, _this)


    ###*
    Returns if some items match the condition in given function

    @method some
    @public
    @param {Function} fn
    @param {Object} _this
    @return {Boolean}
    ###
    some: (fn, _this) ->
        _this ?= @
        return false if typeof fn isnt 'function'
        @toArray().some(fn, _this)


    ###*
    Returns if every items match the condition in given function

    @method every
    @public
    @param {Function} fn
    @param {Object} _this
    @return {Boolean}
    ###
    every: (fn, _this) ->
        _this ?= @
        return false if typeof fn isnt 'function'
        @toArray().every(fn, _this)



    initItems: ->


    ###*
    include all relational models if not set

    @method include
    @param {Object} [options]
    @param {Boolean} [options.async=true] get async values
    @param {Array(String)} [options.props] include only given props
    @return {Promise(BaseModel)} self
    ###
    include: (options = {}) ->

        options.entityPool ?= new EntityPool

        superResult = super(options)

        return superResult if not @isItemEntity

        return @includeEntityItems(options, superResult)


    includeEntityItems: (options, superResult) ->

        EntityCollectionIncluder = require './entity-collection-includer'

        Promise.all([
            superResult
            new EntityCollectionIncluder(@, options).include()
        ]).then => @


    ###*
    freeze the model
    ###
    freeze: ->
        throw @error('FreezeMutableModel', 'Cannot freeze mutable model.') if not @constructor.isImmutable
        if @loaded
            Object.freeze(@items)
            return Object.freeze(@)
        else
            return @include().then =>
                Object.freeze(@items)
                return Object.freeze(@)



    ###*
    create plain object.
    if this dict contains entities, returns their ids
    if this dict contains non-entity models, returns their plain objects

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        plain = super()

        if @isItemEntity
            plain.ids = @ids.slice()
            delete plain.items

        else if @loaded()

            plainItems = for key, item of @items
                if typeof item.toPlainObject is 'function'
                    item.toPlainObject()
                else
                    item

            plain.items = plainItems

        return plain


    ###*
    create plain array.

    @method toPlainArray
    @return {Array} plainArray
    ###
    toPlainArray: ->

        if @isItemEntity
            return @ids.slice()

        else if @loaded()
            items = []
            for key, item of @items
                if typeof item.toPlainObject is 'function'
                    items.push item.toPlainObject()
                else
                    items.push item
            return items
        else
            return []

    ###*
    clone the model as a plain object

    @method clone
    @return {BaseModel}
    ###
    plainClone: ->

        plain = super()

        if @loaded()
            plain.items = for key, item of @items
                if item instanceof BaseModel
                    item.plainClone()
                else
                    item

        return plain


    ###*
    @method loaded
    @public
    @return {Boolean}
    ###
    loaded: -> @items?


    ###*
    get item model
    @method getItemModelClass
    @return {Function}
    ###
    getItemModelClass: ->
        @facade.getModel(@constructor.itemModelName)


    getDiffProps: (plainObj = {}) ->
        thatObj = {}

        if Array.isArray(plainObj)
            if plainObj.length is 0
                thatObj.items = []
            else if typeof plainObj[0] is 'object'
                thatObj.items = plainObj
            else
                thatObj.ids = plainObj
        else
            thatObj = plainObj

        ret = super(thatObj)

        if @isItemEntity and thatObj.ids
            ret.push('ids') if @isIdsDifferent(thatObj.ids)
            return ret

        else if @isItemsDifferent(thatObj.items)
            ret.push('items')
            return ret

        return ret


    isItemsDifferent: (items) ->
        return @itemLength > 0 if not Array.isArray(items)
        return true if @itemLength isnt items.length

        return @some (item, i) ->
            if typeof item.isDifferentFrom is 'function'
                item.isDifferentFrom(items[i])
            else
                not Util.deepEqual(item, items[i])

    isIdsDifferent: (ids) ->
        return @length > 0 if not Array.isArray(ids)
        return not Util.deepEqual(@ids, ids)

module.exports = Collection
