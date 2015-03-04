
Entity = require('../../src/lib/facade').Entity


class Hobby extends Entity

    @properties:
        name    : @TYPES.STRING

    getName: ->
        return @name

module.exports = Hobby
