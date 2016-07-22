
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
            assert GeneralFactory.create('abc', @facade) instanceof GeneralFactory



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
                    i: @TYPES.ENUM ['Jazz', 'Funk', 'Fusion', 'Soul', 'Bossa Nova'], 'Bossa Nova'

            class Sub extends Facade.ValueObject
                @properties:
                    name: @TYPES.STRING 'shampiness'
                    type: @TYPES.STRING 'xyz'

            @facade.addClass('abc', Abc)
            @facade.addClass('sub', Sub)

            abc = GeneralFactory.createModel('abc', undefined, null, @facade)

            assert abc.a is 'a'
            assert abc.b is true
            assert.deepEqual abc.c, [1, 2, 3]
            assert.deepEqual abc.c, Abc.properties.c.default
            assert abc.c isnt Abc.properties.c.default
            assert.deepEqual abc.d, @facade.createModel 'sub', name: 'shinout', type: 'xyz'
            assert abc.e is undefined
            assert abc.f instanceof Date
            assert abc.g instanceof Sub
            assert abc.h is undefined
            assert abc.i is 4


        it 'set subId to undefined when submodel does not exist', ->

            class Abc extends Facade.ValueObject
                @properties:
                    sub: @TYPES.MODEL 'sub'

            class Sub extends Facade.Entity
                @properties:
                    name: @TYPES.STRING

            @facade.addClass('abc', Abc)
            @facade.addClass('sub', Sub)

            abc = GeneralFactory.createModel('abc', undefined, null, @facade)

            assert abc.sub is undefined
            assert abc.subId is undefined


        it 'set subId to null when submodel does not contain id', ->

            class Abc extends Facade.ValueObject
                @properties:
                    sub: @TYPES.MODEL 'sub'

            class Sub extends Facade.Entity
                @properties:
                    name: @TYPES.STRING

            @facade.addClass('abc', Abc)
            @facade.addClass('sub', Sub)

            abc = GeneralFactory.createModel('abc', { sub: {name: 'foo'} }, null, @facade)

            assert abc.sub.id is null
            assert abc.subId is null


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

            assert dict instanceof @facade.getModel 'a-dict'
            assert dict.length is 1
            assert dict.items.shin instanceof @facade.getModel 'a'


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

                assert dict.ids.length is 2
                assert dict.length is 2
                assert dict.items['123'] instanceof @facade.getModel 'b'


            it 'creates dict from array(string), as ids. Not loaded with AsyncRepository', ->

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

                    assert dict.length is 2
                    assert dict.ids.length is 2
                    assert dict.itemLength is 0


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

                    assert dict.ids.length is 2
                    assert dict.length is 2
                    assert dict.itemLength is 0

                    setTimeout =>
                        assert dict.length is 2
                        assert dict.itemLength is 2
                        assert dict.items['123'] instanceof @facade.getModel 'b'
                        done()
                    , 0


            it 'creates dict from array(string), as ids. Loaded with AsyncRepository with async option, even when it\'s immutable', (done) ->

                class ImmutableBDict extends BaseDict
                    @isImmutable: true
                    @itemModelName: 'b'

                class BRepository extends BaseAsyncRepository
                    @modelName: 'b'
                    client: new MemoryResource

                @facade.addClass 'b-repository', BRepository
                @facade.addClass 'immutable-b-dict', ImmutableBDict

                Promise.all([
                    @facade.createRepository('b').save(id: '123', name: 'satake')
                    @facade.createRepository('b').save(id: '456', name: 'shin')

                ]).then =>

                    factory = new GeneralFactory('b', @facade)

                    dict = factory.createDict('immutable-b-dict', [ '123', '456' ], include: async: true)

                    assert dict.ids.length is 2
                    assert dict.length is 2
                    assert dict.itemLength is 0
                    assert Object.isFrozen(dict) is false

                    setTimeout =>
                        assert Object.isFrozen(dict) is true
                        assert Object.isFrozen(dict.items) is true
                        assert dict.length is 2
                        assert dict.itemLength is 2
                        assert dict.items['123'] instanceof @facade.getModel 'b'
                        done()
                    , 0
