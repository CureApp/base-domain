
Facade = require('../base-domain')

describe 'Facade', ->


    describe '@createInstance', ->

        it 'returns instance of Facade', ->
            f = Facade.createInstance()
            assert f instanceof Facade


        it 'returns instance of extended class', ->
            class ChildFacade extends Facade

            f = ChildFacade.createInstance()
            assert f instanceof Facade
            assert f instanceof ChildFacade


    describe 'addClass', ->

        it 'registers the given class, adding "className" property to the class', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true

            f.addClass('hobby', Hobby)

            assert Hobby.className is 'hobby'

            FaHobby = f.getModel('hobby')

            assert FaHobby is Hobby
            assert f.classes.hobby is Hobby


        it 'add new "className" property to the class whose parent class already has "className"', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true
            f.addClass('hobby', Hobby)

            class ChildHobby extends Hobby
                @abc: true
            f.addClass('child-hobby', ChildHobby)

            assert Hobby.className is 'hobby'
            assert ChildHobby.className is 'child-hobby'

            FaHobby = f.getModel('hobby')
            assert FaHobby is Hobby
            assert f.classes.hobby is Hobby

            FaChildHobby = f.getModel('child-hobby')
            assert FaChildHobby is ChildHobby
            assert f.classes['child-hobby'] is ChildHobby



    describe 'hasClass', ->

        it 'returns false if a class with the given name is not found', ->

            f = Facade.createInstance()
            assert f.hasClass('hobby') is false

        it 'returns true if a class with the given name is found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.BaseModel
            f.addClass('hobby', Hobby)
            assert f.hasClass('hobby')


        it 'remembers non-existing class name if cacheResult option is given', ->

            f = Facade.createInstance()

            hasClass = f.hasClass('hobby', cacheResult: true)
            assert hasClass is false

            f.require = -> throw new Error('this must not be called')

            assert f.hasClass('hobby') is false


        it 'remembers, but updates information of non-existing class name if addClass() is called after memorizing', ->

            f = Facade.createInstance()

            hasClass = f.hasClass('hobby', cacheResult: true)
            assert hasClass is false

            class Hobby extends Facade.BaseModel
            f.addClass('hobby', Hobby)

            assert f.hasClass('hobby') is true



    describe 'createFactory', ->

        it 'returns an instance of registered Factory', ->

            class Abc extends Facade.ValueObject

            class AbcFactory extends Facade.BaseFactory
                @modelName: 'abc'
                @xxx: 'yyy'

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            f.addClass('abc-factory', AbcFactory)
            factory = f.createFactory('abc')
            assert factory.constructor.xxx is 'yyy'

        it 'throws error when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            assert.throws(-> f.createFactory('abc'))


    describe 'error', ->

        it 'throw DomainError with reason', ->

            f = Facade.createInstance()
            err = f.error('notANumber')

            assert err.reason is 'notANumber'
            assert f.isDomainError(err)


    describe 'createPreferredRepository', ->

        before ->
            @f = require('../create-facade').create 'preferred-test'


        it 'throw error if no candidates are found', ->

            assert.throws(=> @f.createPreferredRepository('hospital'))



        it 'returns standard repository if preferred repository is not specified', ->

            MedicineRepository = @f.require 'medicine-repository'

            assert @f.createPreferredRepository('medicine') instanceof MedicineRepository


        it 'returns preferred repository', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    repository:
                        medicine: 'web-medicine-repository'

            WebMedicineRepository = f.require 'web-medicine-repository'

            assert f.createPreferredRepository('medicine') instanceof WebMedicineRepository


        it 'returns standard repository when preferred repository name is specified but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    repository:
                        medicine: 'abcdef-repository'

            MedicineRepository = f.require 'medicine-repository'

            assert f.createPreferredRepository('medicine') instanceof MedicineRepository


        it 'checks parent class\'s repository when options.noParent is not true', ->

            { Entity, BaseSyncRepository } = Facade

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentRepository extends BaseSyncRepository
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-repository', ParentRepository)

            assert f.createPreferredRepository('child') instanceof ParentRepository


        it 'skips checking parent class\'s repository when options.noParent is true', ->

            { Entity, BaseSyncRepository } = Facade

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentRepository extends BaseSyncRepository
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-repository', ParentRepository)

            assert.throws(=> f.createPreferredRepository('child', noParent: true))



    describe 'createPreferredFactory', ->

        before ->
            @f = require('../create-facade').create 'preferred-test'


        it 'throw error if no candidates are found', ->

            assert.throws(=> @f.createPreferredFactory('hospital'))


        it 'returns standard factory if preferred factory is not specified', ->

            MedicineFactory = @f.require 'medicine-factory'

            assert @f.createPreferredFactory('medicine') instanceof MedicineFactory


        it 'returns preferred factory', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    factory:
                        medicine: 'xx-medicine-factory'

            XxMedicineFactory = f.require 'xx-medicine-factory'

            assert f.createPreferredFactory('medicine') instanceof XxMedicineFactory


        it 'returns standard factory when preferred factory name is specified but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    factory:
                        medicine: 'abcdef-factory'

            MedicineFactory = f.require 'medicine-factory'

            assert f.createPreferredFactory('medicine') instanceof MedicineFactory


        it 'checks parent class\'s factory when options.noParent is false', ->

            { Entity, BaseFactory } = Facade

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentFactory extends BaseFactory
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-factory', ParentFactory)

            assert f.createPreferredFactory('child', noParent: false) instanceof ParentFactory


        it 'skips checking parent class\'s factory by default', ->

            { Entity, BaseFactory } = Facade

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentFactory extends BaseFactory
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-factory', ParentFactory)

            assert.throws (=> f.createPreferredFactory('child'))



    describe 'createPreferredService', ->

        before ->
            @f = require('../create-facade').create 'preferred-test'


        it 'throw error if no candidates are found', ->

            assert.throws (=> @f.createPreferredService('hospital'))


        it 'returns standard service if preferred service is not specified', ->

            MedicineService = @f.require 'medicine-service'

            assert @f.createPreferredService('medicine') instanceof MedicineService


        it 'returns preferred service', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    service:
                        medicine: 'special-medicine-service'

            SpecialMedicineService = f.require 'special-medicine-service'

            assert f.createPreferredService('medicine') instanceof SpecialMedicineService


        it 'returns standard service when preferred service name is specified but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    service:
                        medicine: 'abcdef-service'

            MedicineService = f.require 'medicine-service'

            assert f.createPreferredService('medicine') instanceof MedicineService



        it 'skips checking parent class\'s service by default', ->

            { Entity, BaseService } = Facade

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentService extends BaseService
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-service', ParentService)

            assert.throws (=> f.createPreferredService('child'))


        it 'checks parent class\'s service when options.noParent is false', ->

            { Entity, BaseService } = Facade

            class Parent extends Entity
                @properties:
                    name: @TYPES.STRING

            class Child extends Parent
                @properties:
                    name: @TYPES.STRING

            class ParentService extends BaseService
                @modelName: 'parent'

            f = require('../create-facade').create()
            f.addClass('parent', Parent)
            f.addClass('child', Child)
            f.addClass('parent-service', ParentService)

            assert f.createPreferredService('child', noParent: false) instanceof ParentService



    describe '[using modules]', ->

        it 'throws error when "core" module is given at constructor', ->

            fn = ->
                require('../create-facade').create 'domain',
                    modules:
                        core: __dirname + '/../module-test/server'

            assert.throws fn, 'Cannot use "core" as a module name'


        it '"moduleName" property of classes in modules is the name of the module', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'

            service = f.createService('server/photo-upload')

            assert service.constructor.moduleName is 'server'


        it '"moduleName" property of classes in core module is "core"', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'

            service = f.createRepository('diary')

            assert service.constructor.moduleName is 'core'


        it 'loads from module dir with suffix', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'

            ServerPhotoUploadService = require(__dirname + '/../module-test/server/photo-upload-service')

            service = f.createService('server/photo-upload')

            assert service instanceof ServerPhotoUploadService


        it 'loads from multiple modules dir', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'
                    client: __dirname + '/../module-test/client'

            ServerPhotoUploadService = require(__dirname + '/../module-test/server/photo-upload-service')
            ClientPhotoUploadService = require(__dirname + '/../module-test/client/photo-upload-service')

            assert ServerPhotoUploadService isnt ClientPhotoUploadService

            ssv = f.createService('server/photo-upload')
            assert ssv instanceof ServerPhotoUploadService

            csv = f.createService('client/photo-upload')
            assert csv instanceof ClientPhotoUploadService


        it 'loads from multiple modules dir', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'
                    client: __dirname + '/../module-test/client'

            ServerPhotoUploadService = require(__dirname + '/../module-test/server/photo-upload-service')
            ClientPhotoUploadService = require(__dirname + '/../module-test/client/photo-upload-service')

            assert ServerPhotoUploadService isnt ClientPhotoUploadService

            ssv = f.createService('server/photo-upload')
            assert ssv instanceof ServerPhotoUploadService

            csv = f.createService('client/photo-upload')
            assert csv instanceof ClientPhotoUploadService


        it 'preferred call loads core module\'s file by default', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'
                    client: __dirname + '/../module-test/client'
                preferred:
                    factory:
                        diary: 'server/diary-factory'

            DiaryFactory = require __dirname + '/../domain/diary-factory'
            service = f.createService('client/photo-upload')
            factory = service.getPreferredFactoryInstance() instanceof DiaryFactory


        it 'preferred call inside module can load other module\'s file', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'
                    client: __dirname + '/../module-test/client'
                preferred:
                    factory:
                        diary: 'server/diary-factory'

            ServerDiaryFactory = require __dirname + '/../module-test/server/diary-factory'
            service = f.createService('client/photo-upload')
            factory = service.getPreferredFactoryInstance() instanceof ServerDiaryFactory


        it 'preferred: module: "client" make preferred call load the file of the module', ->

            f = require('../create-facade').create 'domain',
                modules:
                    server: __dirname + '/../module-test/server'
                    client: __dirname + '/../module-test/client'
                preferred:
                    module: 'client'

            ClientDiaryFactory = require __dirname + '/../module-test/server/diary-factory'
            service = f.createService('client/photo-upload')
            factory = service.getPreferredFactoryInstance() instanceof ClientDiaryFactory

