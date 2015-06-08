
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

    describe 'hasClass', ->

        it 'returns false if a class with the given name is not found', ->

            f = Facade.createInstance()
            expect(f.hasClass('hobby')).to.be.false

        it 'returns true if a class with the given name is found', ->
            f = Facade.createInstance()
            f.addClass('hobby', ->)
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

    describe 'getListFactory', ->

        it 'throws error if given name is not found and no item model name given', ->
            f = Facade.createInstance()
            expect(-> f.getListFactory('hobby-collection')).to.throw Error

        it 'throws error if given name is not found and invalid item model name given', ->
            f = Facade.createInstance()
            expect(-> f.getListFactory('hobby-collection', 'xxx')).to.throw Error

        it 'returns anonymous factory when list model with given name is not found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.Entity

            f.addClass('hobby', Hobby)
            ListFactory = f.getListFactory('hobby-collection', 'hobby')
            expect(ListFactory.isAnonymous).to.be.true

        it 'returns custom list factory class when registered', ->
            f = Facade.createInstance()
            class HobbyCollectionFactory extends Facade.ListFactory

            f.addClass('hobby-collection-factory', HobbyCollectionFactory)
            ListFactory = f.getListFactory('hobby-collection')
            expect(ListFactory.isAnonymous).not.to.exist



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

            class Factory extends Facade.BaseFactory
                @modelName: 'abc'
                @xxx: 'yyy'

            f = Facade.createInstance()
            f.addClass('abc-factory', Factory)
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
