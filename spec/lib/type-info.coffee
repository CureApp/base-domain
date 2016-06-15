
{ TypeInfo, ModelProps } = require '../others'
{ Entity, ValueObject, BaseList, BaseModel } = require('../base-domain')
{ TYPES } = BaseModel

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


    describe 'ENUM definition', ->

        it 'throws an error when first argument of @TYPES.ENUM is not an array', ->

            createCountryEnum = -> TYPES.ENUM { Japan: 1, Korea: 2, China: 3 }

            assert.throws(createCountryEnum, /Values must be an array\./)


        it 'throws an error when first argument of @TYPES.ENUM is not an array of string', ->

            createCountryEnum = -> TYPES.ENUM [ 1, 2, 3 ]

            assert.throws(createCountryEnum, /Values must be an array of string/)


        it 'throws an error when first argument of @TYPES.ENUM contains duplicated entries', ->

            createCountryEnum = -> TYPES.ENUM [ 'Mexico', 'Jamaica', 'Mexico']

            assert.throws(createCountryEnum, /Value 'Mexico' is duplicated\./)


        it 'throws an error when the default value of @TYPES.ENUM is invalid string', ->

            createCountryEnum = -> TYPES.ENUM [ 'Mexico', 'Jamaica', 'Japan'], 'The United States'

            assert.throws(createCountryEnum, /Invalid default value 'The United States'/)


        it 'throws an error when the default value of @TYPES.ENUM is invalid number', ->

            createCountryEnum = -> TYPES.ENUM [ 'Mexico', 'Jamaica', 'Japan'], 3

            assert.throws(createCountryEnum, /Invalid default value '3'/)


    describe 'after parsing a valid model definition', ->

        beforeEach ->

            @facade = require('../create-facade').create()

            class A extends Entity
                @properties:
                    str        : @TYPES.STRING
                    num        : @TYPES.NUMBER
                    date       : @TYPES.DATE
                    createdAt  : @TYPES.CREATED_AT
                    createdAt2 : @TYPES.CREATED_AT
                    updatedAt  : @TYPES.UPDATED_AT
                    updatedAt2 : @TYPES.UPDATED_AT
                    b          : @TYPES.MODEL 'b'
                    c          : @TYPES.MODEL 'c'
                    bs         : @TYPES.MODEL 'b-list'
                    cs         : @TYPES.MODEL 'c-list'
                    en1        : @TYPES.ENUM ['NOT_DISTRIBUTED', 'DISTRIBUTED', 'COMPLETED']
                    en2        : @TYPES.ENUM ['a123', 'a234', 'a345'], 'a234'
                    en3        : @TYPES.ENUM ['Japan', 'Thai', 'Canada'], 2

            class BList extends BaseList
                @itemModelName: 'b'

            class CList extends BaseList
                @itemModelName: 'c'

            @facade.addClass('a', A)
            @facade.addClass('b', class B extends Entity)
            @facade.addClass('c', class C extends ValueObject)
            @facade.addClass('b-list', BList)
            @facade.addClass('c-list', CList)

            @prop = @facade.getModel('a').properties

            @modelProps = new ModelProps('a', A.properties, @facade.getModule())


        it 'has dates collecting prop of DATE, CREATED_AT and UPDATED_AT', ->
            assert.deepEqual @modelProps.dates, ['date', 'createdAt', 'createdAt2', 'updatedAt', 'updatedAt2']


        it 'has createdAt whose value is CREATED_AT at last column', ->
            assert @modelProps.createdAt is 'createdAt2'

        it 'has updatedAt whose value is UPDATED_AT at last column', ->
            assert @modelProps.updatedAt is 'updatedAt2'


        it 'set enum default values', ->
            a = @facade.createModel('a')
            assert a.en1 is undefined
            assert a.en2 is 1
            assert a.en3 is 2


        describe 'isEntity', ->

            it 'returns whether the prop is entity', ->
                assert @modelProps.isEntity('b')
                assert @modelProps.isEntity('c') is false
                assert @modelProps.isEntity('date') is false
                # assert @modelProps.isEntity('xxx') is false
