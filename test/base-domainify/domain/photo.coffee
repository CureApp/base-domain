
{ ValueObject } = require 'base-domain'

class Photo extends ValueObject

    @properties:
        url: @TYPES.STRING
        title: @TYPES.STRING

module.exports = Photo
