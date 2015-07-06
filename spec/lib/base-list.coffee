
facade = require('../create-facade').create()
Facade = facade.constructor

BaseList = facade.constructor.BaseList

hobbies = null


describe 'BaseList', ->

    before ->
        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.ValueObject
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends Facade.MasterRepository
            @modelName: 'hobby'



        facade.addClass 'hobby', Hobby
        facade.addClass 'non-entity', NonEntity
        facade.addClass('hobby-repository', HobbyRepository)

        hobbyFactory = facade.createFactory('hobby', true)

        hobbies = (for name, i in ['keyboard', 'jogging', 'cycling']
            hobbyFactory.createFromObject id: 3 - i, name: name
        )


    it '"loaded", "listeners" and "itemFactory" are hidden properties whereas items is explicit', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyList = new HobbyList(items: hobbies)

        explicitKeys = Object.keys(hobbyList)

        expect(explicitKeys).to.have.length 1
        expect(explicitKeys).to.contain 'items'
        expect(explicitKeys).not.to.contain 'listeners'
        expect(explicitKeys).not.to.contain 'loaded'
        expect(explicitKeys).not.to.contain 'itemFactory'



    it 'itemFactory is hidden properties, created once referred', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyList = new HobbyList(items: hobbies)

        itemFactory = hobbyList.itemFactory

        expect(itemFactory).to.be.instanceof Facade.BaseFactory
        expect(itemFactory).to.equal hobbyList.itemFactory



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

        it 'sorts model by id', ->

            hobbyIds = (hobby.id for hobby in hobbies)
            expect(hobbyIds).to.deep.equal [3, 2, 1]

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            hobbyIdsSorted = (hobby.id for hobby in hobbyList.items)

            expect(hobbyIdsSorted).to.deep.equal [1, 2, 3]


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

        it 'get null when the item is not Entity', ->
            nonEntityList = new NonEntityList()
            expect(nonEntityList.ids).to.be.null

        it 'get array of ids when the item is Entity', ->

            hobbyList = new HobbyList(items: hobbies)
            expect(hobbyList.ids).to.deep.equal [1, 2, 3]



    describe 'first', ->

        it 'returns first value of the items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList.first()).to.equal hobbies[2]



    describe 'last', ->

        it 'returns last value of the items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList.last()).to.equal hobbies[0]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: hobbies)

            expect(hobbyList.toArray()).to.deep.equal hobbyList.items


    describe "on('loaded')", ->

        it 'loaded after loaded when ids is given in constructor', (done) ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            hobbyList = new HobbyList(ids: ['dummy'])
            expect(hobbyList.loaded).to.be.false
            expect(hobbyList.items).to.have.length 0
            expect(hobbyList.ids).to.have.length 0

            hobbyList.on 'loaded', ->
                expect(hobbyList.loaded).to.be.true
                expect(hobbyList.items).to.have.length 1
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


        it 'can load data by ids synchronously from MasterRepository', (done) ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            HobbyRepository = facade.getRepository 'hobby'
            HobbyRepository.load().then ->

                list = new HobbyList()

                list.setIds(['dummy'])

                expect(list.loaded).to.be.true
                expect(list.items).to.have.length.above 0

                done()

            .catch done


        it 'loads data by ids asynchronously from non-MasterRepository', (done) ->

            class CommodityList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'commodity'

            list = new CommodityList()

            list.setIds([2, 3])

            expect(list.loaded).to.be.false
            expect(list.items).to.have.length 0

            list.on 'loaded', ->

                expect(list.loaded).to.be.true
                expect(list.items).to.have.length 2

                done()

