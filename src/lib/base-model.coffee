'use strict'

TypeInfo = require './type-info'
Base = require './base'
ModelProps = require './model-props'
Util = require '../util'

###*
Base model class of DDD pattern.

@class BaseModel
@extends Base
@module base-domain
###
class BaseModel extends Base

    @isEntity: false

    ###*
    Flag of the model's immutablity
    @static
    @property {Boolean} isImmutable
    ###
    @isImmutable: false

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
        hobbies      : @TYPES.MODEL 'hobby-list'
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
    @method enum
    @public
    @return {Object([key: String => Number])}
    ###
    @enum: (prop) ->
        # TODO Object.assign()
        @properties?[prop]?.numsByValue


    ###*
    @method enum
    @public
    @return {Object}
    ###
    enum: (prop) ->
        @getModelProps().getEnumDic(prop)


    ###*
    @method getModelProps
    @private
    @return {ModelProps}
    ###
    getModelProps: ->
        if @root?
            @facade.getModelProps(@constructor.getName())

        else
            new ModelProps(@constructor.getName(), @constructor.properties, null)


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

        modelProps = @getModelProps()

        # set entity prop
        if modelProps.isEntity(prop)
            subIdProp = modelProps.getIdPropByEntityProp(prop)
            @[subIdProp] = value?.id

        # set submodel id prop
        else if modelProps.isId(prop) and value?
            @[prop] = value
            submodelProp = modelProps.getEntityPropByIdProp(prop)

            # if new submodel id is set and old one exists, delete old one
            if @[submodelProp]? and @[prop] isnt @[submodelProp].id
                @[submodelProp] = undefined

        # set enum
        else if modelProps.isEnum(prop)
            @setEnum(prop, value)

        return @

    ###*
    set enum value

    @method setEnum
    @private
    @param {String} prop
    @param {String|Number} value
    ###
    setEnum: (prop, value) ->

        return if not value?
        modelProps = @getModelProps()
        enums = modelProps.getEnumDic(prop)

        if typeof value is 'string' and enums[value]?
            return @[prop] = enums[value]

        else if typeof value is 'number' and modelProps.getEnumValues(prop)[value]?
            return @[prop] = value

        console.error("""
            base-domain: Invalid value is passed to ENUM prop "#{prop}" in model "#{modelProps.modelName}".
            Value: "#{value}"
            The property was not set.
        """)


    ###*
    unset property

    @method unset
    @param {String} prop property name
    @return {BaseModel} this
    ###
    unset: (prop) ->

        @[prop] = undefined

        modelProps = @getModelProps()

        if modelProps.isEntity(prop)
            subIdProp = modelProps.getIdPropByEntityProp(prop)
            @[subIdProp] = undefined

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

        modelProps = @getModelProps()

        for own prop, value of @

            continue if modelProps.isEntity(prop) or modelProps.isOmitted(prop)

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
    clone the model as a plain object

    @method plainClone
    @public
    @return {Object}
    ###
    plainClone: ->

        plainObject = {}

        modelProps = @getModelProps()

        for own prop, value of @

            if modelProps.isModel and value instanceof BaseModel
                plainObject[prop] = value.plainClone()

            else
                plainObject[prop] = Util.clone value

        return plainObject


    ###*
    create clone

    @method clone
    @public
    @return {BaseModel}
    ###
    clone: ->

        plainObject = @plainClone()
        modelProps = @getModelProps()

        return @facade.createModel modelProps.modelName, plainObject


    ###*
    shallow copy the model with props

    @method copyWith
    @return {BaseModel}
    ###
    copyWith: (props = {})->

        modelProps = @getModelProps()

        obj = {}

        for own prop, value of @
            obj[prop] = value

        for own prop, value of props
            obj[prop] = value

        for entityProp in modelProps.getEntityProps()
            entity = obj[entityProp]
            subIdProp = modelProps.getIdPropByEntityProp(entityProp)
            subId = obj[subIdProp]
            if entity? and entity.id isnt subId
                obj[subIdProp] = entity.id


        modelProps = @getModelProps()
        return @facade.createModel modelProps.modelName, obj



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

        Includer = require './includer'

        new Includer(@, options).include().then => @

    ###*
    Check if all subentities are included.
    @method included
    @return {Boolean}
    ###
    included: (recursive = false) ->

        modelProps = @getModelProps()

        for entityProp in modelProps.getEntityProps()

            subIdProp = modelProps.getIdPropByEntityProp(entityProp)

            return false if @[subIdProp]? and not @[entityProp]?

        return true if not recursive

        for modelProp in modelProps.models

            return false if @[modelProp]? and not @[modelProp].included()

        return true

module.exports = BaseModel
