
Facade = require('./base-domain')

describe 'Fixture', ->

    describe 'constructor', ->

        it 'succeed when attempting to insert no data', ->

            facade = require('./create-facade').create()
            facade.insertFixtures(dirname: __dirname + '/fixtures/empty', debug: true)


        it 'inserts data', ->
            facade = require('./create-facade').create('domain')

            facade.insertFixtures(dirname: __dirname + '/fixtures/sample', debug: true).then (entityPool) ->
                assert entityPool.hobby?
                assert entityPool.member?
                assert entityPool.member.shinout?
                assert entityPool.member.satake?
                assert entityPool.hobby.sailing?
                assert entityPool.member.satake.hobbies.length is 1
                assert entityPool.member.satake.hobbies.loaded()
