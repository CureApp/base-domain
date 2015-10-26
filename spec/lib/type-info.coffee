
TypeInfo = require '../../src/lib/type-info'

describe 'TypeInfo', ->

    describe '@createModelType', ->

        it 'returns TypeInfo with calculated idPropName', ->

            typeInfo = TypeInfo.createModelType('paris-match')

            expect(typeInfo).to.have.property('typeName', 'MODEL')
            expect(typeInfo).to.have.property('model', 'paris-match')
            expect(typeInfo).to.have.property('idPropName', 'parisMatchId')

        it 'returns TypeInfo with custom idPropName', ->

            typeInfo = TypeInfo.createModelType('paris-match', 'type')

            expect(typeInfo).to.have.property('typeName', 'MODEL')
            expect(typeInfo).to.have.property('model', 'paris-match')
            expect(typeInfo).to.have.property('idPropName', 'type')
