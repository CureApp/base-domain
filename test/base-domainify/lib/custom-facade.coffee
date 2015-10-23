
Facade = require('base-domain')

class CustomFacade extends Facade

    constructor: ->
        super
        @isCustom = true

module.exports = CustomFacade
