
{ MemoryResource, BaseAsyncRepository } = require('../base-domain')

memory = new MemoryResource()

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

module.exports = DiaryRepository
