
ValueObject = require './value-object'

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

    @property {Array(String|Number)} ids
    ###
    Object.defineProperty @::, 'ids',
        get: ->
            return null if not @constructor.containsEntity()
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
    loaded: is data loaded or not

    @property loaded
    @type Boolean
    ###


    ###*
    @constructor
    @params {any} props
    @params {RootInterface} root
    ###
    constructor: (props = {}, root) ->

        if not @constructor.itemModelName? 
            throw @getFacade().error "@itemModelName is not set, in class #{@constructor.name}"

        super(props, root)

        Object.defineProperty @, 'loaded', value: false, writable: true

        if props.items
            @setItems props.items

        if props.ids
            @setIds props.ids


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
    @param {Array(String|Number)} ids 
    ###
    setIds: (ids = []) ->

        return if not @constructor.containsEntity()

        @loaded = false

        repo = @root.createRepository(@constructor.itemModelName)

        if repo.constructor.isSync

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

        @root.getModel(@itemModelName).isEntity



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
    @return {BaseModel}
    ###
    getItemModelClass: ->
        @root.getModel(@constructor.itemModelName)



module.exports = Collection
