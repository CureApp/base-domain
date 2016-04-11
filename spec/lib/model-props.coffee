
Facade = require '../base-domain'

{ Entity, ValueObject, BaseList } = Facade

{ ModelProps } = require '../others'

describe 'ModelProps', ->

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
            assert @modelProps.isEntity('xxx') is false
