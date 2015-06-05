
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
