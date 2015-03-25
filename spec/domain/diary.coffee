
Entity = require('../base-domain').Entity


class Diary extends Entity

    @properties:
        title    : @TYPES.STRING
        comment  : @TYPES.STRING
        author   : @TYPES.MODEL 'member'
        coauthor : @TYPES.MODEL 'member', 'coauthorId'
        date     : @TYPES.DATE
        upd      : @TYPES.UPDATED_AT

module.exports = Diary
