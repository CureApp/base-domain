
facade = require('../create-facade').create()
Facade = facade.constructor

BaseList = facade.constructor.BaseList

hobbies = null


describe 'BaseList', ->

    before ->
        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.BaseModel
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


    it '"loaded", "listeners", "dic" and "itemFactory" are hidden properties whereas items is explicit', ->

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
        expect(explicitKeys).not.to.contain 'dic'



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

    describe 'has', ->

        beforeEach ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            @hobbyFactory = facade.createFactory('hobby', true)

            hobbies = (for name, i in ['cycling', 'jogging', 'keyboard']
                @hobbyFactory.createFromObject id: name, name: name
            )

            @hobbyList = new HobbyList(items: hobbies)

        it 'checks if the list has item by key or not', ->

            expect(@hobbyList.has('cycling')).to.be.true
            expect(@hobbyList.has('jogging')).to.be.true
            expect(@hobbyList.has('keyboard')).to.be.true
            expect(@hobbyList.has('shogi')).to.be.false


        it 'reflects state of items when pushed', ->
            newHobbies = (for name, i in ['shogi', 'driving']
                @hobbyFactory.createFromObject id: name, name: name
            )
            @hobbyList.items.push newHobbies[0], newHobbies[1]

            expect(@hobbyList.has('shogi')).to.be.true
            expect(@hobbyList.has('driving')).to.be.true
            expect(@hobbyList.has('jogging')).to.be.true

        it 'reflects state of items when popped', ->
            @hobbyList.items.pop()
            expect(@hobbyList.has('cycling')).to.be.true
            expect(@hobbyList.has('jogging')).to.be.true
            expect(@hobbyList.has('keyboard')).to.be.false


        it 'reflects state of items when unshifted', ->
            newHobbies = (for name, i in ['cooking', 'hiking']
                @hobbyFactory.createFromObject id: name, name: name
            )
            @hobbyList.items.unshift newHobbies[0], newHobbies[1]

            expect(@hobbyList.has('cooking')).to.be.true
            expect(@hobbyList.has('hiking')).to.be.true
            expect(@hobbyList.has('keyboard')).to.be.true


        it 'reflects state of items when shifted', ->

            @hobbyList.items.shift()
            expect(@hobbyList.has('cycling')).to.be.false
            expect(@hobbyList.has('jogging')).to.be.true
            expect(@hobbyList.has('keyboard')).to.be.true


        it 'reflects state of items when spliced', ->

            newHobbies = (for name, i in ['baseball', 'soccer']
                @hobbyFactory.createFromObject id: name, name: name
            )

            @hobbyList.items.splice(1, 2, newHobbies[0], newHobbies[1])

            expect(@hobbyList.has('cycling')).to.be.true
            expect(@hobbyList.has('jogging')).to.be.false
            expect(@hobbyList.has('keyboard')).to.be.false
            expect(@hobbyList.has('baseball')).to.be.true
            expect(@hobbyList.has('soccer')).to.be.true


    describe 'getByKey', ->

        beforeEach ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            @hobbyFactory = facade.createFactory('hobby', true)

            hobbies = (for name, i in ['cycling', 'jogging', 'keyboard']
                @hobbyFactory.createFromObject id: name, name: name
            )

            @hobbyList = new HobbyList(items: hobbies)

        it 'returns item by key', ->
            expect(@hobbyList.getByKey('cycling')).to.have.property 'id', 'cycling'
            expect(@hobbyList.getByKey('cycling')).to.have.property 'name', 'cycling'


        it 'follows change of property in item', ->
            @hobbyList.items[0].hoge = true
            expect(@hobbyList.getByKey('cycling')).to.have.property 'hoge', true
            expect(@hobbyList.getByKey('cycling')).to.have.property 'name', 'cycling'
