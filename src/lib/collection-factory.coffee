
GeneralFactory = require './general-factory'

###*
factory of Collection

@class CollectionFactory
@extends GeneralFactory
@module base-domain
###
class CollectionFactory extends GeneralFactory

    ###*
    @constructor
    ###
    constructor: ->
        super
        @itemFactory = @root.createFactory(@getModelClass().itemModelName)


    ###*
    creates an instance of Collection by value

    @method createFromObject
    @public
    @param {any} obj
    @return {Collection}
    ###
    createFromObject: (obj) ->

        if not obj? or typeof obj isnt 'object'
            return @createEmpty()

        if Array.isArray obj
            return @createFromArray(obj)

        Collection = @getModelClass()

        { ids, items } = obj

        if items
            delete obj.items
            items = (@createItemFromObject item for key, item of items)
            coll = super(obj).setItems items
            obj.items = items

        else if Collection.containsEntity()
            delete obj.ids
            coll = super(obj).setIds ids
            obj.ids = ids
        else
            return super(obj)

        return coll


    ###*
    creates an instance of Collection from array

    @method createFromArray
    @public
    @param {Array} arr
    @return {Collection}
    ###
    createFromArray: (arr) ->

        firstValue = arr[0]

        if not firstValue?
            return @createEmpty()

        if typeof firstValue is 'object'
            items = (@createItemFromObject obj for obj in arr)
            return @create().setItems items

        if @getModelClass().containsEntity()
            return @create().setIds arr

        throw new Error "cannot create #{@modelName} with arr\n [#{arr.toString()}]"


    ###*
    creates an instance of Collection by value

    @method createEmpty
    @private
    @return {Collection}
    ###
    createEmpty: ->

        @create().setItems() # setItems to emit "loaded" event


    ###*
    create item model

    @method createItemFromObject
    @return {BaseModel}
    ###
    createItemFromObject: (obj) ->
        return @itemFactory.createFromObject(obj)


module.exports = CollectionFactory
