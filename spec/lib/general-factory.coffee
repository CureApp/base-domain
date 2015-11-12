
{ BaseDict, ValueObject, Entity,
    BaseSyncRepository, BaseAsyncRepository } = Facade = require('../base-domain')
{ GeneralFactory, MemoryResource } = require '../others'

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
                    g: @TYPES.MODEL 'sub'
                    h: @TYPES.MODEL 'sub', optional: true

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
            expect(abc.g).to.be.instanceof Sub
            expect(abc.h).to.be.undefined




    describe 'createDict', ->

        beforeEach ->

            class ADict extends BaseDict
                @itemModelName: 'a'
                @key: (item) -> item.name

            class A extends ValueObject
                @properties:
                    name: @TYPES.STRING

            @facade.addClass 'a-dict', ADict
            @facade.addClass 'a', A


        it 'creates dict from array', ->

            factory = new GeneralFactory('a', @facade)

            dict = factory.createDict('a-dict', [ { name: 'shin' } ])

            expect(dict).to.be.instanceof @facade.getModel 'a-dict'
            expect(dict).to.have.length 1
            expect(dict.items.shin).to.be.instanceof @facade.getModel 'a'


        describe 'with dict of entities', ->

            beforeEach ->

                class BDict extends BaseDict
                    @itemModelName: 'b'

                class B extends Entity
                    @properties:
                        name: @TYPES.STRING

                @facade.addClass 'b', B
                @facade.addClass 'b-dict', BDict


            it 'creates dict from array(string), as ids. Automatically loaded with SyncRepository', ->

                class BRepository extends BaseSyncRepository
                    @modelName: 'b'
                    client: new MemoryResource
                @facade.addClass 'b-repository', BRepository
                @facade.createRepository('b').save(id: '123', name: 'satake')
                @facade.createRepository('b').save(id: '456', name: 'shin')

                factory = new GeneralFactory('b', @facade)

                dict = factory.createDict('b-dict', [ '123', '456' ])

                expect(dict.ids).to.have.length 2
                expect(dict).to.have.length 2
                expect(dict.items['123']).to.be.instanceof @facade.getModel 'b'


            it 'creates dict from array(string), as ids. Not loaded with AsyncRepository', (done) ->

                class BRepository extends BaseAsyncRepository
                    @modelName: 'b'
                    client: new MemoryResource
                @facade.addClass 'b-repository', BRepository

                Promise.all([
                    @facade.createRepository('b').save(id: '123', name: 'satake')
                    @facade.createRepository('b').save(id: '456', name: 'shin')

                ]).then =>

                    factory = new GeneralFactory('b', @facade)

                    dict = factory.createDict('b-dict', [ '123', '456' ])

                    expect(dict).to.have.length 2
                    expect(dict.ids).to.have.length 2
                    expect(dict.itemLength).to.equal 0
                    done()

                .catch done


            it 'creates dict from array(string), as ids. Loaded with AsyncRepository with async option', (done) ->

                class BRepository extends BaseAsyncRepository
                    @modelName: 'b'
                    client: new MemoryResource
                @facade.addClass 'b-repository', BRepository

                Promise.all([
                    @facade.createRepository('b').save(id: '123', name: 'satake')
                    @facade.createRepository('b').save(id: '456', name: 'shin')

                ]).then =>

                    factory = new GeneralFactory('b', @facade)

                    dict = factory.createDict('b-dict', [ '123', '456' ], include: async: true)

                    expect(dict.ids).to.have.length 2
                    expect(dict).to.have.length 2
                    expect(dict.itemLength).to.equal 0

                    setTimeout =>
                        expect(dict).to.have.length 2
                        expect(dict.itemLength).to.equal 2
                        expect(dict.items['123']).to.be.instanceof @facade.getModel 'b'
                        done()
                    , 0

                .catch done
