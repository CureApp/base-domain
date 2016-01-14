
{ ValueObject } = require 'base-domain'

class Url extends ValueObject

    @properties:
        value: @TYPES.STRING

module.exports = Url
