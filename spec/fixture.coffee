
Facade = require('./base-domain')

describe 'Fixture', ->

    describe 'constructor', ->

        it 'succeed when attempting to insert no data', (done) ->
            Facade.createInstance()
                .insertFixtures(dirname: __dirname + '/fixtures/empty', debug: true).then (dataPool) ->
                    done()


        it 'inserts data', (done) ->
            facade = Facade.createInstance(dirname: __dirname + '/domain')

            facade.insertFixtures(dirname: __dirname + '/fixtures/sample', debug: true).then (dataPool) ->
                expect(dataPool).to.have.property 'hobby'
                expect(dataPool).to.have.property 'member'
                expect(dataPool.member).to.have.property 'shinout'
                expect(dataPool.member).to.have.property 'satake'
                expect(dataPool.hobby).to.have.property 'sailing'
                expect(dataPool.member.satake.hobbies[0]).to.equal dataPool.hobby.sailing
                done()
