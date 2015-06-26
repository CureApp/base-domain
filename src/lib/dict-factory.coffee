
BaseFactory = require './base-factory'


###*
factory of dict

@class DictFactory
@extends BaseFactory
@module base-domain
###
class DictFactory extends BaseFactory

    ###*
    create instance
    ###
    @create: (dictModelName, itemFactory) ->
        new DictFactory(dictModelName, itemFactory)

    ###*
    @constructor
    ###
    constructor: (@dictModelName, @itemFactory) ->
        @getFacade = -> @itemFactory.getFacade()
        super


    ###*
    get model class this factory handles

    @method getModelClass
    @return {Function}
    ###
    getModelClass: ->
        @getFacade().getModel(@dictModelName)



    ###*
    creates an instance of BaseDict by value

    @method createFromObject
    @public
    @param {any} obj
    @return {BaseDict}
    ###
    createFromObject: (obj) ->

        if not obj? or typeof obj isnt 'object'
            return @createEmpty()

        if Array.isArray obj
            return @createFromArray(obj)

        DictModel = @getModelClass()

        { ids, items } = obj

        if items
            delete obj.items
            items = (@createItemFromObject item for key, item of items)
            dict = super(obj).setItems items
            obj.items = items

        else if DictModel.containsEntity()
            delete obj.ids
            dict = super(obj).setIds ids
            obj.ids = ids
        else
            return super(obj)

        return dict


    ###*
    creates an instance of BaseDict from array

    @method createFromArray
    @public
    @param {Array} arr
    @return {BaseDict}
    ###
    createFromArray: (arr) ->

        DictModel = @getModelClass()

        firstValue = arr[0]

        if not firstValue?
            return @createEmpty()

        if typeof firstValue is 'object'
            items = (@createItemFromObject obj for obj in arr)
            return new DictModel().setItems items

        if DictModel.containsEntity()
            return new DictModel().setIds arr

        throw new Error "cannot create #{@constructor.modelName} with arr\n [#{arr.toString()}]"

    ###*
    creates an instance of BaseDict by value

    @method createEmpty
    @private
    @return {BaseDict}
    ###
    createEmpty: ->

        DictModel = @getModelClass()
        return new DictModel().setItems()


    ###*
    create item model

    @method createItemFromObject
    @return {BaseModel}
    ###
    createItemFromObject: (obj) ->
        return @itemFactory.createFromObject(obj)


module.exports = DictFactory
