
Entity = require('../../src/lib/facade').Entity


class Member extends Entity

    @properties:
        firstName    : @TYPES.STRING
        age          : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        hobbies      : @TYPES.MODELS 'hobby'
        mCreatedAt   : @TYPES.CREATED_AT
        mUpdatedAt   : @TYPES.UPDATED_AT


module.exports = Member
