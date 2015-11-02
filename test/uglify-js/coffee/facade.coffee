
Facade = require 'base-domain'

class CustomFacade extends Facade

    constructor: (options = {}) ->

        options.dirname = __dirname + '/domain'
        options.master = true

        super


module.exports = CustomFacade
