
TypeInfo = require '../../src/lib/type-info'

describe 'TypeInfo', ->

    describe '@createModelListType', ->

        it 'returns TypeInfo representing MODEL_LIST', ->

            typeInfo = TypeInfo.createModelListType('hobby')

            expect(typeInfo).to.have.property('name', 'MODEL_LIST')
            expect(typeInfo).to.have.property('model', 'hobby')
            expect(typeInfo).to.have.property('idPropName', 'hobbyIds')
            expect(typeInfo).to.have.property('listName', 'hobby-list')


        it 'returns TypeInfo with listName', ->

            typeInfo = TypeInfo.createModelListType('hobby', name: 'another-hobby-list')
            expect(typeInfo).to.have.property('listName', 'another-hobby-list')


        it 'parses 2nd argument as listName when it is string ', ->

            typeInfo = TypeInfo.createModelListType('hobby', 'happy-hobby-list')
            expect(typeInfo).to.have.property('listName', 'happy-hobby-list')

