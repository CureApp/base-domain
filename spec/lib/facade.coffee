
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

        it 'returns true to class "ListFactory"', ->
            expect(Facade.isBaseClass Facade.ListFactory).to.be.true

        it 'returns true to class "BaseRepository"', ->
            expect(Facade.isBaseClass Facade.BaseRepository).to.be.true

        it 'returns true to class "MasterRepository"', ->
            expect(Facade.isBaseClass Facade.MasterRepository).to.be.true

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

        it 'adds copy of the given class', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true

            f.addClass('hobby', Hobby)

            FaHobby = f.getModel('hobby')

            expect(FaHobby).not.to.equal Hobby
            expect(Hobby.abc).to.be.true
            expect(FaHobby.abc).to.be.true


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


        it 'also registers custom parent classes', (done) ->

            class A extends Facade.Entity
            class B extends A

            f = Facade.createInstance()

            originalRequire = f.require
            f.require = (name) ->
                f.require = originalRequire
                if name is 'a' then done() else done('"a" should be required')

            f.addClass('b', B)


        it 'copies class which extends its parent class', ->

            class A extends Facade.Entity
            class B extends A

            f = Facade.createInstance()
            f.addClass('a', A)
            f.addClass('b', B)

            CopiedB = f.getModel('b')
            b = new CopiedB()

            expect(b).to.be.instanceof f.getModel('a')
            expect(b).not.to.be.instanceof B
            expect(b).not.to.be.instanceof A


        it 'generates class with camelized name when skipNameValidation is true', ->

            class A extends Facade.Entity

            f = Facade.createInstance()
            f.addClass('awesome-entity', A, true)

            GeneratedClass = f.getModel('awesome-entity')
            expect(GeneratedClass.name).to.equal 'AwesomeEntity'
            expect(GeneratedClass.getName()).to.equal 'awesome-entity'




    describe 'hasClass', ->

        it 'returns false if a class with the given name is not found', ->

            f = Facade.createInstance()
            expect(f.hasClass('hobby')).to.be.false

        it 'returns true if a class with the given name is found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.BaseModel
            f.addClass('hobby', Hobby)
            expect(f.hasClass('hobby')).to.be.true


    describe 'getListModel', ->

        it 'throws error if given name is not found and no item model name given', ->
            f = Facade.createInstance()
            expect(-> f.getListModel('hobby-collection')).to.throw Error

        it 'throws error if given name is not found and invalid item model name given', ->
            f = Facade.createInstance()
            expect(-> f.getListModel('hobby-collection', 'xxx')).to.throw Error

        it 'returns anonymous list when list model with given name is not found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.Entity

            f.addClass('hobby', Hobby)
            List = f.getListModel('hobby-collection', 'hobby')
            expect(List.isAnonymous).to.be.true

        it 'returns custom list class when list class name is registered', ->
            f = Facade.createInstance()
            class HobbyCollection extends Facade.BaseList

            f.addClass('hobby-collection', HobbyCollection)
            List = f.getListModel('hobby-collection')
            expect(List.isAnonymous).not.to.exist


    describe 'loadMasterTables', ->

        it 'loads master tables', (done) ->

            class ChildFacade extends Facade

            class MastrRepository extends Facade.MasterRepository
                @modelName: 'mastr'

            class Mastr extends Facade.Entity
                @modelName: 'mastr'

            class NonMastrRepository extends Facade.BaseRepository
                @modelName: 'non-mastr'

            f = ChildFacade.createInstance()

            f.addClass 'mastr-repository', MastrRepository
            f.addClass 'mastr', Mastr
            f.addClass 'non-mastr-repository', NonMastrRepository

            f.loadMasterTables('mastr', 'non-mastr').then ->
                models = f.getRepository('mastr').modelsById
                expect(models).to.be.an 'object'

                expect(f.getRepository('non-mastr').modelsById).not.to.exist

                done()

            .catch done


    describe 'getFactory', ->

        it 'returns registered Factory', ->

            class AbcFactory extends Facade.BaseFactory
                @modelName: 'abc'
                @xxx: 'yyy'

            f = Facade.createInstance()
            f.addClass('abc-factory', AbcFactory)
            FactoryClass = f.getFactory('abc')
            expect(FactoryClass.xxx).to.equal 'yyy'
            expect(FactoryClass.isAnonymous).not.to.exist

        it 'returns AnonymousFactory when no factory found and second argument is true', ->

            f = Facade.createInstance()
            FactoryClass = f.getFactory('abc', true)

            expect(FactoryClass.modelName).to.equal 'abc'
            expect(FactoryClass.isAnonymous).to.be.true


        it 'throws error when no factory found and second argument is false', ->

            f = Facade.createInstance()
            expect(-> f.getFactory('abc')).to.throw Error



    describe 'error', ->

        it 'throw DomainError with reason', ->

            f = Facade.createInstance()
            err = f.error('notANumber')

            expect(err).to.have.property 'reason', 'notANumber'
            expect(f.isDomainError(err)).to.be.true
