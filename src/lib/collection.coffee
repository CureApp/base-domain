
ValueObject = require './value-object'

###*
collection model of one model


add      -> addItems -> addItem
setItems -> addItems -> addItem -> emit loaded event

add() is public and setItems is package-level access

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
    ids: get ids of items

    @property {Array(String|Number)} ids
    ###
    Object.defineProperty @::, 'ids',
        get: ->
            return null if not @isItemEntity
            return (item.id for key, item of @items)


    ###*
    the number of items

    @property {Number} length
    @public
    @abstract
    ###

    ###*
    items (submodel collection)

    @property {Object} items
    @abstract
    ###
    items: null



    ###*
    @constructor
    @params {any} props
    @params {RootInterface} root
    ###
    constructor: (props = {}, root) ->

        if not @constructor.itemModelName?
            throw @error 'base-domain:itemModelNameRequired', "@itemModelName is not set, in class #{@constructor.name}"

        super(props, root)

        _itemFactory = null
        isItemEntity = @root.getModel(@constructor.itemModelName).isEntity

        Object.defineProperties @,
            ###*
            item factory
            Created only one time. Be careful that @root is not changed even the collection's root is changed.

            @property {FactoryInterface} itemFactory
            ###
            itemFactory:
                get: -> _itemFactory ?= require('./general-factory').create(@constructor.itemModelName, @root)

            ###*
            loaded: is data loaded or not

            @property loaded
            @type Boolean
            ###
            loaded:
                value: false, writable: true

            isItemEntity:
                value: isItemEntity, writable: false


        if props.items
            @setItems props.items

        if props.ids
            @setIds props.ids


    ###*
    add new submodel to item(s)

    @method add
    @public
    @param {BaseModel|Object} ...items
    ###
    add: (items...) ->
        @addItems(items)


    ###*
    @method addItems
    @param {Object|Array(BaseModel|Object)} items
    @protected
    ###
    addItems: (items = []) ->

        factory = @itemFactory

        for key, item of items
            @addItem(factory.createFromObject item)


    ###*
    add item to @items

    @method addItem
    @protected
    @abstract
    @param {BaseModel} item
    ###
    addItem: (item) ->


    ###*
    set ids.

    @method setIds
    @param {Array(String|Number)} ids
    ###
    setIds: (ids = []) ->

        return if not @isItemEntity

        @loaded = false

        Includer = require './includer'

        repo = new Includer(@).createRepository(@constructor.itemModelName)

        return @ if not repo?

        if repo.constructor.isSync

            subModels = repo.getByIds(ids)
            @setItems(subModels)

        else
            repo.getByIds(ids).then (subModels) =>
                @setItems(subModels)

        return @


    ###*
    set items and emit "loaded" event

    @method setItems
    @param {Object|Array(BaseModel|Object)} items
    ###
    setItems: (items = []) ->

        @addItems(items)

        @loaded = true
        @emitNext('loaded')
        return @


    ###*
    export items to Array

    @method toArray
    @public
    @abstract
    @return {Array}
    ###
    toArray: ->


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

        else
            plainItems = for key, item of @items
                if typeof item.toPlainObject is 'function'
                    item.toPlainObject()
                else
                    item

            plain.items = plainItems

        return plain


    ###*
    get item model
    @method getItemModelClass
    @return {Function}
    ###
    getItemModelClass: ->
        @root.getModel(@constructor.itemModelName)



module.exports = Collection
