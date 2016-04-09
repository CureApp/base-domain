
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

        @facade.addClass('a', A)
        @facade.addClass('b', class B extends Entity)
        @facade.addClass('c', class C extends ValueObject)
        @facade.addClass('b-list', class BList extends BaseList)
        @facade.addClass('c-list', class CList extends BaseList)

        @prop = @facade.getModel('a').properties

        @modelProps = new ModelProps('a', A.properties, @facade.getModule())


    it 'has dates collecting prop of DATE, CREATED_AT and UPDATED_AT', ->
        expect(@modelProps.dates).to.eql ['date', 'createdAt', 'createdAt2', 'updatedAt', 'updatedAt2']


    it 'has createdAt whose value is CREATED_AT at last column', ->
        assert @modelProps.createdAt is 'createdAt2'

    it 'has updatedAt whose value is UPDATED_AT at last column', ->
        assert @modelProps.updatedAt is 'updatedAt2'

    it 'has models collecting MODELs (ValueObject and Entities, Collections)', ->
        expect(@modelProps.models).to.eql ['b', 'c', 'bs', 'cs']

    it 'has entities collecting MODELs who extend Entity', ->
        expect(@modelProps.entities).to.eql ['b']

    it 'has entityDic collecting all entities', ->

        expect(Object.keys @modelProps.entityDic).to.eql ['b']


    describe 'isEntity', ->

        it 'returns whether the prop is entity', ->
            assert @modelProps.isEntity('b')
            assert @modelProps.isEntity('c') is false
            assert @modelProps.isEntity('date') is false
            assert @modelProps.isEntity('xxx') is false
