'use strict'

deepEqual = require 'deep-eql'
clone     = require 'clone'

###*
@method Util
###
class Util

    ###*
    converts hyphenation to camel case

        'shinout-no-macbook-pro' => 'ShinoutNoMacbookPro'
        'shinout-no-macbook-pro' => 'shinoutNoMacbookPro' # if lowerFirst = true

    @method camelize
    @static
    @param {String} hyphened
    @param {Boolean} [lowerFirst=false] make capital char lower
    @return {String} cameled
    ###
    @camelize: (hyphened, lowerFirst = false) ->
       (for substr, i in hyphened.split('-')
           if i is 0 and lowerFirst
               substr
           else
               substr.charAt(0).toUpperCase() + substr.slice(1)
       ).join('')


    ###*
    converts hyphenation to camel case

        'ShinoutNoMacbookPro' => 'shinout-no-macbook-pro'
        'ABC' => 'a-b-c' # current implementation... FIXME ?

    @method hyphenize
    @static
    @param {String} hyphened
    @return {String} cameled
    ###
    @hyphenize: (cameled) ->

        cameled = cameled.charAt(0).toUpperCase() + cameled.slice(1)
        cameled.replace(/([A-Z])/g, (st)-> '-' + st.charAt(0).toLowerCase()).slice(1)


    ###*
    requires js file
    in Titanium, file-not-found-like-exception occurred in require function cannot be caught.
    Thus, before require function is called, check the existence of the file.
    Only in iOS this check occurs.
    File extension must be '.js' in Titanium.

    @method requireFile
    @static
    @param {String} file name without extension
    @return {any} required value
    ###
    @requireFile: (file) ->
        if not Ti?
            return require file

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

    @method requireJSON
    @static
    @param {String} path
    @return {any} required value
    ###
    @requireJSON: (path) ->
        if not Ti?
            return require path

        fileInfo = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, path)

        if fileInfo.exists()
            return JSON.parse fileInfo.read().getText()
        else
            throw new Error("#{path}: no such file.")



    ###*
    in Titanium, "A instanceof B" sometimes fails.
    this is the alternative.

    @method isInstance
    @static
    @param {Object} instance
    @param {Function} class
    @return {Boolean} A is instance of B
    ###
    @isInstance: (instance, Class) ->

        if not Ti?
            return instance instanceof Class

        return false if not instance?.constructor
        return true if Class is Object

        className = Class.name

        until instance.constructor is Object

            return true if instance.constructor.name is className

            instance = Object.getPrototypeOf instance

        return false

    @deepEqual: (a, b) ->

        deepEqual(a, b)


    @clone: (v) ->

        clone v


    ###*
    Check if the given value is instanceof Promise.

    "val instanceof Promise" fails when native Promise and its polyfill are mixed
    ###
    @isPromise: (val) ->

        typeof val?.then is 'function'


module.exports = Util
