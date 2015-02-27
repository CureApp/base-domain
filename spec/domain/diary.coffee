
Entity = require('../../src/facade').Entity


class Diary extends Entity

    @properties:
        title   : @TYPES.STRING
        comment : @TYPES.STRING
        author  : @TYPES.MODEL 'member'
        date    : @TYPES.DATE

module.exports = Diary
