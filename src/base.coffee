
###*
###
class Base

    constructor: ->
        @facade = require('./base-facade').getInstance()


module.exports = Base
