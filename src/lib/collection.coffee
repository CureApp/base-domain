
ValueObject = require './value-object'
Ids = require './ids'

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
    ids: get ids of items

    @property {Ids} ids
    ###
    Object.defineProperty @::, 'ids',
        get: ->
            return null if not @constructor.containsEntity()
            return new Ids(item.id for key, item of @items)


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
    loaded: is data loaded or not

    @property loaded
    @type Boolean
    ###


    ###*
    @constructor
    ###
    constructor: (props = {}) ->

        itemModelName = @getItemModelName()

        Object.defineProperty @, 'loaded', value: false, writable: true

        if props.items
            @setItems props.items

        if props.ids
            @setIds props.ids

        super(props)


    ###*
    add model(s)

    @method add
    @param {BaseModel} model
    @abstract
    ###
    add: (models...) ->

    ###*
    set ids.

    @method setIds
    @param {Ids|Array(String|Number)} ids 
    ###
    setIds: (ids = []) ->

        itemModelName = @getItemModelName()

        return if not @constructor.containsEntity()

        @loaded = false
        ItemRepository = @getFacade().getRepository(itemModelName)

        repo = new ItemRepository()

        if ItemRepository.isSync

            subModels = repo.getByIds(ids)
            @setItems(subModels)

        else
            repo.getByIds(ids).then (subModels) =>
                @setItems(subModels)

        return @


    ###*
    set items from dict object
    update to new key

    @method setItems
    @param {Object|Array} models
    ###
    setItems: (models = {}) ->

        items = (item for prevKey, item of models)

        @add items...

        @loaded = true
        @emitNext('loaded')
        return @


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
    export models to Array

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

        if @constructor.containsEntity()
            plain.ids = @ids.toPlainObject()
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
    get item model name
    @method getItemModelName
    @return {String}
    ###
    getItemModelName: ->
        if not @constructor.itemModelName? 
            throw @getFacade().error "@itemModelName is not set, in class #{@constructor.name}"

        return @constructor.itemModelName


    ###*
    get item model
    @method getItemModel
    @return {BaseModel}
    ###
    getItemModel: ->
        @getFacade().getModel(@getItemModelName())



module.exports = Collection
