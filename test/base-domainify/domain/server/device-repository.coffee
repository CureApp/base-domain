
{ MasterRepository } = require('base-domain')

class ServerDeviceRepository extends MasterRepository

    @modelName: 'device'
    @isServer: true


module.exports = ServerDeviceRepository
