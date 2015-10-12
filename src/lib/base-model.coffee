

TypeInfo = require './type-info'
ModelProps = require './model-props'
Base  = require './base'
Includer = require './includer'
Id = require './id'

###*
Base model class of DDD pattern.

the parent "Base" class just simply gives a @getFacade() method.


@class BaseModel
@extends Base
@module base-domain
###
class BaseModel extends Base


    @isEntity: false

    ###*
    key-value pair representing typeName - type

    use for definition of @properties for each extender

    @property TYPES
    @protected
    @final
    @static
    @type Object
    ###
    @TYPES: TypeInfo.TYPES


    ###*
    key-value pair representing property's name - type of the model

        firstName    : @TYPES.STRING
        lastName     : @TYPES.STRING
        age          : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        team         : @TYPES.MODEL 'team'
        hobbies      : @TYPES.MODEL_LIST 'hobby'
        info         : @TYPES.ANY

    see type-info.coffee for full options.

    @property properties
    @abstract
    @static
    @protected
    @type Object
    ###
    @properties: {}


    ###*
    extend @properties of Parent class

    @example
        class Parent extends BaseModel
            @properties:
                prop1: @TYPES.STRING


        class ChildModel extends ParentModel

            @properties: @withParentProps
                prop2: @TYPES.NUMBER

        ChildModel.properties # prop1 and prop2


    @method withParentProps
    @protected
    @static
    @return {Object}
    ###
    @withParentProps: (properties = {}) ->
        properties[k] ?= v for k, v of @properties # @properties === parent's properties
        return properties


    ###*
    get an instance of ModelProps, which summarizes properties of this class

    @method getModelProps
    @public
    @return {ModelProps}
    ###
    @_props: null
    @getModelProps: ->
        @_props ?= new ModelProps @properties, @getFacade()


    ###*
    @constructor
    @params {any} obj
    @params {RootInterface} root
    ###
    constructor: (obj, root) ->

        super(root)

        @set obj if obj


    ###*
    set value to prop
    @return {BaseModel} this
    ###
    set: (prop, value) ->
        if typeof prop is 'object'
            @set(k, v) for k, v of prop
            return @

        @[prop] = value

        modelProps = @constructor.getModelProps()

        # set entity prop
        if modelProps.isEntity(prop)
            typeInfo = modelProps.getTypeInfo(prop)
            @[typeInfo.idPropName] = new Id(value?.id)

        # set submodel id prop
        else if modelProps.isId(prop)
            @[prop] = new Id(value)
            submodelProp = modelProps.submodelOf(prop)

            # if new submodel id is set and old one exists, delete old one
            if @[submodelProp]? and not @[prop].equals @[submodelProp].id
                @[submodelProp] = undefined

        return @


    ###*
    unset property

    @method unset
    @param {String} prop property name
    @return {BaseModel} this
    ###
    unset: (prop) ->

        @[prop] = undefined

        modelProps = @constructor.getModelProps()

        if modelProps.isEntity(prop)
            typeInfo = modelProps.getTypeInfo(prop)
            @[typeInfo.idPropName] = undefined

        return @


    ###*
    inherit value of anotherModel

    @method inherit
    @param {BaseModel} anotherModel
    @return {BaseModel} this
    ###
    inherit: (anotherModel) ->

        @set(k, v) for own k, v of anotherModel when v?

        return @


    ###*
    create plain object without relational entities
    descendants of Entity are removed, but not descendants of BaseModel
    descendants of Entity in descendants of BaseModel are removed ( = recursive)

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        plainObject = {}

        modelProps = @constructor.getModelProps()

        for own prop, value of @

            continue if modelProps.isEntity(prop) or modelProps.isTmp(prop)

            if typeof value?.toPlainObject is 'function'
                plainObject[prop] = value.toPlainObject()

            else
                plainObject[prop] = value

        return plainObject


    ###*
    check equality

    @method equals
    @param {BaseModel} model
    @return {Boolean}
    ###
    equals: (model) ->
        model? and @constructor is model.constructor


    ###*
    include all relational models if not set

    @method include
    @param {Object} [options]
    @param {Boolean} [options.recursive] recursively include models or not
    @param {Boolean} [options.async=true] get async values
    @param {Array(String)} [options.props] include only given props
    @return {Promise(BaseModel)} self
    ###
    include: (options = {}) ->

        new Includer(@).include(options).then =>
            @emit('included')
            return @


module.exports = BaseModel
