'use strict'

fs = require 'fs'
EntityPool = require './entity-pool'
DomainError = require './lib/domain-error'
{ normalize } = require('path')
{ isPromise } = require('./util')

debug = require('debug')('base-domain:fixture-loader')

###*
Load fixture data (only works in Node.js)

@class FixtureLoader
@module base-domain
###
class FixtureLoader

    constructor: (@facade, @fixtureDirs = []) ->
        if not Array.isArray @fixtureDirs
            @fixtureDirs = [ @fixtureDirs ]

        @entityPool = new EntityPool
        @fixturesByModel = {}


    ###*
    @method load
    @public
    @param {Object} [options]
    @param {Boolean} [options.async]
    @return {EntityPool|Promise(EntityPool)}
    ###
    load: (options = {}) ->

        modelNames = []
        for fixtureDir in @fixtureDirs

            for file in fs.readdirSync fixtureDir + '/data'
                [ modelName, ext ] = file.split('.')
                continue if ext not in ['coffee', 'js', 'json']
                fx = require(fixtureDir + '/data/' + file)
                fx.fixtureDir = fixtureDir
                @fixturesByModel[modelName] = fx
                modelNames.push modelName

        modelNames = @topoSort(modelNames)

        names = options.names ? modelNames

        modelNames = modelNames.filter (name) -> name in names

        if options.async
            return @saveAsync(modelNames).then => @entityPool

        else
            for modelName in modelNames
                @loadAndSaveModels(modelName)

            return @entityPool


    ###*
    @private
    ###
    saveAsync: (modelNames) ->

        if not modelNames.length
            return Promise.resolve(true)

        modelName = modelNames.shift()

        Promise.resolve(@loadAndSaveModels(modelName)).then =>
            @saveAsync(modelNames)

        .catch (e) =>
            console.error e.stack
            return false


    ###*
    @private
    ###
    loadAndSaveModels: (modelName) ->

        fx = @fixturesByModel[modelName]

        data =
            switch typeof fx.data
                when 'string'
                    @readTSV(fx.fixtureDir, fx.data)
                when 'function'
                    fx.data.call(new Scope(@, fx), @entityPool)
                when 'object'
                    fx.data

        try
            repo = @facade.createPreferredRepository(modelName) # TODO: enable to add 2nd argument (noParent: boolean)
        catch e
            console.error e.message
            return

        ids = Object.keys(data)
        debug('inserting %s models into %s', ids.length, modelName)

        # save models portion by portion, considering parallel connection size
        PORTION_SIZE = 5
        do saveModelsByPortion = =>
            return if ids.length is 0

            idsPortion = ids.slice(0, PORTION_SIZE)
            ids = ids.slice(idsPortion.length)

            results = for id in idsPortion
                obj = data[id]
                obj.id = id
                @saveModel(repo, obj)

            if isPromise results[0]
                Promise.all(results).then =>
                    saveModelsByPortion()
            else
                saveModelsByPortion()



    saveModel: (repo, obj) ->

        result = repo.save obj,
            method : 'create'
            fixtureInsertion : true # save even if the repository is master
            include:
                entityPool: @entityPool

        if isPromise result
            result.then (entity) =>
                @entityPool.set entity

        else
            @entityPool.set result



    ###*
    topological sort

    @method topoSort
    @private
    ###
    topoSort: (names) ->

        # adds dependent models
        namesWithDependencies = []

        for el in names
            do add = (name = el) =>

                return if name in namesWithDependencies

                namesWithDependencies.push name

                fx = @fixturesByModel[name]

                unless fx?
                    throw new DomainError 'base-domain:modelNotFound',
                        "model '#{name}' is not found. It might be written in some 'dependencies' property."

                add(depname) for depname in fx.dependencies ? []


        # topological sort
        visited = {}
        sortedNames = []

        for el in namesWithDependencies

            do visit = (name = el, ancestors = []) =>

                fx = @fixturesByModel[name]

                return if visited[name]?

                ancestors.push(name)

                visited[name] = true

                for depname in fx.dependencies ? []

                    if depname in ancestors
                        throw new DomainError 'base-domain:dependencyLoop',
                            'dependency chain is making loop'

                    visit(depname, ancestors.slice())

                sortedNames.push(name)

        return sortedNames


    ###*
    read TSV, returns model data

    @method readTSV
    @private
    ###
    readTSV: (fixtureDir, file) ->

        objs = {}

        lines = fs.readFileSync(fixtureDir + '/tsvs/' + file, 'utf8').split('\n')

        tsv = (line.split('\t') for line in lines)

        names = tsv.shift() # first line is title
        names.shift() # first column is id

        for data in tsv
            obj = {}
            id = data.shift()
            obj.id = id

            break if not id # omit reading all lines below the line whose id is empty

            for name, i in names
                break if not name # omit reading all columns at right side of the column whose title is empty
                value = data[i]
                value = Number(value) if value.match(/^[0-9]+$/) # regard number-like values as a number
                obj[name] = value

            objs[obj.id] = obj

        return objs


###*
'this' property in fixture's data function

this.readTSV('xxx.tsv') is available

    module.exports = {
        data: function(entityPool) {
            this.readTSV('model-name.tsv');
        }
    };

@class Scope
@private
###
class Scope

    constructor: (@loader, @fx) ->

    ###*
    @method readTSV
    @param {String} filename filename (directory is automatically set)
    @return {Object} tsv contents
    ###
    readTSV: (filename) ->
        @loader.readTSV(@fx.fixtureDir, filename)


module.exports = FixtureLoader
