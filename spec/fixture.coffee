
Facade = require('./base-domain')

describe 'Fixture', ->

    describe 'constructor', ->

        it 'succeed when attempting to insert no data', (done) ->

            facade = require('./create-facade').create()
            facade.insertFixtures(dirname: __dirname + '/fixtures/empty', debug: true).then (entityPool) ->
                done()


        it 'inserts data', (done) ->
            facade = require('./create-facade').create('domain')

            facade.insertFixtures(dirname: __dirname + '/fixtures/sample', debug: true).then (entityPool) ->
                expect(entityPool).to.have.property 'hobby'
                expect(entityPool).to.have.property 'member'
                expect(entityPool.member).to.have.property 'shinout'
                expect(entityPool.member).to.have.property 'satake'
                expect(entityPool.hobby).to.have.property 'sailing'
                expect(entityPool.member.satake.hobbies).to.have.length 1
                expect(entityPool.member.satake.hobbies.loaded()).to.be.true
                done()

            .catch done
