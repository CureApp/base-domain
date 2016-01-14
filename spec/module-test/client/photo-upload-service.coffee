{ BaseService } = require('../../base-domain')

class ClientPhotoUploadService extends BaseService

    getEmptyDiary: ->
        return @getFacade().createModel('diary')


    getPreferredFactoryInstance: ->
        return @getFacade().createPreferredFactory('diary')


    getFactoryInstanceInModule: ->
        return @getModule().createPreferredFactory('diary') # TODO implement @getModule()




module.exports = ClientPhotoUploadService
