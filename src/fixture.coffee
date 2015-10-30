
DomainError = require './lib/domain-error'
FixtureLoader = require './fixture-loader'
debug = null


###*
load data from directory and generates fixtures
only available in Node.js

@class Fixture
@module base-domain
###
class Fixture


    ###*
    @constructor
    @param {Object} [options]
    @param {String|Array} [options.dirname='./fixtures'] director(y|ies) to have fixture files. /data, /tsvs should be included in the directory.
    @param {String} [options.debug] if true, shows debug log
    ###
    constructor: (@facade, options = {}) ->

        debugMode = options.debug ? !!@facade.debug
        if debugMode
            require('debug').enable('base-domain:fixture')

        debug = require('debug')('base-domain:fixture')

        @dirnames =
            if options.dirname?
                if Array.isArray options.dirname
                    options.dirname
                else
                    [ options.dirname ]

            else
                [ __dirname + '/fixtures' ]


    ###*
    inserts data to datasource

    @method insert
    @param {Array} names list of fixture models to insert data
    @public
    @return {Promise(EntityPool)}
    ###
    insert: (names) ->
        new FixtureLoader(@facade, @dirnames).load(async: true, names: names)


module.exports = Fixture
