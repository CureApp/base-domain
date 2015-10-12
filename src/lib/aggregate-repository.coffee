
{ BaseSyncRepository } = require './base-sync-repository'

class AggregateRepository extends BaseSyncRepository

    constructor: (@aggregateRoot) ->

        super

        @client = @aggregateRoot.getResourceClient(@constructor.modelName)


module.exports = AggregateRepository
