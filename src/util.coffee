
deepEqual = require 'deep-eql'
clone     = require 'clone'

###*
@method Util
###
class Util

    @deepEqual: (a, b) ->

        deepEqual(a, b)


    @clone: (v) ->

        clone v


module.exports = Util
