
Facade = require '../base-domain'

{ GeneralFactory, BaseDict, Entity, ValueObject,
    BaseSyncRepository, BaseAsyncRepository } = Facade

{ MemoryResource } = require '../others'

describe 'BaseDict', ->

    beforeEach ->

        @facade = require('../create-facade').create()

        class Hobby extends Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends ValueObject
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends BaseSyncRepository
            @modelName: 'hobby'
            client: new MemoryResource()

        class Diary extends Entity
            @properties:
                name: @TYPES.STRING

        class DiaryRepository extends BaseAsyncRepository
            @modelName: 'diary'
            client: new MemoryResource()

        @facade.addClass Hobby
        @facade.addClass NonEntity
        @facade.addClass HobbyRepository
        @facade.addClass Diary
        @facade.addClass DiaryRepository

        @hobbyRepo = @facade.createRepository('hobby')

        @hobbies = (for name, i in ['keyboard', 'jogging', 'cycling']
            hobby = @facade.createModel 'hobby', id: 3 - i, name: name
            @hobbyRepo.save hobby
        )


    describe '@keys', ->

        it 'originally returns item.id', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            dict = new HobbyDict(null, @facade).setItems(@hobbies)

            expect(dict.ids).to.eql [1,2,3]


    describe 'ids', ->

        beforeEach ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            class NonEntityDict extends BaseDict
                @itemModelName: 'non-entity'

            @facade.addClass HobbyDict
            @facade.addClass NonEntityDict

        it 'get array of ids when the item is Entity', ->

            hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)
            expect(hobbyDict.ids).to.deep.equal [1, 2, 3]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)

            expect(hobbyDict).to.have.length 3

            arr = hobbyDict.toArray()
            expect(arr).to.have.length 3

            for hobby in arr
                expect(@hobbies).to.include hobby


    describe 'length', ->

        it 'is the number of items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)
            expect(Object.keys(hobbyDict.items)).to.have.length 3
            expect(hobbyDict).to.have.length 3


    describe 'setIds', ->

        beforeEach (done) ->

            @facade.createRepository('diary').save(id: 'abc', name: 'xxx').then -> done()

        it 'can load data by ids synchronously from BaseSyncRepository', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            dict = new HobbyDict(null, @facade)

            dict.setIds(['1', '3'])
            dict.include()

            expect(dict.length).to.equal 2
            expect(dict.items).to.have.property '1'
            expect(dict.items).to.have.property '3'


        it 'loads data by ids asynchronously from BaseAsyncRepository', (done) ->

            class DiaryDict extends BaseDict
                @itemModelName: 'diary'

            dict = new DiaryDict(null, @facade)

            dict.setIds(['abc'])

            expect(dict.items).to.be.undefined

            dict.include().then =>
                expect(dict.items).to.exist
                expect(dict.itemLength).to.equal 1
                done()


    describe 'has', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'returns true when item exists', ->
            expect(@hobbyDict.has('keyboard')).to.be.true

        it 'returns false when item does not exist', ->
            expect(@hobbyDict.has('sailing')).to.be.false


    describe 'contains', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'returns true when item exists', ->
            expect(@hobbyDict.contains(@hobbies[0])).to.be.true

        it 'returns false when item does not exist', ->
            newHobby = @facade.createModel('hobby', id: 4, name: 'xxx')
            expect(@hobbyDict.has(newHobby)).to.be.false

        it 'returns false when item with same key exists but these two are different', ->
            newHobby = @facade.createModel('hobby', id: 4, name: 'keyboard')
            expect(@hobbyDict.has(newHobby)).to.be.false


    describe 'get', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)

        it 'returns submodel when key exists', ->
            expect(@hobbyDict.get('keyboard')).to.be.instanceof @facade.getModel('hobby')

        it 'returns undefined when key does not exist', ->
            expect(@hobbyDict.get('xxx')).to.be.undefined



    describe 'add', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'add item model', ->
            newHobby = @facade.createModel('hobby', id: 4, name: 'xxx')
            @hobbyDict.add(newHobby)
            expect(@hobbyDict.items.xxx).to.be.instanceof @facade.getModel 'hobby'


        it 'adds non-item model', ->
            newHobby = id: 4, name: 'yyyy'
            @hobbyDict.add(newHobby)
            expect(@hobbyDict.items.yyyy).to.be.instanceof @facade.getModel 'hobby'


    describe 'remove', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'removes by key', ->
            @hobbyDict.remove('keyboard')
            expect(@hobbyDict.items.keyboard).not.to.exist

        it 'removes by item', ->
            @hobbyDict.remove(@hobbies[0])
            expect(@hobbyDict.items.keyboard).not.to.exist


        it 'do nothing if no key exists', ->
            @hobbyDict.remove('xxx')



    describe 'clear', ->

        it 'removes all items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)

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
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: @hobbies, @facade)

        it 'adds if not exist', ->

            h = @facade.createModel 'hobby', name: 'skiing'

            @hobbyDict.toggle h

            expect(@hobbyDict.has 'skiing').to.be.true


        it 'removes if exists', ->

            h = @facade.createModel 'hobby', name: 'skiing'

            @hobbyDict.add h
            @hobbyDict.toggle h
            expect(@hobbyDict.has 'skiing').to.be.false


    describe 'toPlainObject', ->

        it 'returns object with ids when item is entity', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)
            plain = hobbyDict.toPlainObject()

            expect(plain).to.have.property 'ids'
            expect(plain).not.to.have.property 'items'


        it 'returns object with items when item is non-entity', ->

            class NonEntityDict extends BaseDict
                @itemModelName: 'non-entity'

            nonEntities = (for name, i in ['keyboard', 'jogging', 'cycling']
                @facade.createModel 'non-entity', id: 3 - i, name: name
            )

            nonEntityDict = new NonEntityDict(items: nonEntities, @facade)
            plain = nonEntityDict.toPlainObject()

            expect(plain).not.to.have.property 'ids'
            expect(plain).to.have.property 'items'
            expect(plain.items).to.be.instanceof Array
            expect(plain.items).to.have.length 3


        it 'returns object with custom properties', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyDict = new HobbyDict(items: @hobbies, annualCost: 2000, @facade)

            expect(hobbyDict.toPlainObject()).to.have.property 'ids'
            expect(hobbyDict.toPlainObject()).to.have.property 'annualCost'
