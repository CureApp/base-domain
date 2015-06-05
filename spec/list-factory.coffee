
facade = require('./create-facade').create()
Facade = facade.constructor

describe 'ListFactory', ->

    before ->
        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.BaseModel
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends Facade.MasterRepository
            @modelName: 'hobby'


        facade.addClass('hobby', Hobby)
        facade.addClass('non-entity', NonEntity)
        facade.addClass('hobby-repository', HobbyRepository)


    describe 'createEmpty', ->

        hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
        hobbyList = hobbyListFactory.createEmpty()

        it 'creates list', ->

            expect(hobbyList).to.be.instanceof Facade.BaseList
            expect(hobbyList.items).to.be.instanceof Array
            expect(hobbyList.loaded).to.be.true

        it 'creates empty list', ->
            expect(hobbyList.items).to.have.length 0
            expect(hobbyList.ids).to.have.length 0


    describe 'createFromNonArrayObject', ->

        it 'regards arg as list object when arg has items', ->

            obj = items: [ {name: 'keyboard'}, {name: 'programming'} ]

            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromObject(obj)
            expect(list.items).to.have.length 2


        it 'regards arg as list object when arg has ids', (done) ->

            obj = ids: ['dummy']

            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromObject(obj)

            list.on 'loaded', ->
                expect(list.items).to.have.length.above 0
                done()


        it 'regards arg as one (pre)model when arg has neither ids nor items', ->

            obj = name: 'climbing'

            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromObject(obj)

            expect(list.items).to.have.length 1
            expect(list.first().name).to.equal 'climbing'



    describe 'createFromArray', ->

        it 'throws error when array of non-object given to non-entity-list factory', ->

            hobbyListFactory = facade.createListFactory('ne-list', 'non-entity')
            expect(-> hobbyListFactory.createFromArray(['abc', 'def'])).to.throw Error

        it 'regards string array as id list', (done) ->
            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromArray(['dummy'])

            list.on 'loaded', ->
                expect(list.items).to.have.length.above 0
                done()

        it 'regards object array as pre-model list', (done) ->

            data = [ {id: 3, name: 'keyboard'}, {id: 2, name: 'sailing'} ]

            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromArray(data)

            list.on 'loaded', ->
                Hobby = facade.getModel 'hobby'
                expect(list.items).to.have.length 2
                expect(list.items[0]).to.be.instanceof Hobby
                expect(list.ids).to.eql [2,3]
                done()



    describe 'createFromIds', ->

        class Commodity extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class CommodityRepository extends Facade.BaseRepository
            @modelName: 'hobby'

            query: ->
                items = [{id: 1, name: 'pencil'}, {id: 2, name: 'toothbrush'}, {id: 3, name: 'potatochips'}]
                Promise.resolve (@factory.createFromObject(item) for item in items)

        facade.addClass('commodity', Commodity)
        facade.addClass('commodity-repository', CommodityRepository)


        it 'can load data by ids synchronously from MasterRepository', (done) ->

            HobbyRepository = facade.getRepository 'hobby'
            HobbyRepository.load().then ->

                hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
                list = hobbyListFactory.createFromIds(['dummy'])

                expect(list.loaded).to.be.true
                expect(list.items).to.have.length.above 0

                done()

        it 'loads data by ids asynchronously from non-MasterRepository', (done) ->

            commodityListFactory = facade.createListFactory('commodity-list', 'commodity')
            list = commodityListFactory.createFromIds([1, 2, 3])

            expect(list.loaded).to.be.false
            expect(list.items).to.have.length 0

            list.on 'loaded', ->
                expect(list.loaded).to.be.true
                expect(list.items).to.have.length 3

                done()


