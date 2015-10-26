
{ MasterDataResource, MemoryResource, Util } = require './others'

fs = require 'fs'
getGlobal = -> @ # for setting global variable

describe 'MasterDataResource', ->

    before ->
        @dir = __dirname + '/empty'
        @allJSON = @dir + '/master-data/all.json'

        if fs.existsSync @allJSON
            fs.unlinkSync @allJSON


    it 'always loads data from data directory in Node.js environment', ->

        expect(fs.existsSync @allJSON).to.be.false

        master = new MasterDataResource(@dir).init()

        expect(master.memories.device).to.be.instanceof MemoryResource

        expect(fs.existsSync @allJSON).to.be.true


    describe 'in Titanium environment', ->

        before ->
            getGlobal().Ti = {}
            expect(Ti).to.exist
            fs.unlinkSync @allJSON
            @UtilRequireJSON = Util.requireJSON
            Util.requireJSON = (file) -> require file

            @consoleError = console.error
            console.error = ->


        it 'loads from JSON file', ->

            master = new MasterDataResource(@dir).init()

            expect(master.memories.device).to.not.exist

            master.build()

            master2 = new MasterDataResource(@dir).init()
            expect(master2.memories.device).to.be.instanceof MemoryResource

        after ->
            getGlobal().Ti = undefined
            expect(Ti).not.to.exist
            Util.requireJSON = @UtilRequireJSON
            console.error = @consoleError


