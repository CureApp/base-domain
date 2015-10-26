
fs = require 'fs'


###*
Load fixture data (only works in Node.js)

@class FixtureLoader
@module base-domain
###
class FixtureLoader

    constructor: (@fixtureDir) ->


    ###*
    @method load
    @public
    ###
    load: ->

        tables = {}

        for file in fs.readdirSync @fixtureDir + '/data'
            [ modelName, ext ] = file.split('.')

            continue if ext not in ['coffee', 'js']

            tables[modelName] = @loadFile(file)

        return tables


    ###*
    load one data file

    @method loadFile
    @private
    ###
    loadFile: (file) ->

        [ modelName, ext ] = file.split('.')
        { data } = require(@fixtureDir + '/data/' + file)

        switch typeof data
            when 'string'
                return @readTSV(data)

            when 'function'
                return data.call(@, {})

            when 'object'
                return data


    ###*
    read TSV, returns model data

    @method readTSV
    @private
    ###
    readTSV: (file) ->

        objs = {}

        lines = fs.readFileSync(@fixtureDir + '/tsvs/' + file, 'utf8').split('\n')

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


module.exports = FixtureLoader
