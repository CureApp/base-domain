
facade = require('../create-facade').create()
Facade = facade.constructor

PropInfo = require '../../src/lib/prop-info'

describe 'PropInfo', ->

    before ->
        class A extends Facade.Entity
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
                bs         : @TYPES.MODEL_LIST 'b'
                cs         : @TYPES.MODEL_LIST 'c'

        facade.addClass('a', A)
        facade.addClass('b', class B extends Facade.Entity)
        facade.addClass('c', class C extends Facade.BaseModel)

        @prop = facade.getModel('a').properties
        @facade = facade

        @propInfo = new PropInfo(A.properties, facade)


    it 'has dateProps collecting prop of DATE, CREATED_AT and UPDATED_AT', ->
        expect(@propInfo.dateProps).to.eql ['date', 'createdAt', 'createdAt2', 'updatedAt', 'updatedAt2']


    it 'has createdAt whose value is CREATED_AT at last column', ->
        expect(@propInfo.createdAt).to.equal 'createdAt2'

    it 'has updatedAt whose value is UPDATED_AT at last column', ->
        expect(@propInfo.updatedAt).to.equal 'updatedAt2'

    it 'has modelProps collecting MODELs (BaseModels and Entities)', ->
        expect(@propInfo.modelProps).to.eql ['b', 'c']

    it 'has listProps collecting MODEL_LISTs', ->
        expect(@propInfo.listProps).to.eql ['bs', 'cs']

    it 'has entityProps collecting MODELs who extend Entity', ->
        expect(@propInfo.entityProps).to.eql ['b']

    it 'has nonEntityProps collecting MODELs who don\'t extend Entity', ->
        expect(@propInfo.nonEntityProps).to.eql ['c']


    it 'has dic collecting all properties', ->

        expect(Object.keys @propInfo.dic).to.eql Object.keys @prop

    it 'has entityDic collecting all entities', ->

        expect(Object.keys @propInfo.entityDic).to.eql ['b']

    it 'has modelDic collecting all models', ->

        expect(Object.keys @propInfo.modelDic).to.eql ['b', 'c']

    describe 'isEntityProp', ->

        it 'returns whether the prop is entity', ->
            expect(@propInfo.isEntityProp('b')).to.be.true
            expect(@propInfo.isEntityProp('c')).to.be.false
            expect(@propInfo.isEntityProp('date')).to.be.false
            expect(@propInfo.isEntityProp('xxx')).to.be.false

    describe 'isModelProp', ->
        it 'returns whether the prop is model', ->
            expect(@propInfo.isModelProp('b')).to.be.true
            expect(@propInfo.isModelProp('c')).to.be.true
            expect(@propInfo.isModelProp('date')).to.be.false
            expect(@propInfo.isModelProp('xxx')).to.be.false


    describe 'getTypeInfo', ->
        it 'returns typeInfo of the prop', ->
            expect(@propInfo.getTypeInfo('b')).to.exist
            expect(@propInfo.getTypeInfo('c')).to.exist
            expect(@propInfo.getTypeInfo('cs')).to.exist
            expect(@propInfo.getTypeInfo('num')).to.exist
            expect(@propInfo.getTypeInfo('xxxx')).not.to.exist
