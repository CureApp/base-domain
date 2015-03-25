
Entity = require('../base-domain').Entity


class Hobby extends Entity

    @properties:
        name    : @TYPES.STRING

    getName: ->
        return @name

module.exports = Hobby
