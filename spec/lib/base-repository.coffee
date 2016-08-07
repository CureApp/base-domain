
facade = require('../create-facade').create('domain')

Hobby = facade.getModel 'hobby'

describe 'BaseRepository', ->

    describe 'factory', ->

        it 'is created by the model name', ->
            repo = facade.createRepository('hobby')
            HobbyFactory = facade.require('hobby-factory')
            assert repo.factory instanceof HobbyFactory


    describe 'save', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', ->

            repo.save(name: 'music').then (model) =>
                assert model instanceof Hobby


        it 'returns instance of Model with createdAt, updatedAt when configured as such', ->

            memberRepo = facade.createRepository('member')

            model = memberRepo.save(firstName: 'Shin')
            assert model.mCreatedAt?
            assert model.mUpdatedAt?
            assert new Date(model.mCreatedAt) instanceof Date
            assert new Date(model.mUpdatedAt) instanceof Date

        it 'createdAt stays original', ->

            memberRepo = facade.createRepository('member')
            now = new Date()

            model = memberRepo.save(firstName: 'Shin', mCreatedAt: now)
            assert model.mCreatedAt?
            assert.deepEqual model.mCreatedAt, now

        it 'createdAt is newly set even when model has id', ->

            memberRepo = facade.createRepository('member')
            now = new Date()

            model = memberRepo.save(firstName: 'Shin', id: 'shin')
            assert model.mCreatedAt?
            assert new Date(model.mCreatedAt) instanceof Date
            assert new Date(model.mUpdatedAt) instanceof Date


        it 'updatedAt changes for each saving', ->

            memberRepo = facade.createRepository('member')
            now = new Date()

            model = memberRepo.save(firstName: 'Shin', mUpdatedAt: now)
            assert model.mCreatedAt?
            assert model.mUpdatedAt isnt now

        it 'returns instance of Model with relation ids', ->

            memberFactory = facade.createFactory('member')

            member = memberFactory.createFromObject
                id: '12'
                firstName: 'Shin'
                age: 29
                registeredAt: new Date()
                hobbies: [
                    { id: 1, name: 'keyboard' }
                    { id: 2, name: 'ingress' }
                    { id: 3, name: 'Shogi' }
                ]

            dFactory = facade.createFactory('diary')

            diary = dFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                author: member
                date  : new Date()


            dRepo = facade.createRepository('diary')
            dRepo.save(diary).then (model) =>
                assert model.memberId is '12'


     describe 'get', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', ->

            repo.get(1).then (model) =>
                assert model instanceof Hobby


     describe 'query', ->
        repo = facade.createRepository('hobby')

        it 'returns array of models', ->

            repo.query().then (models) =>
                assert models instanceof Array
                assert models[0] instanceof Hobby


     describe 'singleQuery', ->
        repo = facade.createRepository('hobby')

        it 'returns instance of Model', ->

            repo.singleQuery().then (model) =>
                assert model instanceof Hobby


     describe 'delete', ->
        repo = facade.createRepository('hobby')

        it 'returns boolean', ->

            repo.delete(id: '123').then (isDeleted) =>
                assert isDeleted



     describe 'update', ->
        repo = facade.createRepository('hobby')
        memberRepo = facade.createRepository('member')

        before ->
            memberRepo.save(id: '123', firstName: 'shin')
            repo.save(id: '123', name: 'tennis').then (entity) =>
                @tennis = entity

        it 'returns instance of Model', ->

            repo.update('123', name: 'tennis').then (model) =>
                assert model instanceof Hobby


        it 'returns instance of Model with updatedAt when configured as such', ->

            model = memberRepo.update('123', firstName: 'Shin')
            assert new Date(model.mUpdatedAt) instanceof Date


     describe 'updateProps', ->

        repo = facade.createRepository('hobby')

        before ->
            repo.save(id: 'xyz', name: 'tennis').then (entity) =>
                @tennis = entity

        it 'returns diff props', ->
            repo.updateProps(@tennis, { name: 'xxx' }).then (results) =>
                assert.deepEqual results, {}


