
{ ValueObject } = require('../../base-domain')

class BookInfo extends ValueObject

    @properties:
        title: @TYPES.STRING
        isbn:  @TYPES.MODEL 'isbn'
        author: @TYPES.MODEL 'member'


module.exports = BookInfo
