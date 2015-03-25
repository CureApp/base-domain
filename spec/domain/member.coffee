
Entity = require('../base-domain').Entity


class Member extends Entity

    @properties:
        firstName    : @TYPES.STRING
        age          : @TYPES.NUMBER
        registeredAt : @TYPES.DATE
        hobbies      : @TYPES.MODELS 'hobby'
        newHobbies   : @TYPES.MODELS 'hobby', 'newHobbyIds'
        mCreatedAt   : @TYPES.CREATED_AT
        mUpdatedAt   : @TYPES.UPDATED_AT


module.exports = Member
