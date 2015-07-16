through = require 'through'
fs      = require 'fs'
coffee  = require 'coffee-script'

initialCodeGenerated = false

module.exports = (file, options) ->

    throwError() if not options.dirname

    if initialCodeGenerated
        return through()

    else
        initialCode = getInitialCode(options.dirname)
        initialCodeGenerated = true

        data = ''
        write = (buf) -> data += buf

        end = ->
            @queue initialCode
            @queue data
            @queue null

        return through write, end



getInitialCode = (dirname) ->

    basename = require('path').basename dirname
    _ = ' ' # spacer for indent

    coffeeCode = """
        Facade = require 'base-domain'

        Facade::init = ->
        #{_}return unless @dirname.match '#{basename}'\n
    """

    for filename in getFiles(dirname)

        path = dirname + '/' + filename
        name = filename.split('.')[0]

        coffeeCode += """
            #{_}@addClass '#{name}', require('#{path}')\n
        """


    coffeeCode += "#{_}return\n"

    return coffee.compile(coffeeCode, bare: true)



getFiles = (dirname) ->

    fileInfoDict = {}

    for filename in fs.readdirSync(dirname)

        klass = require dirname + '/' + filename
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



throwError = ->
    throw new Error """
        dirname must be passed.

        browserify -t [ base-domain/ify --dirname dirname ]

    """
