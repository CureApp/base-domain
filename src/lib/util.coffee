
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
        fileInfo = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, path)

        if fileInfo.exists()
            return require path
        else
            throw new Error("#{path}: no such file.")


module.exports = Util
