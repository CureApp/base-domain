
facade = require './init'

Hobby = facade.getModel 'hobby'

describe 'BaseRepository', ->

    describe 'factory', ->

        it 'is created by the model name', ->
            repo = facade.createRepository('hobby')
            HobbyFactory = facade.getFactory('hobby')
            expect(repo.factory).to.be.instanceof HobbyFactory


    describe 'save', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', (done) ->

            repo.save(name: 'music').then (model) =>
                expect(model).to.be.instanceof Hobby
                done()


        it 'returns instance of Model with createdAt, updatedAt when configured as such', (done) ->

            memberRepo = facade.createRepository('member')

            memberRepo.save(firstName: 'Shin').then (model) =>
                arg1 = model.arg1 # mock prop
                expect(arg1).to.have.property('mCreatedAt')
                expect(arg1).to.have.property('mUpdatedAt')
                expect(new Date(arg1.mCreatedAt)).to.be.instanceof Date
                expect(new Date(arg1.mUpdatedAt)).to.be.instanceof Date
                done()



     describe 'get', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', (done) ->

            repo.get(1).then (model) =>
                expect(model).to.be.instanceof Hobby
                done()


     describe 'query', ->
        repo = facade.createRepository('hobby')

        it 'returns array of models', (done) ->

            repo.query().then (models) =>
                expect(models).to.be.instanceof Array
                expect(models[0]).to.be.instanceof Hobby
                done()


     describe 'singleQuery', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', (done) ->

            repo.singleQuery().then (model) =>
                expect(model).to.be.instanceof Hobby
                done()


     describe 'delete', ->
        repo = facade.createRepository('hobby')

        it 'returns boolean', (done) ->

            repo.delete(id: '123').then (isDeleted) =>
                expect(isDeleted).to.be.true
                done()



     describe 'update', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', (done) ->

            repo.update('123', name: 'tennis').then (model) =>
                expect(model).to.be.instanceof Hobby

                done()

        it 'returns instance of Model with updatedAt when configured as such', (done) ->

            memberRepo = facade.createRepository('member')

            memberRepo.update('123', firstName: 'Shin').then (model) =>
                arg2 = model.arg2 # mock prop
                expect(arg2).not.to.have.property('mCreatedAt')
                expect(arg2).to.have.property('mUpdatedAt')
                expect(new Date(arg2.mUpdatedAt)).to.be.instanceof Date
                done()
