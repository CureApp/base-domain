
BaseModule = require './base-module'

class CoreModule extends BaseModule

    constructor: (@path, @facade) ->
        @name = 'core'

    normalizeName: (modFullName) ->
        if modFullName.slice(0, 5) is 'core/'
            return modFullName.slice(5)
        return modFullName

module.exports = CoreModule
