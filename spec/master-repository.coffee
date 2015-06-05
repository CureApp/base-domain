
facade = require './init'

MasterRepository = facade.constructor.MasterRepository

Hobby = facade.getModel 'hobby'


describe 'MasterRepository', ->

    describe 'storeMasterTable', ->

        it 'is true by default', ->

            expect(MasterRepository.storeMasterTable).to.be.true

        it 'is true by default in extenders', ->

            class Child extends MasterRepository

            expect(Child.storeMasterTable).to.be.true

        it 'is undefined in BaseRepository', ->

            BaseRepository = facade.constructor.BaseRepository

            expect(BaseRepository.storeMasterTable).not.to.be.true

    describe 'loaded', ->

        it 'returns false when class is just created', ->

            class Child extends MasterRepository

            expect(Child.loaded()).to.be.false

        it 'returns true when loaded', ->

            class HobbyRepository extends MasterRepository
                @modelName: 'hobby'
                getFacade: -> facade

            expect(HobbyRepository.modelsById).not.to.exist
            expect(HobbyRepository.loaded()).to.be.false

            HobbyRepository.load().then (isSucceed) ->

                expect(HobbyRepository.loaded()).to.be.true
                done()


    describe 'load', ->

        it 'loads models to @constructor.modelsById', (done) ->

            class HobbyRepository extends MasterRepository
                @modelName: 'hobby'
                getFacade: -> facade

            expect(HobbyRepository.modelsById).not.to.exist
            expect(HobbyRepository.loaded()).to.be.false

            HobbyRepository.load().then (isSucceed) ->

                expect(HobbyRepository.modelsById).to.be.an 'object'
                expect(HobbyRepository.loaded()).to.be.true
                expect(HobbyRepository.modelsById.dummy).to.be.instanceof Hobby
                expect(isSucceed).to.be.true
                done()

        it 'fails when @storeMasterTable is off', (done) ->

            class HobbyRepository extends MasterRepository
                @storeMasterTable: off

            HobbyRepository.load().then (isSucceed) ->
                expect(isSucceed).to.be.false
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
