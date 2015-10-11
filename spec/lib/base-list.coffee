
facade = require('../create-facade').create()
Facade = facade.constructor

{ Ids, BaseList, MemoryResource } = facade.constructor

hobbies = null


describe 'BaseList', ->

    before ->
        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.ValueObject
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends Facade.BaseSyncRepository
            @modelName: 'hobby'
            client: new MemoryResource()

        class Diary extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class DiaryRepository extends Facade.BaseAsyncRepository
            @modelName: 'diary'
            client: new MemoryResource()

        facade.addClass 'hobby', Hobby
        facade.addClass 'non-entity', NonEntity
        facade.addClass 'hobby-repository', HobbyRepository
        facade.addClass 'diary', Diary
        facade.addClass 'diary-repository', DiaryRepository

        hobbyFactory = facade.createFactory('hobby', true)
        hobbyRepo    = facade.createRepository('hobby')

        hobbies = (for name, i in ['keyboard', 'jogging', 'cycling']
            hobby = hobbyFactory.createFromObject id: 3 - i, name: name
            hobbyRepo.save hobby
        )


    it '"loaded" is a hidden property whereas items is explicit', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyList = new HobbyList(items: hobbies)

        explicitKeys = Object.keys(hobbyList)

        expect(explicitKeys).to.have.length 1
        expect(explicitKeys).to.contain 'items'
        expect(explicitKeys).not.to.contain 'loaded'


    it 'can contain custom properties', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'
            @properties:
                annualCost: @TYPES.NUMBER

        hobbyList = new HobbyList(items: hobbies, annualCost: 2000)

        expect(hobbyList).to.have.property 'annualCost', 2000

        explicitKeys = Object.keys(hobbyList)
        expect(explicitKeys).to.contain 'annualCost'


    it 'throws error if itemModelName is not set', ->
        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade

        expect(-> new HobbyList()).to.throw Facade.DomainError



    describe 'constructor', ->

        it 'sorts model when sort function is defined', ->

            hobbyIds = (hobby.id for hobby in hobbies)

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

                sort: (a, b) -> a.id - b.id

            hobbyList = new HobbyList(items: hobbies)

            hobbyIdsSorted = (hobby.id.toString() for hobby in hobbyList.items)

            expect(hobbyIdsSorted).to.deep.equal new Ids([1, 2, 3]).toPlainObject()


    describe 'ids', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        class NonEntityList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'non-entity'

        it 'get array when the item is Entity', ->
            hobbyList = new HobbyList()
            expect(hobbyList.ids).to.be.instanceof Array
            expect(hobbyList.ids).to.be.instanceof Ids

        it 'get null when the item is not Entity', ->
            nonEntityList = new NonEntityList()
            expect(nonEntityList.ids).to.be.null

        it 'get array of ids when the item is Entity', ->

            hobbyList = new HobbyList(items: hobbies)
            expect(hobbyList.ids).to.deep.equal new Ids [3, 2, 1]



    describe 'first', ->

        it 'returns first value of the items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList.first()).to.equal hobbies[0]



    describe 'last', ->

        it 'returns last value of the items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList.last()).to.equal hobbies[2]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList.toArray()).to.deep.equal hobbyList.items


    describe "on('loaded')", ->

        before (done) ->

            facade.createRepository('diary').save(id: 'abc', name: 'xxx').then -> done()


        it 'loaded after loaded when ids is given in constructor', (done) ->

            class DiaryList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'diary'


            diaryList = new DiaryList(ids: ['abc'])
            expect(diaryList.loaded).to.be.false
            expect(diaryList.items).to.have.length 0
            expect(diaryList).to.have.length 0
            expect(diaryList.ids).to.have.length 0

            diaryList.on 'loaded', ->
                expect(diaryList.loaded).to.be.true
                expect(diaryList).to.have.length 1
                expect(diaryList.items).to.have.length 1
                expect(diaryList.ids).to.have.length 1
                expect(diaryList.ids[0].equals 'abc').to.be.true
                done()

        it 'executed after event registered when array is given in constructor', (done) ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            hobbyList.on 'loaded', ->
                expect(hobbyList.loaded).to.be.true
                expect(hobbyList.items).to.have.length 3
                expect(hobbyList).to.have.length 3
                done()


    describe 'toPlainObject', ->

        it 'returns object with ids when item is entity', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)
            plain = hobbyList.toPlainObject()

            expect(plain).to.have.property 'ids'
            expect(plain).not.to.have.property 'items'


        it 'returns object with items when item is non-entity', ->

            class NonEntityList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'non-entity'

            nonEntityFactory = facade.createFactory('non-entity', true)
            nonEntities = (for name, i in ['keyboard', 'jogging', 'cycling']
                nonEntityFactory.createFromObject id: 3 - i, name: name
            )

            nonEntityList = new NonEntityList(items: nonEntities)
            plain = nonEntityList.toPlainObject()

            expect(plain).not.to.have.property 'ids'
            expect(plain).to.have.property 'items'
            expect(plain.items).to.have.length 3


        it 'returns object with custom properties', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyList = new HobbyList(items: hobbies, annualCost: 2000)

            expect(hobbyList.toPlainObject()).to.have.property 'ids'
            expect(hobbyList.toPlainObject()).to.have.property 'annualCost'


    describe 'add', ->

        it 'appends models', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyList = new HobbyList(items: hobbies, annualCost: 2000)
            Hobby = facade.getModel 'hobby'

            hobbyList.add new Hobby(id: 0, name: 'abc'), new Hobby(id: 100, name: 'xyz')

            expect(hobbyList.first()).to.have.property 'name', 'keyboard'
            expect(hobbyList.last()).to.have.property 'name', 'xyz'


    describe 'clear', ->

        it 'clears all models', ->


            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList).to.have.length 3

            hobbyList.clear()

            expect(hobbyList).to.have.length 0
            expect(hobbyList.ids).to.have.length 0

            hobbyList.clear()

            expect(hobbyList).to.have.length 0
            expect(hobbyList.ids).to.have.length 0


    describe 'setIds', ->

        class Commodity extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class CommodityRepository extends Facade.BaseRepository
            @modelName: 'commodity'

            query: (params) ->
                ids = params.where.id.inq
                items = [{id: 1, name: 'pencil'}, {id: 2, name: 'toothbrush'}, {id: 3, name: 'potatochips'}]
                Promise.resolve (@factory.createFromObject(item) for item in items when item.id in ids)

        facade.addClass('commodity', Commodity)
        facade.addClass('commodity-repository', CommodityRepository)


        it 'can load data by ids synchronously from BaseSyncRepository', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            HobbyRepository = facade.getRepository 'hobby'

            list = new HobbyList()

            list.setIds(['1', '3'])

            expect(list.loaded).to.be.true
            expect(list.items).to.have.length 2


        it 'loads data by ids asynchronously from BaseAsyncRepository', (done) ->

            class DiaryList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'diary'

            list = new DiaryList()

            list.setIds(['abc'])

            expect(list.loaded).to.be.false
            expect(list.items).to.have.length 0
            expect(list).to.have.length 0

            list.on 'loaded', ->

                expect(list.loaded).to.be.true
                expect(list.items).to.have.length 1
                expect(list).to.have.length 1

                done()

    describe 'remove', ->

        it 'removes an item by index', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList).to.have.length 3

            hobbyList.remove(1)

            expect(hobbyList).to.have.length 2
            expect(hobbyList.ids).to.have.length 2

            expect(hobbyList.ids).to.eql new Ids [3, 1]

