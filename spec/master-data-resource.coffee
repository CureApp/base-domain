
Facade = require './base-domain'
{ MasterDataResource, MemoryResource, Util } = require './others'

fs = require 'fs'
getGlobal = -> @ # for setting global variable

describe 'MasterDataResource', ->

    before ->
        @dirname = __dirname + '/master-test'
        @allJSON = @dirname + '/master-data/all.json'

        if fs.existsSync @allJSON
            fs.unlinkSync @allJSON


    it 'always loads data from data directory in Node.js environment', ->

        assert fs.existsSync(@allJSON) is false

        f = Facade.createInstance(dirname: @dirname, master: true)

        assert f.master.memories.device instanceof MemoryResource

        assert fs.existsSync @allJSON


    describe 'in Titanium environment', ->

        before ->
            getGlobal().Ti = {}
            assert Ti?
            fs.unlinkSync @allJSON
            @FacadeRequireJSON = Facade.requireJSON
            @FacadeRequireFile = Facade.requireFile
            Facade.requireJSON = (file) -> require file
            Facade.requireFile = (file) -> require file

            @consoleError = console.error
            console.error = ->


        it 'loads from JSON file', ->

            f = Facade.createInstance(dirname: @dirname, master: true)

            assert not f.master.memories.device?

            f.master.build()

            assert fs.existsSync @allJSON

            f2 = Facade.createInstance(dirname: @dirname, master: true)

            assert f2.master.memories.device instanceof MemoryResource

        after ->
            getGlobal().Ti = undefined
            assert not Ti?
            Facade.requireJSON = @FacadeRequireJSON
            Facade.requireFile = @FacadeRequireFile
            console.error = @consoleError


