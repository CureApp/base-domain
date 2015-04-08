
Facade = require('./base-domain')

describe 'Fixture', ->

    describe 'constructor', ->

        it 'succeed when attempting to insert no data', (done) ->
            Facade.createInstance()
                .insertFixtures(dirname: __dirname + '/fixtures/empty', debug: true).then ->
                    done()


        it 'inserts data', (done) ->
            facade = Facade.createInstance(dirname: __dirname + '/domain')

            facade.insertFixtures(dirname: __dirname + '/fixtures/sample', debug: true).then ->
                done()
