
Facade = require('../base-domain')
{ MasterRepository, Entity } = Facade
{ MemoryResource } = require '../others'

describe 'MasterRepository', ->

    beforeEach ->

        @f = Facade.createInstance
            master:  true
            dirname: __dirname + '/../empty'

        class Device extends Entity
            @properties:
                name: @TYPES.STRING
                os  : @TYPES.STRING

        class DeviceRepository extends MasterRepository
            @modelName: 'device'

        class Dummy extends Entity
        class DummyRepository extends MasterRepository
            @modelName: 'dummy'

        @f.addClass('device', Device)
        @f.addClass('device-repository', DeviceRepository)

        @f.addClass('dummy', Dummy)
        @f.addClass('dummy-repository', DummyRepository)

    it 'throws error when master is disabled', ->

        f = require('../create-facade').create()

        class Device extends Entity
        class DeviceRepository extends MasterRepository
            @modelName: 'device'

        f.addClass('device', Device)
        f.addClass('device-repository', DeviceRepository)

        expect(=> f.createRepository('device')).to.throw /MasterRepository is disabled/


    it 'throws error when the model is not registered in master', ->

        expect(=> @f.createRepository('dummy')).to.throw /No master data of 'dummy'/


    it 'has client, instance of MemoryResource', ->

        repo = @f.createRepository('device')

        expect(repo.client).to.be.instanceof MemoryResource


    describe 'get', ->

        it 'gets data by id', ->

            repo = @f.createRepository('device')

            iPhone6s = repo.get('iphone6s')

            expect(iPhone6s).to.be.instanceof @f.getModel('device')
            expect(iPhone6s).to.have.property 'id', 'iphone6s'
            expect(iPhone6s).to.have.property 'name', 'iPhone6S'
            expect(iPhone6s).to.have.property 'os', 'iOS'


        it 'returns null if not exists', ->

            repo = @f.createRepository('device')
            expect(repo.get('abc')).to.not.exist


    describe 'getAll', ->

        it 'returns all models', ->

            repo = @f.createRepository('device')
            devices = repo.getAll()

            expect(devices).to.be.instanceof Array
            expect(devices).to.have.length 3


    describe 'save', ->

        it 'throws an error', ->

            repo = @f.createRepository('device')
            expect(=> repo.save(id: '3gs', name: 'iPhone3GS', os: 'iOS')).to.throw /cannot save/


    describe 'update', ->

        it 'throws an error', ->

            repo = @f.createRepository('device')
            expect(=> repo.update('iphone6s', os: 'iOS9')).to.throw /cannot update/


    describe 'delete', ->

        it 'throws an error', ->

            repo = @f.createRepository('device')
            iPhone6s = repo.get('iphone6s')

            expect(=> repo.delete(iPhone6s)).to.throw /cannot delete/

