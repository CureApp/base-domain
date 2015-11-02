
{ ValueObject } = require 'base-domain'

class Link extends ValueObject

    @properties:
        url: @TYPES.STRING
        title: @TYPES.STRING
        summary: @TYPES.STRING
        photo: @TYPES.MODEL 'photo'

module.exports = Link
