
through = require 'through'
fs      = require 'fs'
coffee  = require 'coffee-script'

class BaseDomainify

    @moduleName = 'base-domain'

    constructor: ->

        @initialCodeGenerated = false


    ###*
    get CoffeeScript code of adding addClass methods to all domain files

    @method run
    @public
    @return {String} code CoffeeScript code
    ###
    run: (file, options = {}) ->

        @dirname = options.dirname

        @throwError() if not @dirname

        return through() if @initialCodeGenerated

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

        basename = require('path').basename @dirname
        _ = ' ' # spacer for indent

        coffeeCode = """
            Facade = require '#{@constructor.moduleName}'

            Facade::init = ->
            #{_}return unless @dirname.match '#{basename}'\n
        """

        for filename in @getFiles()

            path = @dirname + '/' + filename
            name = filename.split('.')[0]

            coffeeCode += """
                #{_}@addClass '#{name}', require('#{path}')\n
            """


        coffeeCode += "#{_}return\n"

        return coffee.compile(coffeeCode, bare: true)



    ###*
    get domain files to load

    @method getFiles
    @private
    @return {Array} filenames
    ###
    getFiles: ->

        fileInfoDict = {}

        for filename in fs.readdirSync(@dirname)

            klass = require @dirname + '/' + filename
            [ name, ext ] = filename.split('.')

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
