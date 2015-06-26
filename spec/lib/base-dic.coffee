
facade = require('../create-facade').create()
Facade = facade.constructor

BaseDic = facade.constructor.BaseDic

hobbies = null


describe 'BaseDic', ->

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


    it '"loaded", "listeners" and "itemFactory" are hidden properties whereas items is explicit', ->

        class HobbyDic extends BaseDic
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyDic = new HobbyDic(items: hobbies)

        explicitKeys = Object.keys(hobbyDic)

        expect(explicitKeys).to.have.length 1
        expect(explicitKeys).to.contain 'items'
        expect(explicitKeys).not.to.contain 'listeners'
        expect(explicitKeys).not.to.contain 'loaded'
        expect(explicitKeys).not.to.contain 'itemFactory'



    it 'itemFactory is hidden properties, created once referred', ->

        class HobbyDic extends BaseDic
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyDic = new HobbyDic(items: hobbies)

        itemFactory = hobbyDic.itemFactory

        expect(itemFactory).to.be.instanceof Facade.BaseFactory
        expect(itemFactory).to.equal hobbyDic.itemFactory


    it 'can contain custom properties', ->

        class HobbyDic extends BaseDic
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'
            @properties:
                annualCost: @TYPES.NUMBER

        hobbyDic = new HobbyDic(items: hobbies, annualCost: 2000)

        expect(hobbyDic).to.have.property 'annualCost', 2000

        explicitKeys = Object.keys(hobbyDic)
        expect(explicitKeys).to.contain 'annualCost'


    describe '@keys', ->

        it 'originally returns item.id', ->

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            dic = new HobbyDic().setItems(hobbies)

            expect(dic.ids).to.eql [1,2,3]


    describe 'ids', ->

        class HobbyDic extends BaseDic
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        class NonEntityDic extends BaseDic
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'non-entity'

        it 'get array when the item is Entity', ->
            hobbyDic = new HobbyDic()
            expect(hobbyDic.ids).to.be.instanceof Array

        it 'get null when the item is not Entity', ->
            nonEntityDic = new NonEntityDic()
            expect(nonEntityDic.ids).to.be.null

        it 'get array of ids when the item is Entity', ->

            hobbyDic = new HobbyDic(items: hobbies)
            expect(hobbyDic.ids).to.deep.equal [1, 2, 3]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDic = new HobbyDic(items: hobbies)

            arr = hobbyDic.toArray()
            expect(arr).to.have.length 3

            for hobby in arr
                expect(hobbies).to.include hobby


    describe "on('loaded')", ->

        it 'loaded after loaded when ids is given in constructor', (done) ->

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            hobbyDic = new HobbyDic(ids: ['dummy'])
            expect(hobbyDic.loaded).to.be.false
            expect(hobbyDic.items).not.to.have.property 'dummy'
            expect(hobbyDic.ids).to.have.length 0

            hobbyDic.on 'loaded', ->
                expect(hobbyDic.loaded).to.be.true
                expect(hobbyDic.items).to.have.property 'dummy'
                done()

        it 'executed after event registered when array is given in constructor', (done) ->

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDic = new HobbyDic(items: hobbies)

            hobbyDic.on 'loaded', ->
                expect(hobbyDic.loaded).to.be.true
                expect(hobbyDic.items).to.have.property 1
                expect(hobbyDic.items).to.have.property 2
                expect(hobbyDic.items).to.have.property 3
                done()


    describe 'toPlainObject', ->

        it 'returns object with ids when item is entity', ->

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyDic = new HobbyDic(items: hobbies)
            plain = hobbyDic.toPlainObject()

            expect(plain).to.have.property 'ids'
            expect(plain).not.to.have.property 'items'


        it 'returns object with items when item is non-entity', ->

            class NonEntityDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'non-entity'

            nonEntityFactory = facade.createFactory('non-entity', true)
            nonEntities = (for name, i in ['keyboard', 'jogging', 'cycling']
                nonEntityFactory.createFromObject id: 3 - i, name: name
            )

            nonEntityDic = new NonEntityDic(items: nonEntities)
            plain = nonEntityDic.toPlainObject()

            expect(plain).not.to.have.property 'ids'
            expect(plain).to.have.property 'items'
            expect(plain.items).to.have.property 1
            expect(plain.items).to.have.property 2
            expect(plain.items).to.have.property 3


        it 'returns object with custom properties', ->

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyDic = new HobbyDic(items: hobbies, annualCost: 2000)

            expect(hobbyDic.toPlainObject()).to.have.property 'ids'
            expect(hobbyDic.toPlainObject()).to.have.property 'annualCost'


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

            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'


            HobbyRepository = facade.getRepository 'hobby'
            HobbyRepository.load().then ->

                dic = new HobbyDic()

                dic.setIds(['dummy'])

                expect(dic.loaded).to.be.true
                expect(dic.items).to.have.property 'dummy'

                done()

            .catch done


        it 'loads data by ids asynchronously from non-MasterRepository', (done) ->

            class CommodityDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'commodity'

            dic = new CommodityDic()

            dic.setIds([2, 3])

            expect(dic.loaded).to.be.false
            expect(dic.items).to.eql {}

            dic.on 'loaded', ->

                expect(dic.loaded).to.be.true
                expect(dic.items).not.to.have.property 1
                expect(dic.items).to.have.property 2
                expect(dic.items).to.have.property 3

                done()

    describe 'has', ->
        before ->
            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDic = new HobbyDic(items: hobbies)

        it 'returns true when item exists', ->
            expect(@hobbyDic.has('keyboard')).to.be.true

        it 'returns false when item does not exist', ->
            expect(@hobbyDic.has('sailing')).to.be.false


    describe 'contains', ->

        before ->
            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDic = new HobbyDic(items: hobbies)

        it 'returns true when item exists', ->
            expect(@hobbyDic.contains(hobbies[0])).to.be.true

        it 'returns false when item does not exist', ->
            newHobby = facade.createFactory('hobby').createFromObject id: 4, name: 'xxx'
            expect(@hobbyDic.has(newHobby)).to.be.false

        it 'returns false when item with same key exists but these two are different', ->
            newHobby = facade.createFactory('hobby').createFromObject id: 4, name: 'keyboard'
            expect(@hobbyDic.has(newHobby)).to.be.false


    describe 'get', ->

        before ->
            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDic = new HobbyDic(items: hobbies)

        it 'returns submodel when key exists', ->
            expect(@hobbyDic.get('keyboard')).to.be.instanceof facade.getModel('hobby')

        it 'returns undefined when key does not exist', ->
            expect(@hobbyDic.get('xxx')).to.be.undefined


    describe 'add', ->

        before ->
            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDic = new HobbyDic(items: hobbies)

        it 'add item model', ->
            newHobby = facade.createFactory('hobby').createFromObject id: 4, name: 'xxx'
            @hobbyDic.add(newHobby)
            expect(@hobbyDic.items.xxx).to.be.instanceof facade.getModel 'hobby'


        it 'does not add non-item model', ->
            newHobby = id: 4, name: 'yyyy'
            @hobbyDic.add(newHobby)
            expect(@hobbyDic.items.yyyy).not.to.exist


    describe 'remove', ->

        beforeEach ->
            class HobbyDic extends BaseDic
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDic = new HobbyDic(items: hobbies)

        it 'removes by key', ->
            @hobbyDic.remove('keyboard')
            expect(@hobbyDic.items.keyboard).not.to.exist

        it 'removes by item', ->
            @hobbyDic.remove(hobbies[0])
            expect(@hobbyDic.items.keyboard).not.to.exist


        it 'do nothing if no key exists', ->
            @hobbyDic.remove('xxx')
