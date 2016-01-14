
{ ValueObject } = require('../../base-domain')

class BookInfo extends ValueObject

    @properties:
        title: @TYPES.STRING
        author: @TYPES.MODEL 'member'


module.exports = BookInfo
