
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
    constructor: (domainPath) ->

        @masterDirPath = domainPath + '/master-data'
        @masterJSONPath = @masterDirPath + '/all.json'
        @memories = {}



    ###*
    load data from directory(Node.js) or JSON (other environments)

    @method init
    @public
    @chainable
    ###
    init: ->

        if not Ti? and not window?
            @build()

        else
            plainMemories = @loadFromJSON()

            for modelName, plainMemory of plainMemories
                @memories[modelName] = MemoryResource.restore(plainMemory)

        @


    ###*
    load data from JSON file
    This implementation is mainly for Titanium.
    Overwritten by base-domainify when browserify packs into one package.

    @method loadFromJSON
    @private
    ###
    loadFromJSON: ->

        try
            return Util.requireJSON @masterJSONPath

        catch e
            console.error("""
                base-domain: [warning] MasterDataResource could not load from path '#{@masterJSONPath}'
            """)


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
        fs.writeFileSync @masterJSONPath, JSON.stringify @toPlainObject(), null, 1


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
