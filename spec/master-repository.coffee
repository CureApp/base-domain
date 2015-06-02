
facade = require './init'

MasterRepository = facade.constructor.MasterRepository

Hobby = facade.getModel 'hobby'


describe 'MasterRepository', ->

    describe 'load', ->

        class HobbyRepository extends MasterRepository

            @modelName: 'hobby'

            getFacade: -> facade

        it 'loads models to @constructor.modelsById', (done) ->

            expect(HobbyRepository.modelsById).not.to.exist

            HobbyRepository.load().then ->

                expect(HobbyRepository.modelsById).to.be.an 'object'
                expect(HobbyRepository.modelsById.dummy).to.be.instanceof Hobby
                done()


    describe 'getByIdSync', ->

        class HobbyRepository extends MasterRepository

            @modelName: 'hobby'

            getFacade: -> facade


        it 'returns null when not loaded', ->

            dummyHobby = new HobbyRepository().getByIdSync 'dummy'

            expect(dummyHobby).to.be.null


        it 'returns model by id synchronously', (done) ->

            HobbyRepository.load().then ->

                dummyHobby = new HobbyRepository().getByIdSync 'dummy'

                expect(dummyHobby).to.be.instanceof Hobby

                done()


        it 'returns model the same reference as pooled', (done) ->

            HobbyRepository.load().then ->

                dummyHobby = new HobbyRepository().getByIdSync 'dummy'

                expect(dummyHobby).to.equal HobbyRepository.modelsById.dummy

                done()


        it 'returns null when no object found by id', (done) ->

            HobbyRepository.load().then ->

                hobby = new HobbyRepository().getByIdSync 'xxx'

                expect(hobby).to.be.null

                done()
