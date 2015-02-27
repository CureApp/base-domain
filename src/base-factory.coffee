

Base  = require './base'
TYPES = require './types'

###*
Base factory class of DDD pattern.

create instance of model

the parent "Base" class just simply gives a @facade property.

@class BaseFactory
@extends Base
@module base-domain
###
class BaseFactory extends Base

    ###*
    model class to create

    @property ModelClass
    @static
    @protected
    @type Model
    ###
    @ModelClass: null


    ###*
    create instance of ModelClass by plain object

    for each prop, values are modified by @modifyValueByPropName()

    @method createFromObject
    @public
    @param {Object} obj
    @return {Model} model
    ###
    createFromObject: (obj) ->

        if not obj? or typeof obj isnt 'object'
            return null

        ModelClass = @constructor.ModelClass
        model = new ModelClass()


        for own prop, value of obj

            if prop is 'id'
                model.id = @modifyIdValue value

            else
                model[prop] = @modifyValueByPropName(prop, value)

        return model



    ###*
    modify value of prop of plain object by property name

    @method modifyValueByNonModelPropName
    @protected
    @param {String} prop name
    @param {any} value
    @return {any} value modified value
    ###
    modifyValueByPropName: (prop, value) ->

        propertyInfo = @constructor.ModelClass.properties

        typeInfo = TYPES.info(propertyInfo[prop])

        if typeInfo.model?

            subModelFactory = @facade.createFactory(typeInfo.model)

            # if prop is array of models
            if typeInfo.name is 'MODELS' and Array.isArray value
                return (subModelFactory.createFromObject(subObj) for subObj in value)

            # if prop is model
            else if typeInfo.name is 'MODEL'
                return subModelFactory.createFromObject(value)

        return @modifyValueByNonModelPropName(prop, value)


    ###*
    modify non-model value of prop of plain object by property name

    By default, value is not modified.
    This means that even if property info suggests the value should be number, casting to number won't be occurred.
    This let-it-be policy is for flexibility.
    You can modify values by implementing this method in subclass.

    @method modifyValueByNonModelPropName
    @protected
    @abstract
    @param {String} prop name
    @param {any} value
    @return {any} value modified value
    ###
    modifyValueByNonModelPropName: (prop, value) ->

        return value


    ###*
    modify id value from plain object and set it to model
    Do nothing by default.

    @method modifyIdValue
    @protected
    @param {any} id
    @return {any} id modified id
    ###
    modifyIdValue: (idValue) ->

        return idValue



module.exports = BaseFactory
