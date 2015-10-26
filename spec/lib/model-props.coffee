
Facade = require '../base-domain'

{ Entity, ValueObject, BaseList } = Facade

ModelProps = require '../../src/lib/model-props'

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

        @modelProps = new ModelProps('a', A.properties, @facade)


    it 'has dates collecting prop of DATE, CREATED_AT and UPDATED_AT', ->
        expect(@modelProps.dates).to.eql ['date', 'createdAt', 'createdAt2', 'updatedAt', 'updatedAt2']


    it 'has createdAt whose value is CREATED_AT at last column', ->
        expect(@modelProps.createdAt).to.equal 'createdAt2'

    it 'has updatedAt whose value is UPDATED_AT at last column', ->
        expect(@modelProps.updatedAt).to.equal 'updatedAt2'

    it 'has models collecting MODELs (ValueObject and Entities, Collections)', ->
        expect(@modelProps.models).to.eql ['b', 'c', 'bs', 'cs']

    it 'has entities collecting MODELs who extend Entity', ->
        expect(@modelProps.entities).to.eql ['b']

    it 'has nonEntities collecting MODELs who don\'t extend Entity', ->
        expect(@modelProps.nonEntities).to.eql ['c', 'bs', 'cs']


    it 'has dic collecting all properties', ->

        expect(Object.keys @modelProps.dic).to.eql Object.keys @prop

    it 'has entityDic collecting all entities', ->

        expect(Object.keys @modelProps.entityDic).to.eql ['b']

    it 'has modelDic collecting all models', ->

        expect(Object.keys @modelProps.modelDic).to.eql ['b', 'c', 'bs', 'cs']

    describe 'isEntity', ->

        it 'returns whether the prop is entity', ->
            expect(@modelProps.isEntity('b')).to.be.true
            expect(@modelProps.isEntity('c')).to.be.false
            expect(@modelProps.isEntity('date')).to.be.false
            expect(@modelProps.isEntity('xxx')).to.be.false

    describe 'isModelProp', ->
        it 'returns whether the prop is model', ->
            expect(@modelProps.isModel('b')).to.be.true
            expect(@modelProps.isModel('c')).to.be.true
            expect(@modelProps.isModel('date')).to.be.false
            expect(@modelProps.isModel('xxx')).to.be.false


    describe 'getTypeInfo', ->
        it 'returns typeInfo of the prop', ->
            expect(@modelProps.getTypeInfo('b')).to.exist
            expect(@modelProps.getTypeInfo('c')).to.exist
            expect(@modelProps.getTypeInfo('cs')).to.exist
            expect(@modelProps.getTypeInfo('num')).to.exist
            expect(@modelProps.getTypeInfo('xxxx')).not.to.exist
