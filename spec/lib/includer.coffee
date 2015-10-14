
facade = require('../create-facade').create()
Facade = facade.constructor
{ ValueObject, Entity, BaseAsyncRepository, BaseSyncRepository } = facade.constructor
MemoryResource = require '../../src/memory-resource'


Includer = require '../../src/lib/includer'


describe 'Includer', ->

    before (done) ->

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

        facade.addClass('a', A)
        facade.addClass('b', B)
        facade.addClass('c', C)
        facade.addClass('b-repository', BRepository)
        facade.addClass('c-repository', CRepository)

        bRepo = facade.createRepository('b')
        cRepo = facade.createRepository('c')

        cRepo.save(id: 'xxx', name: 'shin')
        cRepo.save(id: 'yyy', name: 'satake')

        Promise.all([
            bRepo.save(id: 'xxx', name: 'shin', cId: 'xxx')
            bRepo.save(id: 'yyy', name: 'satake', cId: 'yyy')
        ]).then -> done()


    beforeEach ->

        @a = facade.createFactory('a').createFromObject { bId: 'xxx', cId: 'xxx' }, include: null

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

            class Main extends Facade.BaseModel
                @properties:
                    name: @TYPES.STRING
                    sub: @TYPES.MODEL 'sub-item', 'subId'

            class SubItem extends Facade.Entity
                @properties:
                    name: @TYPES.STRING

            class SubItemRepository extends Facade.BaseRepository
                @modelName: 'sub-item'
                get: (id) ->
                    item = @getFacade().createFactory('sub-item', true).createFromObject {id: id, name: 'mock'}
                    return Promise.resolve item


            @f = Facade.createInstance()
            @f.addClass('main', Main)
            @f.addClass('sub-item', SubItem)
            @f.addClass('sub-item-repository', SubItemRepository)

        it 'includes subEntities', (done) ->

            main = @f.createFactory('main', true).createFromObject
                name: 'xxx'
                subId: 'abc'

            main.include().then =>
                expect(main.sub).to.be.instanceof @f.getModel 'sub-item'
                done()

            .catch done




