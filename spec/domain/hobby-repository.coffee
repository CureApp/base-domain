

{ MemoryResource, BaseAsyncRepository } = require('../base-domain')

memory = new MemoryResource()

class HobbyRepository extends BaseAsyncRepository

    @modelName: 'hobby'

    client: memory

module.exports = HobbyRepository
