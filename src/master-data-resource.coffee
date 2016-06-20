'use strict'

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
    constructor: (@facade) ->

        { dirname } = @facade

        @masterDirPath  = @constructor.getDirPath(dirname)
        @masterJSONPath = @constructor.getJSONPath(dirname)
        @memories = {}


    ###*
    Get master data dir

    @method getDirPath
    @public
    @static
    @return {String}
    ###
    @getDirPath: (dirname) -> dirname + '/master-data'

    ###*
    Get master JSON path

    @method getJSONPath
    @public
    @static
    @return {String}
    ###
    @getJSONPath: (dirname) -> @getDirPath(dirname) + '/all.json'


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
    getMemoryResource: (modelName) ->
        @memories[modelName] ?= new MemoryResource


    ###*
    Create JSON file from tsv files (**only called by Node.js**)

    @method build
    ###
    build: ->

        FixtureLoader = require './fixture-loader'

        new FixtureLoader(@facade, @masterDirPath).load()
        { fs } = @facade.constructor # only defined in Node.js
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
