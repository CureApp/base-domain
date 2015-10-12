
TypeInfo = require '../../src/lib/type-info'

describe 'TypeInfo', ->

    describe '@createModelType', ->

        it 'returns TypeInfo with calculated idPropName', ->

            typeInfo = TypeInfo.createModelType('paris-match')

            expect(typeInfo).to.have.property('name', 'MODEL')
            expect(typeInfo).to.have.property('model', 'paris-match')
            expect(typeInfo).to.have.property('idPropName', 'parisMatchId')

        it 'returns TypeInfo with custom idPropName', ->

            typeInfo = TypeInfo.createModelType('paris-match', 'type')

            expect(typeInfo).to.have.property('name', 'MODEL')
            expect(typeInfo).to.have.property('model', 'paris-match')
            expect(typeInfo).to.have.property('idPropName', 'type')



    describe '@createModelListType', ->

        it 'returns TypeInfo representing MODEL_LIST', ->

            typeInfo = TypeInfo.createModelListType('hobby')

            expect(typeInfo).to.have.property('name', 'MODEL_LIST')
            expect(typeInfo).to.have.property('itemModel', 'hobby')
            expect(typeInfo).to.have.property('model', 'hobby-list')


        it 'returns TypeInfo with listName', ->

            typeInfo = TypeInfo.createModelListType('hobby', name: 'another-hobby-list')
            expect(typeInfo).to.have.property('model', 'another-hobby-list')


        it 'parses 2nd argument as listName when it is string ', ->

            typeInfo = TypeInfo.createModelListType('hobby', 'happy-hobby-list')
            expect(typeInfo).to.have.property('model', 'happy-hobby-list')


    describe '@createModelDictType', ->

        it 'returns TypeInfo representing MODEL_DICT', ->

            typeInfo = TypeInfo.createModelDictType('hobby')

            expect(typeInfo).to.have.property('name', 'MODEL_DICT')
            expect(typeInfo).to.have.property('itemModel', 'hobby')
            expect(typeInfo).to.have.property('model', 'hobby-dict')


        it 'returns TypeInfo with dictName', ->

            typeInfo = TypeInfo.createModelDictType('hobby', name: 'another-hobby-dict')
            expect(typeInfo).to.have.property('model', 'another-hobby-dict')


        it 'parses 2nd argument as dictName when it is string ', ->

            typeInfo = TypeInfo.createModelDictType('hobby', 'happy-hobby-dict')
            expect(typeInfo).to.have.property('model', 'happy-hobby-dict')

