
{ BaseAsyncRepository } = require('../base-domain')
{ MemoryResource } = require '../others'

###*
repository of diary

@class DiaryRepository
@extends BaseAsyncRepository
###
class DiaryRepository extends BaseAsyncRepository

    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'diary'

    client: new MemoryResource()

module.exports = DiaryRepository
