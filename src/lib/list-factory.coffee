
BaseList = require './base-list'
BaseFactory = require './base-factory'


###*
factory of list

@class ListFactory
@extends Base
@module base-domain
###
class ListFactory extends BaseFactory


    ###*
    get anonymous list factory class

    @method getAnonymousClass
    @param {String} modelName
    @param {String} itemModelName
    @return {Function}
    ###
    @getAnonymousClass: (modelName, itemModelName) ->

        class AnonymousListFactory extends ListFactory
            @modelName     : modelName
            @itemModelName : itemModelName
            @isAnonymous   : true

        return AnonymousListFactory

    ###*
    get model class this factory handles

    @method getModelClass
    @return {Class}
    ###
    @_ModelClass: undefined
    getModelClass: ->
        {modelName, itemModelName} = @constructor
        @_ModelClass ?= @getFacade().getListModel(modelName, itemModelName)


    ###*
    creates an instance of BaseList by value

    @method createList
    @public
    @param {any} value
    @return {BaseList}
    ###
    createList: (value) ->

        if not value? or typeof value isnt 'object'
            return @createEmpty()

        if not Array.isArray value
            return @createFromObject(value)

        return @createFromArray(value)



    ###*
    creates an instance of BaseList from array

    @method createFromArray
    @private
    @param {Array} arr
    @return {BaseList}
    ###
    createFromArray: (arr) ->

        ListModel = @getModelClass()

        firstValue = arr[0]

        if not firstValue?
            return @createEmpty()

        if typeof firstValue is 'object'
            return @createFromObjectList(arr)

        if ListModel.containsEntity()
            return @createFromIds(arr)

        throw new Error "cannot create #{@constructor.modelName} with arr\n [#{arr.toString()}]"

    ###*
    creates an instance of BaseList by value

    @method createEmpty
    @private
    @return {BaseList}
    ###
    createEmpty: ->

        ListModel = @getModelClass()
        return new ListModel()


    ###*
    creates an instance of BaseList by value

    @method createFromObject
    @private
    @params {Object} obj
    @return {BaseList}
    ###
    createFromObject: (obj) ->

        if obj.items and Array.isArray obj.items

            return @createFromArray(obj.items)

        if obj.ids and Array.isArray obj.ids

            return @createFromArray(obj.ids)

        # regard the obj as (pre)model
        objList = [obj]
        return @createFromObjectList objList


    ###*
    creates an instance of BaseList by value

    @method createFromObjectList
    @private
    @params {Array(Object)} objList
    @return {BaseList}
    ###
    createFromObjectList: (objList) ->

        itemFactory = @getFacade().createFactory(@constructor.itemModelName, true)

        SubModel = itemFactory.getModelClass()

        subModels = (itemFactory.createFromObject(subObj) for subObj in objList)

        ListModel = @getModelClass()

        return new ListModel(subModels)


    ###*
    creates an instance of BaseList by value

    @method createFromIds
    @private
    @params {Array(String|Number)} ids
    @return {BaseList}
    ###
    createFromIds: (ids) ->

        ListModel = @getModelClass()
        ItemRepository = @getFacade().getRepository(@constructor.itemModelName)

        repo = new ItemRepository()

        if ItemRepository.storeMasterTable and ItemRepository.loaded()

            items = (repo.getByIdSync(id) for id in ids)

            return new ListModel(items)

        else

            modelsPromise = repo.query(where: id: inq: ids)

            return new ListModel(modelsPromise)

module.exports = ListFactory
