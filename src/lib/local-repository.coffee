
BaseSyncRepository = require './base-sync-repository'

###*
repository of local memory, saved in @root

@class LocalRepository
@extends BaseSyncRepository
@module base-domain
###
class LocalRepository extends BaseSyncRepository

    constructor: ->

        super

        @client = @root.useMemoryResource(@constructor.modelName)

module.exports = LocalRepository
