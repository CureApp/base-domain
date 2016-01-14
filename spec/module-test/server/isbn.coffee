
{ ValueObject } = require('../../base-domain')

class Isbn extends ValueObject
    @properties:
        value: @TYPES.STRING


module.exports = Isbn
