{ BaseService } = require('../../base-domain')

class ClientPhotoUploadService extends BaseService

    getEmptyDiary: ->
        return @facade.createModel('diary')


    getPreferredFactoryInstance: ->
        return @facade.createPreferredFactory('diary')


    getFactoryInstanceInModule: ->
        return @getModule().createPreferredFactory('diary') # TODO implement @getModule()




module.exports = ClientPhotoUploadService
