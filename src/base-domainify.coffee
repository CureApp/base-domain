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


    for filename in fs.readdirSync(dirname)

        path = dirname + '/' + filename
        name = filename.split('.')[0]

        coffeeCode += """
            #{_}@addClass '#{name}', require('#{path}'), true\n
        """


    coffeeCode += "#{_}return\n"

    return coffee.compile(coffeeCode, bare: true)



throwError = ->
    throw new Error """
        dirname must be passed.

        browserify -t [ base-domain/ify --dirname dirname ]

    """
