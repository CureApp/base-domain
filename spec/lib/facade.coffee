
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
            expect(-> f.createFactory('abc')).to.throw Error


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

            expect(=> @f.createPreferredRepository('hospital')).to.throw.Error



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


        it 'returns repository with prefix if exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    prefix: 'web'

            WebMedicineRepository = f.require 'web-medicine-repository'

            assert f.createPreferredRepository('medicine') instanceof WebMedicineRepository


        it 'returns standard repository when prefix is given but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    prefix: 'node'

            MedicineRepository = f.require 'medicine-repository'

            assert f.createPreferredRepository('medicine') instanceof MedicineRepository


        it 'returns standard repository when preferred repository name is specified but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    repository:
                        medicine: 'abcdef-repository'

            MedicineRepository = f.require 'medicine-repository'

            assert f.createPreferredRepository('medicine') instanceof MedicineRepository



    describe 'createPreferredFactory', ->

        before ->
            @f = require('../create-facade').create 'preferred-test'


        it 'throw error if no candidates are found', ->

            expect(=> @f.createPreferredFactory('hospital')).to.throw.Error


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


        it 'returns factory with prefix if exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    prefix: 'xx'

            XxMedicineFactory = f.require 'xx-medicine-factory'

            assert f.createPreferredFactory('medicine') instanceof XxMedicineFactory


        it 'returns standard factory when prefix is given but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    prefix: 'node'

            MedicineFactory = f.require 'medicine-factory'

            assert f.createPreferredFactory('medicine') instanceof MedicineFactory


        it 'returns standard factory when preferred factory name is specified but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    factory:
                        medicine: 'abcdef-factory'

            MedicineFactory = f.require 'medicine-factory'

            assert f.createPreferredFactory('medicine') instanceof MedicineFactory



    describe 'createPreferredService', ->

        before ->
            @f = require('../create-facade').create 'preferred-test'


        it 'throw error if no candidates are found', ->

            expect(=> @f.createPreferredService('hospital')).to.throw.Error


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


        it 'returns service with prefix if exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    prefix: 'special'

            SpecialMedicineService = f.require 'special-medicine-service'

            assert f.createPreferredService('medicine') instanceof SpecialMedicineService


        it 'returns standard service when prefix is given but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    prefix: 'node'

            MedicineService = f.require 'medicine-service'

            assert f.createPreferredService('medicine') instanceof MedicineService


        it 'returns standard service when preferred service name is specified but not exists', ->

            f = require('../create-facade').create 'preferred-test',
                preferred:
                    service:
                        medicine: 'abcdef-service'

            MedicineService = f.require 'medicine-service'

            assert f.createPreferredService('medicine') instanceof MedicineService
