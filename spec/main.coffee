{ requireFile }= require('../../main')

describe 'requireFile', ->

    it 'just requires a file', ->

        abc = requireFile(__dirname + '/sample-files/abc')
        assert abc is 'abc'


    describe 'in Titanium environment', ->

        beforeEach ->
            getGlobal = -> @
            getGlobal().Ti =
                Platform:
                    name: 'android'
                Filesystem:
                    getFile: (a, b) ->
                    resourcesDirectory: 'Resources'

        afterEach ->
            getGlobal = -> @
            getGlobal().Ti = undefined
            assert not Ti?


        it 'just adds suffix ".js" and requires the path when platform is android', ->

            Ti.Filesystem.getFile = -> throw new Error 'this must not be called'

            abc = requireFile(__dirname + '/sample-files/abc')
            assert abc is 'abc'


        it 'adds suffix ".js", checkes existence and requires when platform is not android', ->

            Ti.Platform.name = 'iPhone'

            Ti.Filesystem.getFile = (a, b) ->
                exists: -> true

            abc = requireFile(__dirname + '/sample-files/abc')
            assert abc is 'abc'


        it 'adds suffix ".js", checkes existence and throws an error when platform is not android and file does not exist', ->

            Ti.Platform.name = 'iPhone'

            Ti.Filesystem.getFile = (a, b) ->

                exists: -> false

            assert.throws(-> requireFile(__dirname + '/sample-files/abc'))



