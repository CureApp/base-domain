
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

        expect(fs.existsSync @allJSON).to.be.false

        f = Facade.createInstance(dirname: @dirname, master: true)

        expect(f.master.memories.device).to.be.instanceof MemoryResource

        expect(fs.existsSync @allJSON).to.be.true


    describe 'in Titanium environment', ->

        before ->
            getGlobal().Ti = {}
            expect(Ti).to.exist
            fs.unlinkSync @allJSON
            @UtilRequireJSON = Util.requireJSON
            @UtilRequireFile = Util.requireFile
            Util.requireJSON = (file) -> require file
            Util.requireFile = (file) -> require file

            @consoleError = console.error
            console.error = ->


        it 'loads from JSON file', ->

            f = Facade.createInstance(dirname: @dirname, master: true)

            expect(f.master.memories.device).to.not.exist

            f.master.build()

            expect(fs.existsSync @allJSON).to.be.true

            f2 = Facade.createInstance(dirname: @dirname, master: true)

            expect(f2.master.memories.device).to.be.instanceof MemoryResource

        after ->
            getGlobal().Ti = undefined
            expect(Ti).not.to.exist
            Util.requireJSON = @UtilRequireJSON
            Util.requireFile = @UtilRequireFile
            console.error = @consoleError


