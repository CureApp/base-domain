
Facade = require '../base-domain'

{ ValueObject, Entity, BaseAsyncRepository, BaseSyncRepository } = Facade

MemoryResource = require '../../src/memory-resource'
Includer = require '../../src/lib/includer'


describe 'Includer', ->

    before (done) ->

        @facade = require('../create-facade').create()

        class A extends ValueObject
            @properties:
                b: @TYPES.MODEL 'b'
                c: @TYPES.MODEL 'c'

        class B extends Entity
            @properties:
                c: @TYPES.MODEL 'c'
                name: @TYPES.STRING

        class BRepository extends BaseAsyncRepository
            client: new MemoryResource()

        class CRepository extends BaseSyncRepository
            client: new MemoryResource()

        class C extends Entity
            @properties:
                name: @TYPES.STRING

        @facade.addClass(A)
        @facade.addClass(B)
        @facade.addClass(C)
        @facade.addClass(BRepository)
        @facade.addClass(CRepository)

        bRepo = @facade.createRepository('b')
        cRepo = @facade.createRepository('c')

        cRepo.save(id: 'xxx', name: 'shin')
        cRepo.save(id: 'yyy', name: 'satake')

        Promise.all([
            bRepo.save(id: 'xxx', name: 'shin', cId: 'xxx')
            bRepo.save(id: 'yyy', name: 'satake', cId: 'yyy')
        ]).then -> done()


    beforeEach ->

        @a = @facade.createModel('a', { bId: 'xxx', cId: 'xxx' }, include: null)

    describe 'constructor', ->

        it 'receives modelPool object at 2nd argument', ->

            modelPool = {}

            includer = new Includer(@a, modelPool)

            expect(includer.modelPool).to.equal modelPool


    describe 'cache', ->

        it 'caches model by its model name', ->

            includer = new Includer(@a)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.modelPool.hoge.abc).to.deep.equal({ id: 'abc', mock: true })



    describe 'cached', ->

        it 'returns cached model by model name and id', ->

            includer = new Includer(@a)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.cached('hoge', 'abc')).to.deep.equal({ id: 'abc', mock: true })


        it 'returns undefined when unknown model name is given', ->

            includer = new Includer(@a)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.cached('fuga', 'abc')).to.be.undefined

        it 'returns undefined when unknown id is given', ->

            includer = new Includer(@a)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.cached('hoge', '123')).to.be.undefined


    describe 'include', ->

        before ->

            class Main extends ValueObject
                @properties:
                    name: @TYPES.STRING
                    sub: @TYPES.MODEL 'sub-item', 'subId'

            class SubItem extends Entity
                @properties:
                    name: @TYPES.STRING

            class SubItemRepository extends BaseAsyncRepository
                @modelName: 'sub-item'
                get: (id) ->
                    item = @getFacade().createModel('sub-item', {id: id, name: 'mock'})
                    return Promise.resolve item


            @f = require('../create-facade').create()
            @f.addClass('main', Main)
            @f.addClass('sub-item', SubItem)
            @f.addClass('sub-item-repository', SubItemRepository)

        it 'includes subEntities', (done) ->

            main = @f.createModel 'main',
                name: 'xxx'
                subId: 'abc'

            main.include().then =>
                expect(main.sub).to.be.instanceof @f.getModel 'sub-item'
                done()

            .catch done




