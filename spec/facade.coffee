
Facade = require('./base-domain')

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

            class MastrFactory extends Facade.BaseFactory
                @modelName: 'mastr'

            class Mastr extends Facade.Entity
                @modelName: 'mastr'

            class NonMastrRepository extends Facade.BaseRepository
                @modelName: 'non-mastr'

            f = ChildFacade.createInstance()

            f.addClass 'mastr-repository', MastrRepository
            f.addClass 'mastr-factory', MastrFactory
            f.addClass 'mastr', Mastr
            f.addClass 'non-mastr-repository', NonMastrRepository

            f.loadMasterTables('mastr', 'non-mastr').then ->
                models = f.getRepository('mastr').modelsById
                expect(models).to.be.an 'object'

                expect(f.getRepository('non-mastr').modelsById).not.to.exist

                done()

            .catch done


    describe 'error', ->

        it 'throw DomainError with reason', ->

            f = Facade.createInstance()
            err = f.error('notANumber')

            expect(err).to.have.property 'reason', 'notANumber'
            expect(f.isDomainError(err)).to.be.true
