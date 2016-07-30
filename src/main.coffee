Facade = require('./lib/facade')

Facade.fs = require('fs')
Facade.csvParse = require('csv-parse/lib/sync')


###*
Requires js file
in Titanium, file-not-found-like-exception occurred in require function cannot be caught.
Thus, before require function is called, check the existence of the file.
Only in iOS this check occurs.
File extension must be '.js' in Titanium.

@param {String} file name without extension
@return {any} required value
###
Facade.requireFile = (file) ->
    if not Ti?
        ret = require file
        return if ret.default then ret.default else ret

    # in Titanium
    path = file + '.js'

    if Ti.Platform.name is 'android'
        return require file

    fileInfo = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, path)

    if fileInfo.exists()
        return require file
    else
        throw new Error("#{path}: no such file.")


###*
Parse a file as JSON format.
In Titanium, requiring JSON does not work.

@param {String} path
@return {any} required value
###
Facade.requireJSON = (path) ->
    if not Ti?
        return require path

    fileInfo = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, path)

    if fileInfo.exists()
        return JSON.parse fileInfo.read().getText()
    else
        throw new Error("#{path}: no such file.")


module.exports = Facade
