
BaseFactory = require './base-factory'


###*
factory of dic

@class DicFactory
@extends BaseFactory
@module base-domain
###
class DicFactory extends BaseFactory

    ###*
    create instance
    ###
    @create: (dicModelName, itemFactory) ->
        new DicFactory(dicModelName, itemFactory)

    ###*
    @constructor
    ###
    constructor: (@dicModelName, @itemFactory) ->
        super


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Function}
    ###
    getModelClass: ->
        @getFacade().getModel(@dicModelName)



    ###*
    creates an instance of BaseDic by value

    @method createFromObject
    @public
    @param {any} obj
    @return {BaseDic}
    ###
    createFromObject: (obj) ->

        if not obj? or typeof obj isnt 'object'
            return @createEmpty()

        if Array.isArray obj
            return @createFromArray(obj)

        DicModel = @getModelClass()

        { ids, items } = obj

        if items
            delete obj.items
            items = (@createItemFromObject item for key, item of items)
            dic = super(obj).setItems items
            obj.items = items

        else if DicModel.containsEntity()
            delete obj.ids
            dic = super(obj).setIds ids
            obj.ids = ids
        else
            return super(obj)

        return dic


    ###*
    creates an instance of BaseDic from array

    @method createFromArray
    @public
    @param {Array} arr
    @return {BaseDic}
    ###
    createFromArray: (arr) ->

        DicModel = @getModelClass()

        firstValue = arr[0]

        if not firstValue?
            return @createEmpty()

        if typeof firstValue is 'object'
            items = (@createItemFromObject obj for obj in arr)
            return new DicModel().setItems items

        if DicModel.containsEntity()
            return new DicModel().setIds arr

        throw new Error "cannot create #{@constructor.modelName} with arr\n [#{arr.toString()}]"

    ###*
    creates an instance of BaseDic by value

    @method createEmpty
    @private
    @return {BaseDic}
    ###
    createEmpty: ->

        DicModel = @getModelClass()
        return new DicModel().setItems()


    ###*
    create item model

    @method createItemFromObject
    @return {BaseModel}
    ###
    createItemFromObject: (obj) ->
        return @itemFactory.createFromObject(obj)


module.exports = DicFactory
