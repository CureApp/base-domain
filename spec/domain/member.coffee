
Entity = require('../../src/lib/facade').Entity


class Member extends Entity

    @properties:
        firstName    : @TYPES.STRING
        age          : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        hobbies      : @TYPES.MODELS 'hobby'

module.exports = Member
