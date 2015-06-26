
BaseFactory = require './base-factory'


###*
factory of list

@class ListFactory
@extends Base
@module base-domain
###
class ListFactory extends BaseFactory

    ###*
    create instance
    ###
    @create: (listModelName, itemFactory) ->
        new ListFactory(listModelName, itemFactory)


    ###*
    @constructor
    ###
    constructor: (@listModelName, @itemFactory) ->
        @getFacade = -> @itemFactory.getFacade()
        super


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Function}
    ###
    getModelClass: ->
        @getFacade().getModel(@listModelName)


    ###*
    creates an instance of BaseList by value

    @method createFromObject
    @public
    @param {any} obj
    @return {BaseList}
    ###
    createFromObject: (obj) ->

        if not obj? or typeof obj isnt 'object'
            return @createEmpty()

        if Array.isArray obj
            return @createFromArray(obj)

        ListModel = @getModelClass()

        { ids, items } = obj

        if items
            delete obj.items
            items = (@createItemFromObject item for item in items)
            list = super(obj).setItems items
            obj.items = items

        else if ListModel.containsEntity()
            delete obj.ids
            list = super(obj).setIds ids
            obj.ids = ids
        else
            return super(obj)

        return list


    ###*
    creates an instance of BaseList from array

    @method createFromArray
    @public
    @param {Array} arr
    @return {BaseList}
    ###
    createFromArray: (arr) ->

        ListModel = @getModelClass()

        firstValue = arr[0]

        if not firstValue?
            return @createEmpty()

        if typeof firstValue is 'object'
            items = (@createItemFromObject obj for obj in arr)
            return new ListModel().setItems items

        if ListModel.containsEntity()
            return new ListModel().setIds arr

        throw new Error "cannot create #{@constructor.modelName} with arr\n [#{arr.toString()}]"

    ###*
    creates an instance of BaseList by value

    @method createEmpty
    @private
    @return {BaseList}
    ###
    createEmpty: ->

        ListModel = @getModelClass()
        return new ListModel().setItems()


    ###*
    create item model

    @method createItemFromObject
    @return {BaseModel}
    ###
    createItemFromObject: (obj) ->
        return @itemFactory.createFromObject(obj)


module.exports = ListFactory
