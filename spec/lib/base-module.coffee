
{ BaseModule } = require('../others')


describe 'BaseModule', ->


    describe 'normalizeName', ->

        beforeEach ->
            @f = require('../create-facade').create()


        it 'attaches module name to the given name when the name contains no "/"', ->

            mod = new BaseModule('abc', 'dummy', @f)

            assert mod.normalizeName('xxx-factory') is 'abc/xxx-factory'

        it 'attaches nothing when the given name contains "/"', ->

            mod = new BaseModule('abc', 'dummy', @f)

            assert mod.normalizeName('yyy/xxx-factory') is 'yyy/xxx-factory'



    xdescribe 'createModel', ->


    describe 'createFactory', ->

        it 'create factory in the module when module contains the factory', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'

            factory = f.getModule('server').createFactory('diary')

            assert factory.constructor.moduleName is 'server'
            assert factory.constructor.className is 'server/diary-factory'

            ServerDiaryFactory = require __dirname + '/../module-test/server/diary-factory'
            assert factory instanceof ServerDiaryFactory


        it 'create factory of the core module when module does not contain the factory', ->

            f = require('../create-facade').create 'domain',
                modules:
                    dummy: __dirname + '/../module-test/dummy'

            factory = f.getModule('dummy').createFactory('diary')

            assert factory.constructor.moduleName is 'core'
            assert factory.constructor.className is 'diary-factory'

            DiaryFactory = require __dirname + '/../domain/diary-factory'
            assert factory instanceof DiaryFactory




    describe 'createRepository', ->

        it 'create repository in the module when module contains the repository', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'

            repository = f.getModule('server').createRepository('diary')

            assert repository.constructor.moduleName is 'server'
            assert repository.constructor.className is 'server/diary-repository'

            ServerDiaryRepository = require __dirname + '/../module-test/server/diary-repository'
            assert repository instanceof ServerDiaryRepository


        it 'create repository of the core module when module does not contain the repository', ->

            f = require('../create-facade').create 'domain',
                modules:
                    dummy: __dirname + '/../module-test/dummy'

            repository = f.getModule('dummy').createRepository('diary')

            assert repository.constructor.moduleName is 'core'
            assert repository.constructor.className is 'diary-repository'

            DiaryRepository = require __dirname + '/../domain/diary-repository'
            assert repository instanceof DiaryRepository



    describe 'createService', ->

        it 'create service in the module when module contains the service', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'

            service = f.getModule('server').createService('photo-upload')

            assert service.constructor.moduleName is 'server'
            assert service.constructor.className is 'server/photo-upload-service'

            ServerPhotoUploadService = require __dirname + '/../module-test/server/photo-upload-service'
            assert service instanceof ServerPhotoUploadService


        it 'create service of the core module when module does not contain the service', ->

            f = require('../create-facade').create 'domain',
                modules:
                    dummy: __dirname + '/../module-test/dummy'

            service = f.getModule('dummy').createService('photo-upload')

            assert service.constructor.moduleName is 'core'
            assert service.constructor.className is 'photo-upload-service'

            PhotoUploadService = require __dirname + '/../domain/photo-upload-service'
            assert service instanceof PhotoUploadService

