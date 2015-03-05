
BaseFactory = require('../../src/lib/facade').BaseFactory


class HobbyFactory extends BaseFactory

    @modelName: 'hobby'

    beforeCreateFromObject: (obj) ->
        obj.isUnique = true

        return obj


    afterCreateModel: (model) ->
        model.isAwesomeHobby = true

        return model

module.exports = HobbyFactory
