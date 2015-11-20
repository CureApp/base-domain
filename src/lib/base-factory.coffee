'use strict'

Base = require './base'
GeneralFactory = require './general-factory'

###*
Base factory class of DDD pattern.

create instance of model

@class BaseFactory
@extends Base
@implements FactoryInterface
@module base-domain
###
class BaseFactory extends Base

    ###*
    model name to handle

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: null


    getModelName: ->
        @constructor.modelName ? @constructor.getName().slice(0, -'-factory'.length)


    ###*
    constructor

    @constructor
    @params {RootInterface} root
    ###
    constructor: (root) ->

        super(root)

        modelName = @getModelName()
        @gf = new GeneralFactory(modelName, @root)


    @_ModelClass
    getModelClass: ->
        @_ModelClass ?= @gf.getModelClass()

    ###*
    create empty model instance

    @method createEmpty
    @return {BaseModel}
    ###
    createEmpty: -> @gf.createEmpty()


    ###*
    create instance of model class by plain object

    for each prop, values are set by Model#set(prop, value)

    @method createFromObject
    @public
    @param {Object} obj
    @param {Object} [options={}]
    @param {Object} [options.include] options to pass to Includer
    @param {Object} [options.include.async=false] include submodels asynchronously
    @param {Boolean} [options.include.recursive=false] recursively include or not
    @param {Array(String)} [options.include.props] include submodels of given props
    @return {BaseModel} model
    ###
    createFromObject: (obj, options = {}) -> @gf.createFromObject(obj, options)


    ###*
    create model list

    @method createList
    @public
    @param {String} listModelName model name of list
    @param {any} obj
    @param {Object} [options={}]
    @param {Object} [options.include] options to pass to Includer
    @param {Object} [options.include.async=false] include submodels asynchronously
    @param {Boolean} [options.include.recursive=false] recursively include or not
    @param {Array(String)} [options.include.props] include submodels of given props
    @return {BaseList} list
    ###
    createList: (listModelName, obj, options) -> @gf.createList(listModelName, obj, options)


    ###*
    create model dict

    @method createDict
    @public
    @param {String} dictModelName model name of dict
    @param {any} obj
    @param {Object} [options={}]
    @param {Object} [options.include] options to pass to Includer
    @param {Object} [options.include.async=false] include submodels asynchronously
    @param {Boolean} [options.include.recursive=false] recursively include or not
    @param {Array(String)} [options.include.props] include submodels of given props
    @return {BaseDict} dict
    ###
    createDict: (dictModelName, obj, options) -> @gf.createDict(dictModelName, obj, options)


module.exports = BaseFactory
