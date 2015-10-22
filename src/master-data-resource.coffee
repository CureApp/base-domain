
Util = require './util'
MemoryResource = require './memory-resource'

###*

@class MasterDataResource
@implements ResourceClientInterface
###
class MasterDataResource

    ###*
    load master JSON file if exists

    @constructor
    ###
    constructor: (@masterDirPath) ->

        @memories = {}

        if not Ti? and not window? # = Node.js is expected
            @build()

        else
            @loadFromJSON()


    ###*
    load data from JSON file

    @method loadFromJSON
    @private
    ###
    loadFromJSON: ->

        try
            memories = Util.requireJSON @getMasterJSONPath()

            for modelName, plainMemory of memories
                @memories[modelName] = MemoryResource.restore(plainMemory)

        catch e
            console.error("""
                base-domain: [warning] MasterDataResource could not load from path '#{@getMasterJSONPath()}'
            """)


    ###*
    Get path of the JSON file containing all master data

    @method getMasterJSONPath
    @return {String} path
    ###
    getMasterJSONPath: ->
        @masterDirPath + '/all.json'



    ###*
    Get memory resource of the given modelName
    @method getMemoryResource
    @return {MemoryResource}
    ###
    getMemoryResource: (modelName) -> @memories[modelName]


    ###*
    Create JSON file from tsv files (**only called by Node.js**)

    @method build
    ###
    build: ->

        FixtureLoader = require './fixture-loader'

        data = new FixtureLoader(@masterDirPath).load()

        for modelName, modelData of data
            memory = @memories[modelName] = new MemoryResource()
            for id, value of modelData
                memory.create(value)

        fs = require 'fs'
        fs.writeFileSync @getMasterJSONPath(), JSON.stringify @toPlainObject(), null, 1


    ###*
    Create plain object

    @method toPlainObject
    @return {Object} plainObject
    ###
    toPlainObject: ->

        plainObj = {}

        for modelName, memory of @memories

            plainObj[modelName] = memory.toPlainObject()

        return plainObj


module.exports = MasterDataResource
