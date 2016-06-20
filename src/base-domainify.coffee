'use strict'
through = require 'through'
fs      = require 'fs'
Path    = require 'path'
coffee  = require 'coffee-script'
require('coffee-script/register')

Path.isAbsolute ?= (str) -> str.charAt(0) is '/'

Facade = require './main'
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
    run: (@file, options = {}) ->

        return through() if @initialCodeGenerated

        { dirname, modules } = options
        @throwError() if not dirname

        modulePaths = {}

        for modNamePath in modules?.split(',') ? []
            [modName, path] = modNamePath.split(':')
            modulePaths[modName] = path

        initialCode = @getInitialCode(dirname, modulePaths)

        @initialCodeGenerated = true

        data = ''
        write = (buf) -> data += buf
        end = -> @queue val for val in [initialCode, data, null]

        return through write, end



    relativePath: (path) ->
        dir = Path.dirname(@file)
        relPath = Path.relative(dir, path)

        if relPath.charAt(0) isnt '.'
            relPath = './' + relPath

        return relPath


    absolutePath: (path) ->
        return path if Path.isAbsolute path
        return process.cwd() + '/' + path


    baseName: (path) ->
        return Path.basename path


    ###*
    get CoffeeScript code of adding addClass methods to all domain files

    @method getInitialCode
    @private
    @return {String} code CoffeeScript code
    ###
    getInitialCode: (dirname, modulePaths) ->
        basename = @baseName dirname
        _ = ' ' # spacer for indent

        coffeeCode = """
            Facade = require '#{@moduleName}'

            Facade::init = ->
            #{_}return unless @dirname.match '#{basename}'\n
        """

        coffeeCode += @getScriptToLoadCoreModule(dirname)

        coffeeCode += @getScriptToLoadModule(moduleName, path) for moduleName, path of modulePaths

        coffeeCode += "#{_}return\n"

        return coffee.compile(coffeeCode, bare: true)



    getScriptToLoadCoreModule: (dirname) ->

        _ = ' ' # spacer for indent
        coffeeCode = ''

        if masterJSONPath = @getMasterJSONPath(dirname)
            coffeeCode += """
                #{_}@master?.loadFromJSON = -> require('#{masterJSONPath}')\n
            """

        for filename in @getFiles(dirname)

            name = filename.split('.')[0]
            path = @relativePath(dirname) + '/' + name

            coffeeCode += """
                #{_}@addClass '#{name}', require('#{path}')\n
            """
        return coffeeCode


    getScriptToLoadModule: (moduleName, moduleDirname) ->

        basename = @baseName moduleDirname
        _ = ' ' # spacer for indent
        coffeeCode = """
            #{_}if @modules['#{moduleName}'] and @modules['#{moduleName}'].path.match '#{basename}'\n
        """

        for filename in @getFiles(moduleDirname)

            name = filename.split('.')[0]
            path = @relativePath(moduleDirname) + '/' + name

            coffeeCode += """
                #{_}#{_}@addClass '#{moduleName}/#{name}', require('#{path}')\n
            """
        return coffeeCode


    ###*
    @method getCodeOfMasterData
    @private
    @return {String} path
    ###
    getMasterJSONPath: (dirname) ->

        try
            facade = Facade.createInstance(dirname: @absolutePath(dirname), master: true)

            { masterJSONPath } = facade.master

            return '' if not fs.existsSync(masterJSONPath)

            relPath = MasterDataResource.getJSONPath(@relativePath(dirname))

            return relPath

        catch e
            return ''




    ###*
    get domain files to load

    @method getFiles
    @private
    @return {Array} filenames
    ###
    getFiles: (dirname) ->

        fileInfoDict = {}

        path = @absolutePath(dirname)

        for filename in fs.readdirSync(path)

            [ name, ext ] = filename.split('.')
            continue if ext not in ['js', 'coffee']

            klass = require path + '/' + filename

            fileInfoDict[name] = filename: filename, klass: klass

        files = []
        for name, fileInfo of fileInfoDict

            { klass, filename } = fileInfo
            continue if filename in files

            ParentClass = Object.getPrototypeOf(klass::).constructor

            if ParentClass.className and pntFileName = fileInfoDict[ParentClass.getName()]?.filename

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

            browserify -t [ base-domain/ify --dirname dirname --modules module1:/path/to/module1,module2:/path/to/module2 ]

        """


module.exports = BaseDomainify
