
BaseSyncRepository = require './base-sync-repository'

class LocalRepository extends BaseSyncRepository

    constructor: ->

        super

        @client = @root.useMemoryResource(@constructor.modelName)

module.exports = LocalRepository
