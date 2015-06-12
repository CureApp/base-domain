
class Util

    ###*
    converts hyphenation to camel case

        'shinout-no-macbook-pro' => 'ShinoutNoMacbookPro'
        'shinout-no-macbook-pro' => 'shinoutNoMacbookPro' # if lowerFirst = true

    @method camelize
    @private
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
    @private
    @static
    @param {String} hyphened
    @return {String} cameled
    ###
    @hyphenize: (cameled) ->

        cameled = cameled.charAt(0).toUpperCase() + cameled.slice(1)
        cameled.replace(/([A-Z])/g, (st)-> '-' + st.charAt(0).toLowerCase()).slice(1)

module.exports = Util
