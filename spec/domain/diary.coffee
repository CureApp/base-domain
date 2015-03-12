
Entity = require('../../src/lib/facade').Entity


class Diary extends Entity

    @properties:
        title   : @TYPES.STRING
        comment : @TYPES.STRING
        author  : @TYPES.MODEL 'member'
        date    : @TYPES.DATE
        upd     : @TYPES.UPDATED_AT

module.exports = Diary
