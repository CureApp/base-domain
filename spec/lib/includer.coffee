
facade = require('../create-facade').create()
Facade = facade.constructor

Includer = require '../../src/lib/includer'


describe 'Includer', ->

    describe 'constructor', ->

        it 'receives modelPool object at 2nd argument', ->

            modelPool = mock: true

            includer = new Includer({}, modelPool) 

            expect(includer.modelPool).to.equal modelPool


    describe 'cache', ->

        it 'caches model by its model name', ->

            model = {}

            includer = new Includer(model)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.modelPool.hoge.abc).to.deep.equal({ id: 'abc', mock: true })



    describe 'cached', ->

        it 'returns cached model by model name and id', ->

            model = {}

            includer = new Includer(model)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.cached('hoge', 'abc')).to.deep.equal({ id: 'abc', mock: true })


        it 'returns undefined when unknown model name is given', ->

            model = {}

            includer = new Includer(model)

            includer.cache('hoge', id: 'abc', mock: true)

            expect(includer.cached('fuga', 'abc')).to.be.undefined

        it 'returns undefined when unknown id is given', ->

            model = {}

            includer = new Includer(model)

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




