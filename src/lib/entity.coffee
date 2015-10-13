

BaseModel = require './base-model'

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
    @type {String|Number}
    ###
    id: null


    ###*
    check equality

    @method equals
    @param {Entity} entity
    @return {Boolean}
    ###
    equals: (entity) ->

        return false if not @id?

        super(entity) and @id is entity.id


module.exports = Entity
