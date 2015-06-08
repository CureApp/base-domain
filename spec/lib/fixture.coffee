
Facade = require('../base-domain')

describe 'Fixture', ->

    describe 'constructor', ->

        it 'succeed when attempting to insert no data', (done) ->

            facade = require('../create-facade').create()
            facade.insertFixtures(dirname: __dirname + '/../fixtures/empty', debug: true).then (dataPool) ->
                    done()


        it 'inserts data', (done) ->
            facade = require('../create-facade').create('domain')

            facade.insertFixtures(dirname: __dirname + '/../fixtures/sample', debug: true, data: abc: 1).then (dataPool) ->
                expect(dataPool).to.have.property 'hobby'
                expect(dataPool).to.have.property 'member'
                expect(dataPool.member).to.have.property 'shinout'
                expect(dataPool.member).to.have.property 'satake'
                expect(dataPool.hobby).to.have.property 'sailing'
                expect(dataPool.member.satake.hobbies.items).to.have.length 1
                expect(dataPool.member.satake.hobbies.items[0]).to.be.instanceof facade.getModel('hobby')
                done()

            .catch done
