
through = require 'through'
fs      = require 'fs'
path    = require 'path'
coffee  = require 'coffee-script'
require('coffee-script/register')

path.isAbsolute ?= (str) -> str.charAt(0) is '/'

MasterDataResource = require './master-data-resource'

class BaseDomainify


    constructor: (@moduleName = 'base-domain')->

        @initialCodeGenerated = false


    ###*
    get CoffeeScript code of adding addClass methods to all domain files

    @method run
    @public
    @return {String} code CoffeeScript code
    ###
    run: (file, options = {}) ->

        return through() if @initialCodeGenerated

        { dirname } = options

        @throwError() if not dirname

        if path.isAbsolute dirname
            @absolutePath = dirname
        else
            @absolutePath = process.cwd() + '/' + dirname

        dir = path.dirname(file)
        @relativePath = path.relative(dir, dirname)

        if @relativePath.charAt(0) isnt '.'
            @relativePath = './' + @relativePath

        initialCode = @getInitialCode(options.dirname)

        @initialCodeGenerated = true

        data = ''
        write = (buf) -> data += buf
        end = -> @queue val for val in [initialCode, data, null]

        return through write, end


    ###*
    get CoffeeScript code of adding addClass methods to all domain files

    @method getInitialCode
    @private
    @return {String} code CoffeeScript code
    ###
    getInitialCode: ->

        basename = require('path').basename @relativePath
        _ = ' ' # spacer for indent

        coffeeCode = """
            Facade = require '#{@moduleName}'

            Facade::init = ->
            #{_}return unless @dirname.match '#{basename}'\n
        """

        if masterJSONPath = @getMasterJSONPath()
            coffeeCode += """
                #{_}@master?.loadFromJSON = -> require('#{masterJSONPath}')\n
            """

        for filename in @getFiles()

            name = filename.split('.')[0]
            path = @relativePath + '/' + name

            coffeeCode += """
                #{_}@addClass require('#{path}')\n
            """

        coffeeCode += "#{_}return\n"

        return coffee.compile(coffeeCode, bare: true)


    ###*
    @method getCodeOfMasterData
    @private
    @return {String} path
    ###
    getMasterJSONPath: ->

        master = new MasterDataResource(@absolutePath)

        try
            master.build()

            { masterJSONPath } = master

            return '' if not fs.existsSync(masterJSONPath)

            relPath = new MasterDataResource(@relativePath).masterJSONPath

            return relPath

        catch e
            return ''




    ###*
    get domain files to load

    @method getFiles
    @private
    @return {Array} filenames
    ###
    getFiles: ->

        fileInfoDict = {}

        for filename in fs.readdirSync(@absolutePath)

            [ name, ext ] = filename.split('.')
            continue if ext not in ['js', 'coffee']

            klass = require @absolutePath + '/' + filename

            continue if typeof klass.getName isnt 'function'
            continue if klass.getName() isnt name

            fileInfoDict[name] = filename: filename, klass: klass

        files = []
        for name, fileInfo of fileInfoDict

            { klass, filename } = fileInfo
            continue if filename in files

            ParentClass = Object.getPrototypeOf(klass::).constructor

            if typeof ParentClass.getName is 'function' and pntFileName = fileInfoDict[ParentClass.getName()]?.filename

                files.push pntFileName unless pntFileName in files

            files.push filename

        return files


    ###*
    throw error

    @method throwError
    @private
    ###
    throwError:  ->
        throw new Error """
            dirname must be passed.

            browserify -t [ base-domain/ify --dirname dirname ]

        """


module.exports = BaseDomainify
