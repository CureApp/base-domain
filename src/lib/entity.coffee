

BaseModel = require './base-model'
Id        = require './id'

###*
Base model class with "id" column

@class Entity
@extends BaseModel
@module base-domain
###
class Entity extends BaseModel

    @isEntity: true

    ###*
    primary key for the model

    @property id
    @type {Id}
    ###
    id: null

    ###*
    set model prop
    @return {Entity} this
    ###
    setNonEntityProp: (prop, value) ->

        if prop isnt 'id'
            return super

        @[prop] = new Id(value)


module.exports = Entity
