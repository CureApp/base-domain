
Facade = require('../base-domain')
{ GeneralFactory } = require '../others'

describe 'GeneralFactory', ->

    beforeEach ->
        @facade = require('../create-facade').create()

    describe '@create', ->

        it 'returns general factory when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            @facade.addClass('abc', Abc)
            expect(GeneralFactory.create('abc', @facade)).to.be.instanceof GeneralFactory



    describe '@createModel', ->

        it 'adds default values to undefined values', ->

            class Abc extends Facade.ValueObject
                @properties:
                    a: @TYPES.STRING 'a'
                    b: @TYPES.BOOLEAN true
                    c: @TYPES.ARRAY [1, 2, 3]
                    d: @TYPES.MODEL('sub', default: name: 'shinout')
                    e: @TYPES.STRING
                    f: @TYPES.DATE -> new Date()

            class Sub extends Facade.ValueObject
                @properties:
                    name: @TYPES.STRING 'shampiness'
                    type: @TYPES.STRING 'xyz'

            @facade.addClass('abc', Abc)
            @facade.addClass('sub', Sub)

            abc = GeneralFactory.createModel('abc', undefined, null, @facade)

            expect(abc.a).to.equal 'a'
            expect(abc.b).to.be.true
            expect(abc.c).to.eql [1, 2, 3]
            expect(abc.c).to.eql Abc.properties.c.default
            expect(abc.c).to.not.equal Abc.properties.c.default
            expect(abc.d).to.eql @facade.createModel 'sub', name: 'shinout', type: 'xyz'
            expect(abc.e).to.be.undefined
            expect(abc.f).to.be.instanceof Date


