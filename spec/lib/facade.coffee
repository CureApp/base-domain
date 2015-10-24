
Facade = require('../base-domain')

describe 'Facade', ->


    describe '@createInstance', ->

        it 'returns instance of Facade', ->
            f = Facade.createInstance()
            expect(f).to.be.instanceof Facade


        it 'returns instance of extended class', ->
            class ChildFacade extends Facade

            f = ChildFacade.createInstance()
            expect(f).to.be.instanceof Facade
            expect(f).to.be.instanceof ChildFacade

    describe '@isBaseClass', ->

        it 'returns true to class "Base"', ->
            expect(Facade.isBaseClass Facade.Base).to.be.true

        it 'returns true to class "BaseFactory"', ->
            expect(Facade.isBaseClass Facade.BaseFactory).to.be.true

        it 'returns true to class "BaseModel"', ->
            expect(Facade.isBaseClass Facade.BaseModel).to.be.true

        it 'returns true to class "Entity"', ->
            expect(Facade.isBaseClass Facade.Entity).to.be.true

        it 'returns true to class "BaseList"', ->
            expect(Facade.isBaseClass Facade.BaseList).to.be.true

        it 'returns true to class "BaseRepository"', ->
            expect(Facade.isBaseClass Facade.BaseRepository).to.be.true

        it 'returns true to class "BaseSyncRepository"', ->
            expect(Facade.isBaseClass Facade.BaseSyncRepository).to.be.true

        it 'returns true to class "BaseAsyncRepository"', ->
            expect(Facade.isBaseClass Facade.BaseAsyncRepository).to.be.true

        it 'returns true to class "DomainError"', ->
            expect(Facade.isBaseClass Facade.DomainError).to.be.true

        it 'returns false to unregistereed class', ->
            class BaseModel extends Facade.BaseModel
            expect(Facade.isBaseClass BaseModel).to.be.false


    describe '@registerBaseClass', ->

        it 'registers base class', ->

            class SpecificRepository extends Facade.BaseRepository

            expect(Facade.isBaseClass SpecificRepository).to.be.false

            Facade.registerBaseClass SpecificRepository

            expect(Facade.isBaseClass SpecificRepository).to.be.true


    describe 'addClass', ->

        it 'registers the given class', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true

            f.addClass('hobby', Hobby)

            FaHobby = f.getModel('hobby')

            expect(FaHobby).to.equal Hobby
            expect(f.classes.hobby).to.equal Hobby


        it 'registers the given class, without name', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true

            f.addClass(Hobby)

            FaHobby = f.getModel('hobby')

            expect(FaHobby).to.equal Hobby
            expect(f.classes.hobby).to.equal Hobby


        it 'cannot register class with the invalid name', ->

            class CamelCaseClass extends Facade.Entity

            f = Facade.createInstance()

            expect(-> f.addClass('xxx', CamelCaseClass)).to.throw Facade.DomainError


        it 'can register class with the invalid name, when 3rd argument is true', ->

            class CamelCaseClass extends Facade.Entity
                @abc: true

            f = Facade.createInstance()

            expect(-> f.addClass('xxx', CamelCaseClass, true)).not.to.throw Facade.DomainError

            expect(f.getModel('xxx')).to.have.property 'abc', true



    describe 'hasClass', ->

        it 'returns false if a class with the given name is not found', ->

            f = Facade.createInstance()
            expect(f.hasClass('hobby')).to.be.false

        it 'returns true if a class with the given name is found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.BaseModel
            f.addClass('hobby', Hobby)
            expect(f.hasClass('hobby')).to.be.true


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
            expect(factory.constructor.xxx).to.equal 'yyy'

        it 'throws error when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            expect(-> f.createFactory('abc')).to.throw Error



    describe 'error', ->

        it 'throw DomainError with reason', ->

            f = Facade.createInstance()
            err = f.error('notANumber')

            expect(err).to.have.property 'reason', 'notANumber'
            expect(f.isDomainError(err)).to.be.true
