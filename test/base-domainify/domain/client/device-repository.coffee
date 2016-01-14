{ MasterRepository } = require('base-domain')

class ClientDeviceRepository extends MasterRepository

    @modelName: 'device'

    count: -> 100

module.exports = ClientDeviceRepository
