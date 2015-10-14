
DomainError = require './domain-error'
debug = null

{ normalize } = require('path')
fs = require('fs')

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
    @param {Object} [options.data={}] default data, merged to dataPool
    @param {String} [options.debug] if true, shows debug log
    ###
    constructor: (@facade, options = {}) ->

        debugMode = options.debug ? !!@facade.debug
        if debugMode
            require('debug').enable('base-domain:fixture')

        debug = require('debug')('base-domain:fixture')

        # loading model files
        @fxModelMap = {}

        dirnames =
            if options.dirname?
                if Array.isArray options.dirname
                    options.dirname
                else
                    [ options.dirname ]

            else
                [ __dirname + '/fixtures' ]

        for dirname in dirnames
            dataDir = normalize dirname + '/data'

            for file in fs.readdirSync(dataDir)
                [ modelName, ext ] = file.split('.')
                continue if ext not in ['js', 'coffee', 'json']

                setting = require(dataDir + '/' + file)
                @fxModelMap[modelName] = new FixtureModel(@, modelName, setting, normalize dirname)


        # initial data pool
        @dataPool =
            if options.data? and typeof options.data is 'object'
                JSON.parse JSON.stringify options.data
            else
                {}

        @dataPool[modelName] ?= {} for modelName of @fxModelMap


    ###*
    add data to pool for model's data

    @method addToDataPool
    @return {Object}
    ###
    addToDataPool: (modelName, dataName, data) ->

        @dataPool[modelName][dataName] = data


    ###*
    inserts data to datasource

    @param {Array} names list of fixture models to insert data
    @method insert
    @return {Promise}
    ###
    insert: (names) ->

        names ?= (name for name of @fxModelMap)

        names = [names] if typeof names is 'string'

        modelNames = @resolveDependencies(names)

        if not modelNames.length
            debug 'no data to insert.'
            return Promise.resolve(true)


        debug("insertion order: #{modelNames.join(' -> ')}")


        do insert = =>

            modelName = modelNames.shift()

            if not modelName?
                return Promise.resolve(true)

            fxModel = @fxModelMap[modelName]

            fxModel.insert().then ->
                insert()

            .catch (e) =>
                console.error e.stack

                return false


    ###*
    adds dependent models, topological sort

    @private
    @param {Array} names list of fixture models to insert data
    @method resolveDependencies
    @return {Array} model names
    ###
    resolveDependencies: (names) ->

        # adds dependent models 
        namesWithDependencies = []

        for el in names
            do add = (name = el) =>

                return if name in namesWithDependencies

                namesWithDependencies.push name

                fxModel = @fxModelMap[name]

                unless fxModel
                    throw new DomainError('base-domain:modelNotFound', "model '#{name}' is not found. It might be written in some 'dependencies' property.")

                add(depname) for depname in fxModel.dependencies


        # topological sort
        visited = {}
        sortedNames = []

        for el in namesWithDependencies

            do visit = (name = el, ancestors = []) =>

                fxModel = @fxModelMap[name]

                return if visited[name]?

                ancestors.push(name)

                visited[name] = true

                for depname in fxModel.dependencies

                    if depname in ancestors
                        throw new DomainError('base-domain:dependencyLoop', 'dependency chain is making loop')


                    visit(depname, ancestors.slice())

                sortedNames.push(name)

        return sortedNames




###*

@class FixtureModel
###
class FixtureModel

    ###*
    @constructor
    ###
    constructor: (@fx, @name, setting = {}, @dirname) ->

        @dependencies = setting.dependencies ? []
        @data = setting.data ? ->



    ###*
    inserts data to datasource

    @method insert
    @return {Promise}
    ###
    insert: ->

        modelDataMap =
            switch typeof @data
                when 'string'
                    @readTSV(@data)
                when 'function'
                    @data(@fx.dataPool)


        dataNames = Object.keys modelDataMap

        debug("inserting #{dataNames.length} data into #{@name}")

        factory = @fx.facade.createFactory(@name)
        repository = @fx.facade.createRepository(@name)

        do insert = =>

            if dataNames.length is 0
                return Promise.resolve(true)

            dataName = dataNames.shift()
            data = modelDataMap[dataName]

            model = factory.createFromObject data

            Promise.resolve(repository.save(model)).then (savedModel) =>

                @fx.addToDataPool(@name, dataName, savedModel)
                insert()



    ###*
    read TSV, returns model data

    @method readTSV
    ###
    readTSV: (filename) ->


        objs = {}

        lines = fs.readFileSync(@dirname + '/tsvs/' + filename, 'utf8').split('\n')

        tsv = (line.split('\t') for line in lines)

        names = tsv.shift() # first line is title
        names.shift() # first column is dataName

        for data in tsv
            obj = {}
            dataName = data.shift()

            break if not dataName # omit reading all lines below the line whose dataName is empty

            for name, i in names
                break if not name # omit reading all columns at right side of the column whose title is empty
                value = data[i]
                value = Number(value) if value.match(/^[0-9]+$/) # regard number-like values as a number
                obj[name] = value

            objs[dataName] = obj

        return objs





module.exports = Fixture
