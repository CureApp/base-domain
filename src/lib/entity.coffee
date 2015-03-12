

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
    @type any
    ###
    id: null


module.exports = Entity
