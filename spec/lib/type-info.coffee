
{ TypeInfo } = require '../others'

describe 'TypeInfo', ->

    describe '@createModelType', ->

        it 'returns TypeInfo with calculated idPropName', ->

            typeInfo = TypeInfo.createModelType('paris-match')

            assert typeInfo.typeName is 'MODEL'
            assert typeInfo.model is 'paris-match'
            assert typeInfo.idPropName is 'parisMatchId'

        it 'returns TypeInfo with custom idPropName', ->

            typeInfo = TypeInfo.createModelType('paris-match', 'type')

            assert typeInfo.typeName is 'MODEL'
            assert typeInfo.model is 'paris-match'
            assert typeInfo.idPropName is 'type'
