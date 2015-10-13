
facade = require('../create-facade').create()
Facade = facade.constructor

{ BaseDict, MemoryResource } = facade.constructor

hobbies = null


describe 'BaseDict', ->

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

        class HobbyDict extends BaseDict
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyDict = new HobbyDict(items: hobbies)

        explicitKeys = Object.keys(hobbyDict)

        expect(explicitKeys).to.have.length 1
        expect(explicitKeys).to.contain 'items'
        expect(explicitKeys).not.to.contain 'loaded'


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

            expect(dict.ids).to.eql [1,2,3]


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

        it 'get null when the item is not Entity', ->
            nonEntityDict = new NonEntityDict()
            expect(nonEntityDict.ids).to.be.null

        it 'get array of ids when the item is Entity', ->

            hobbyDict = new HobbyDict(items: hobbies)
            expect(hobbyDict.ids).to.deep.equal [1, 2, 3]


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

        before (done) ->

            facade.createRepository('diary').save(id: 'abc', name: 'xxx').then -> done()

        it 'loaded after loaded when ids is given in constructor', (done) ->

            class DiaryDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'diary'

            diaryDict = new DiaryDict(ids: ['abc'])

            expect(diaryDict.loaded).to.be.false
            expect(diaryDict).to.have.length 0
            expect(diaryDict.ids).to.have.length 0

            diaryDict.on 'loaded', ->
                expect(diaryDict.loaded).to.be.true
                expect(diaryDict).to.have.length 1
                expect(diaryDict.ids).to.have.length 1
                expect(diaryDict.ids[0]).to.equal 'abc'
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

            nonEntityFactory = facade.createFactory('non-entity')
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

        it 'can load data by ids synchronously from BaseSyncRepository', ->

            class HobbyDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            dict = new HobbyDict()

            dict.setIds(['1', '3'])

            expect(dict.loaded).to.be.true
            expect(dict.length).to.equal 2
            expect(dict.items).to.have.property '1'
            expect(dict.items).to.have.property '3'


        it 'loads data by ids asynchronously from BaseAsyncRepository', (done) ->

            class DiaryDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'diary'

            dict = new DiaryDict()

            dict.setIds(['abc'])

            expect(dict.loaded).to.be.false
            expect(dict.items).to.eql {}

            dict.on 'loaded', ->

                expect(dict.loaded).to.be.true
                expect(dict.items).to.have.property 'abc'

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
            @factory = facade.createFactory('hobby')

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


