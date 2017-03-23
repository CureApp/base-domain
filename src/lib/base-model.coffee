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
    set value to prop and create a new model
    @method $set
    @return {BaseModel} this
    ###
    $set: (prop, value) ->
        if typeof prop is 'object'
            return @copyWith(prop)

        props = {}
        props[prop] = value
        return @copyWith(props)


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
    unset property and create a new model

    @method $unset
    @param {String} prop property name
    @return {BaseModel} this
    ###
    $unset: (prop) ->
        props = {}
        props[prop] = null

        modelProps = @getModelProps()

        if modelProps.isEntity(prop)
            subIdProp = modelProps.getIdPropByEntityProp(prop)
            props[subIdProp] = null

        return @copyWith(props)


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
            if value?
                obj[prop] = value
            else
                delete obj[prop]

        for entityProp in modelProps.getEntityProps()
            entity = obj[entityProp]
            subIdProp = modelProps.getIdPropByEntityProp(entityProp)
            subId = obj[subIdProp]
            if entity? and entity.id isnt subId
                obj[subIdProp] = entity.id


        modelProps = @getModelProps()
        return @facade.createModel modelProps.modelName, obj


    ###*
    Get diff prop values

    @method getDiff
    @public
    @param {any} plainObj
    @param {Object} [options]
    @param {Array(String)} [options.ignores] prop names to skip checking diff
    @return {Object}
    ###
    getDiff: (plainObj = {}, options = {}) ->

        @getDiffProps(plainObj, options).reduce (obj, prop) ->
            obj[prop] = plainObj[prop]
            return obj
        , {}

    ###*
    Get diff props

    @method diff
    @public
    @param {any} plainObj
    @param {Object} [options]
    @param {Array(String)} [options.ignores] prop names to skip checking diff
    @return {Array(String)}
    ###
    getDiffProps: (plainObj = {}, options = {}) ->

        return Object.keys(@) if not plainObj? or typeof plainObj isnt 'object'

        diffProps = []
        modelProps = @getModelProps()

        ignores = {}
        ignores[prop] = true for prop in options.ignores if Array.isArray(options.ignores)

        propsToCheck = modelProps.getAllProps().filter (prop) ->
            not ignores[prop] and not modelProps.isEntity(prop)

        for prop in propsToCheck
            thisValue = @[prop]
            thatValue = plainObj[prop]

            if not thisValue?
                continue if not thatValue?

            if not thatValue? or not thisValue?
                diffProps.push(prop)
                continue

            continue if thisValue is thatValue

            # if
            continue if modelProps.isEntity(prop) and thisValue[prop]? and not thatValue?

            if modelProps.isId(prop)
                entityProp = modelProps.getEntityPropByIdProp(prop)
                if thisValue isnt thatValue
                    diffProps.push(prop, entityProp)
                    continue
                thisEntityValue = @[entityProp]
                thatEntityValue = plainObj[entityProp]

                if not thisEntityValue?
                    diffProps.push(entityProp) if thatEntityValue?
                    continue

                else if typeof thisEntityValue.isDifferentFrom is 'function'
                    diffProps.push(entityProp) if thisEntityValue.isDifferentFrom(thatEntityValue)
                    continue
                else
                    diffProps.push(entityProp) # rare case when value of entity prop isn't entity

            else if modelProps.isDate(prop)
                thisISOValue = if typeof thisValue.toISOString is 'function' then thisValue.toISOString() else thisValue
                thatISOValue = if typeof thatValue.toISOString is 'function' then thatValue.toISOString() else thatValue
                continue if thisISOValue is thatISOValue

            else if modelProps.isEnum(prop)
                thatEnumValue = if typeof thatValue is 'string' then @enum(prop)[thatValue] else thatValue
                continue if thisValue is thatEnumValue

            else if typeof thisValue.isDifferentFrom is 'function'
                continue if not thisValue.isDifferentFrom(thatValue)

            else
                continue if Util.deepEqual(thisValue, thatValue)

            diffProps.push(prop)

        return diffProps


    ###*
    Get difference props

    @method diff
    @public
    @param {any} plainObj
    @return {Array(String)}
    ###
    isDifferentFrom: (val) ->
        return @getDiffProps(val).length > 0


    ###*
    freeze the model
    ###
    freeze: ->
        throw @error('FreezeMutableModel', 'Cannot freeze mutable model.') if not @constructor.isImmutable
        return Object.freeze(@)

    ###*
    include all relational models if not set

    @method include
    @param {Object} [options]
    @param {Boolean} [options.async=true] get async values
    @param {Array(String)} [options.props] include only given props
    @return {Promise(BaseModel)} self
    ###
    include: (options = {}) ->

        Includer = require './includer'

        new Includer(@, options).include().then => @


    ###*
    include all relational models and returns new model

    @method $include
    @param {Object} [options]
    @param {Boolean} [options.async=true] get async values
    @param {Array(String)} [options.props] include only given props
    @return {Promise(BaseModel)} new model
    ###
    $include: (options = {}) ->

        Includer = require './includer'

        new Includer(@, options).include(createNew = true)


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
