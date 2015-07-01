

BaseModel = require './base-model'

###*
Base model class without "id" column

@class ValueObject
@extends BaseModel
@module base-domain
###
class ValueObject extends BaseModel

    @isEntity: false

module.exports = ValueObject
