
ValueObject = require './value-object'
Ids = require './ids'

###*
list class of DDD pattern.

@class BaseList
@extends ValueObject
@module base-domain
###
class BaseList extends ValueObject

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

    @property ids
    @type Array(Id)
    @public
    ###
    Object.defineProperty @::, 'ids',
        get: ->
            return null if not @constructor.containsEntity()
            return new Ids(item.id for key, item of @items)


    ###*
    the number of items

    @property length
    @type number
    @public
    ###
    Object.defineProperty @::, 'length',
        get: ->
            return @items.length


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
    itemFactory: instance of factory which creates item models

    @property itemFactory
    @type BaseFactory
    ###

    ###*
    @constructor
    ###
    constructor: (props = {}) ->

        itemModelName = @getItemModelName()

        # loaded and listeners are hidden properties
        _itemFactory = null
        Object.defineProperties @, 
            items       : value: [], enumerable: true
            loaded      : value: false, writable: true
            listeners   : value: []
            itemFactory : get: ->
                _itemFactory ?= @getFacade().createFactory(itemModelName, true)

        if props.items
            @setItems props.items

        if props.ids
            @setIds props.ids

        super(props)


    ###*
    set ids.

    @method setIds
    @param {Array(String|Number)} ids 
    ###
    setIds: (ids = []) ->

        return if not @constructor.containsEntity()

        @loaded = false
        itemModelName = @getItemModelName()
        ItemRepository = @getFacade().getRepository(itemModelName)

        if ItemRepository.aggreate
            pntRepo = new ItemRepository.aggregate

        repo = new ItemRepository()

        if ItemRepository.storeMasterTable and ItemRepository.loaded()

            subModels = (repo.getByIdSync(id) for id in ids)
            @setItems(subModels)

        else
            repo.query(where: id: inq: ids).then (subModels) =>
                @setItems(subModels)

        return @

    ###*
    add model(s)

    @method add
    @param {BaseModel} model
    ###
    add: (models...) ->

        @setItems(models)


    ###*
    set items

    @method setItems
    @param {Array} models
    ###
    setItems: (models = []) ->
        itemModelName = @getItemModelName()
        ItemClass = @getFacade().getModel itemModelName

        @items.push item for item in models when item instanceof ItemClass

        @items.sort(@sort) if @sort

        @loaded = true
        @emitLoaded()
        return @


    ###*
    clear all models

    @method clear
    ###
    clear: ->

        len = @length

        @items.pop() for i in [0...len] 

        return


    ###*
    remove item by index

    @method remove
    @param {Number} index
    ###
    remove: (index) ->

        @items.splice(index, 1)



    ###*
    returns item is Entity

    @method containsEntity
    @static
    @public
    @return {Boolean}
    ###
    @containsEntity: ->
        if not @itemModelName? 
            throw @getFacade().error "@itemModelName is not set, in class #{@name}"

        return @getFacade().getModel(@itemModelName).isEntity


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

        plain = super()

        if @constructor.containsEntity()
            plain.ids = @ids.toPlainObject()
            delete plain.items

        else
            plainItems = []
            for item in @items
                if typeof item.toPlainObject is 'function'
                    plainItems.push item.toPlainObject()
                else
                    plainItems.push item

            plain.items = plainItems

        return plain


    ###*
    on addEventListeners for 'loaded'

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


    getItemModelName: ->
        if not @constructor.itemModelName? 
            throw @getFacade().error "@itemModelName is not set, in class #{@constructor.name}"

        return @constructor.itemModelName

module.exports = BaseList
