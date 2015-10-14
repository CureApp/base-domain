
MemoryResource = require '../../src/memory-resource'

{ BaseAsyncRepository } = require('../base-domain')

class HobbyRepository extends BaseAsyncRepository

    @modelName: 'hobby'

    client: new MemoryResource()

module.exports = HobbyRepository
