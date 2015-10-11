
facade = require('../create-facade').create()
Facade = facade.constructor

{ Ids, BaseDict } = facade.constructor

hobbies = null


describe 'BaseDict', ->

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

        class HobbyDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyDict = new HobbyDict(items: hobbies)

        explicitKeys = Object.keys(hobbyDict)

        expect(explicitKeys).to.have.length 1
        expect(explicitKeys).to.contain 'items'
        expect(explicitKeys).not.to.contain 'listeners'
        expect(explicitKeys).not.to.contain 'loaded'
        expect(explicitKeys).not.to.contain 'itemFactory'



    it 'itemFactory is hidden properties, created once referred', ->

        class HobbyDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyDict = new HobbyDict(items: hobbies)

        itemFactory = hobbyDict.itemFactory

        expect(itemFactory).to.be.instanceof Facade.BaseFactory
        expect(itemFactory).to.equal hobbyDict.itemFactory


    it 'can contain custom properties', ->

        class HobbyDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'
            @properties:
                annualCost: @TYPES.NUMBER

        hobbyDict = new HobbyDict(items: hobbies, annualCost: 2000)

        expect(hobbyDict).to.have.property 'annualCost', 2000

        explicitKeys = Object.keys(hobbyDict)
        expect(explicitKeys).to.contain 'annualCost'

    it 'throws error if itemModelName is not set', ->
        class HobbyDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade

        expect(-> new HobbyDict()).to.throw Facade.DomainError



    describe '@keys', ->

        it 'originally returns item.id', ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            dict = new HobbyDict().setItems(hobbies)

            expect(dict.ids).to.eql new Ids [1,2,3]


    describe 'ids', ->

        class HobbyDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        class NonEntityDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'non-entity'

        it 'get array when the item is Entity', ->
            hobbyDict = new HobbyDict()
            expect(hobbyDict.ids).to.be.instanceof Array
            expect(hobbyDict.ids).to.be.instanceof Ids

        it 'get null when the item is not Entity', ->
            nonEntityDict = new NonEntityDict()
            expect(nonEntityDict.ids).to.be.null

        it 'get array of ids when the item is Entity', ->

            hobbyDict = new HobbyDict(items: hobbies)
            expect(hobbyDict.ids).to.deep.equal new Ids [1, 2, 3]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: hobbies)

            expect(hobbyDict).to.have.length 3

            arr = hobbyDict.toArray()
            expect(arr).to.have.length 3

            for hobby in arr
                expect(hobbies).to.include hobby


    describe "on('loaded')", ->

        it 'loaded after loaded when ids is given in constructor', (done) ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            hobbyDict = new HobbyDict(ids: ['dummy'])
            expect(hobbyDict.loaded).to.be.false
            expect(hobbyDict.items).not.to.have.property 'dummy'
            expect(hobbyDict).to.have.length 0
            expect(hobbyDict.ids).to.have.length 0

            hobbyDict.on 'loaded', ->
                expect(hobbyDict.loaded).to.be.true
                expect(hobbyDict.items).to.have.property 'dummy'
                done()

        it 'executed after event registered when array is given in constructor', (done) ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: hobbies)

            hobbyDict.on 'loaded', ->
                expect(hobbyDict.loaded).to.be.true
                expect(hobbyDict.items).to.have.property 1
                expect(hobbyDict.items).to.have.property 2
                expect(hobbyDict.items).to.have.property 3
                done()


    describe 'toPlainObject', ->

        it 'returns object with ids when item is entity', ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: hobbies)
            plain = hobbyDict.toPlainObject()

            expect(plain).to.have.property 'ids'
            expect(plain).not.to.have.property 'items'


        it 'returns object with items when item is non-entity', ->

            class NonEntityDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'non-entity'

            nonEntityFactory = facade.createFactory('non-entity', true)
            nonEntities = (for name, i in ['keyboard', 'jogging', 'cycling']
                nonEntityFactory.createFromObject id: 3 - i, name: name
            )

            nonEntityDict = new NonEntityDict(items: nonEntities)
            plain = nonEntityDict.toPlainObject()

            expect(plain).not.to.have.property 'ids'
            expect(plain).to.have.property 'items'
            expect(plain.items).to.be.instanceof Array
            expect(plain.items).to.have.length 3


        it 'returns object with custom properties', ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyDict = new HobbyDict(items: hobbies, annualCost: 2000)

            expect(hobbyDict.toPlainObject()).to.have.property 'ids'
            expect(hobbyDict.toPlainObject()).to.have.property 'annualCost'


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

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            HobbyRepository = facade.getRepository 'hobby'
            HobbyRepository.load().then ->

                dict = new HobbyDict()

                dict.setIds(['dummy'])

                expect(dict.loaded).to.be.true
                expect(dict.items).to.have.property 'dummy'

                done()

            .catch done


        it 'loads data by ids asynchronously from non-MasterRepository', (done) ->

            class CommodityDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'commodity'

            dict = new CommodityDict()

            dict.setIds([2, 3])

            expect(dict.loaded).to.be.false
            expect(dict.items).to.eql {}

            dict.on 'loaded', ->

                expect(dict.loaded).to.be.true
                expect(dict.items).not.to.have.property 1
                expect(dict.items).to.have.property 2
                expect(dict.items).to.have.property 3

                done()

    describe 'has', ->
        before ->
            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: hobbies)

        it 'returns true when item exists', ->
            expect(@hobbyDict.has('keyboard')).to.be.true

        it 'returns false when item does not exist', ->
            expect(@hobbyDict.has('sailing')).to.be.false


    describe 'contains', ->

        before ->
            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: hobbies)

        it 'returns true when item exists', ->
            expect(@hobbyDict.contains(hobbies[0])).to.be.true

        it 'returns false when item does not exist', ->
            newHobby = facade.createFactory('hobby').createFromObject id: 4, name: 'xxx'
            expect(@hobbyDict.has(newHobby)).to.be.false

        it 'returns false when item with same key exists but these two are different', ->
            newHobby = facade.createFactory('hobby').createFromObject id: 4, name: 'keyboard'
            expect(@hobbyDict.has(newHobby)).to.be.false


    describe 'get', ->

        before ->
            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: hobbies)

        it 'returns submodel when key exists', ->
            expect(@hobbyDict.get('keyboard')).to.be.instanceof facade.getModel('hobby')

        it 'returns undefined when key does not exist', ->
            expect(@hobbyDict.get('xxx')).to.be.undefined


    describe 'add', ->

        before ->
            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: hobbies)

        it 'add item model', ->
            newHobby = facade.createFactory('hobby').createFromObject id: 4, name: 'xxx'
            @hobbyDict.add(newHobby)
            expect(@hobbyDict.items.xxx).to.be.instanceof facade.getModel 'hobby'


        it 'does not add non-item model', ->
            newHobby = id: 4, name: 'yyyy'
            @hobbyDict.add(newHobby)
            expect(@hobbyDict.items.yyyy).not.to.exist


    describe 'remove', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: hobbies)

        it 'removes by key', ->
            @hobbyDict.remove('keyboard')
            expect(@hobbyDict.items.keyboard).not.to.exist

        it 'removes by item', ->
            @hobbyDict.remove(hobbies[0])
            expect(@hobbyDict.items.keyboard).not.to.exist


        it 'do nothing if no key exists', ->
            @hobbyDict.remove('xxx')



    describe 'clear', ->

        it 'removes all items', ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: hobbies)

            expect(hobbyDict).to.have.length 3
            expect(hobbyDict.ids).to.have.length 3

            hobbyDict.clear()

            expect(hobbyDict).to.have.length 0
            expect(hobbyDict.ids).to.have.length 0

            hobbyDict.clear()

            expect(hobbyDict).to.have.length 0
            expect(hobbyDict.ids).to.have.length 0



    describe 'toggle', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: hobbies)
            @factory = @hobbyDict.itemFactory

        it 'adds if not exist', ->

            h = @factory.createFromObject
                name        : 'skiing'

            @hobbyDict.toggle h

            expect(@hobbyDict.has 'skiing').to.be.true


        it 'removes if exists', ->

            h = @factory.createFromObject
                name        : 'skiing'

            @hobbyDict.add h
            @hobbyDict.toggle h
            expect(@hobbyDict.has 'skiing').to.be.false


