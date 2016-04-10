
Facade = require('../base-domain')
{ MasterRepository, Entity } = Facade
{ MemoryResource } = require '../others'

describe 'MasterRepository', ->

    beforeEach ->

        @f = Facade.createInstance
            master:  true
            dirname: __dirname + '/../master-test'

        class Dummy extends Entity
        class DummyRepository extends MasterRepository
            @modelName: 'dummy'

        @f.addClass('dummy', Dummy)
        @f.addClass('dummy-repository', DummyRepository)

    it 'throws error when master is disabled', ->

        f = require('../create-facade').create()

        class Device extends Entity
        class DeviceRepository extends MasterRepository
            @modelName: 'device'

        f.addClass('device', Device)
        f.addClass('device-repository', DeviceRepository)

        assert.throws (=> f.createRepository('device')), /MasterRepository is disabled/


    it 'succeeds with no data, when the model is not registered in master', ->

        repo = @f.createRepository('dummy')
        assert repo.client instanceof MemoryResource
        assert repo.client.count() is 0


    it 'has client, instance of MemoryResource', ->

        repo = @f.createRepository('device')
        assert repo.client instanceof MemoryResource
        assert repo.client.count() > 0


    describe 'get', ->

        it 'gets data by id', ->

            repo = @f.createRepository('device')

            iPhone6s = repo.get('iphone6s')

            assert iPhone6s instanceof @f.getModel('device')
            assert iPhone6s.id is 'iphone6s'
            assert iPhone6s.name is 'iPhone6S'
            assert iPhone6s.os is 'iOS'


        it 'returns null if not exists', ->

            repo = @f.createRepository('device')
            assert not repo.get('abc')?


    describe 'getAll', ->

        it 'returns all models', ->

            repo = @f.createRepository('device')
            devices = repo.getAll()

            assert devices instanceof Array
            assert devices.length is 3


    describe 'save', ->

        it 'throws an error', ->

            repo = @f.createRepository('device')
            assert.throws (=> repo.save(id: '3gs', name: 'iPhone3GS', os: 'iOS')), /cannot save/


    describe 'update', ->

        it 'throws an error', ->

            repo = @f.createRepository('device')
            assert.throws (=> repo.update('iphone6s', os: 'iOS9')), /cannot update/


    describe 'delete', ->

        it 'throws an error', ->

            repo = @f.createRepository('device')
            iPhone6s = repo.get('iphone6s')

            assert.throws (=> repo.delete(iPhone6s)), /cannot delete/
