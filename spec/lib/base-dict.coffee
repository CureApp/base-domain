
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

        @facade.addClass 'hobby', Hobby
        @facade.addClass 'non-entity', NonEntity
        @facade.addClass 'hobby-repository', HobbyRepository
        @facade.addClass 'diary', Diary
        @facade.addClass 'diary-repository', DiaryRepository

        @hobbyRepo = @facade.createRepository('hobby')

        @hobbies = (for name, i in ['keyboard', 'jogging', 'cycling']
            hobby = @facade.createModel 'hobby', id: 3 - i, name: name
            @hobbyRepo.save hobby
        )


    describe '@key', ->

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

            @facade.addClass 'hobby-dict', HobbyDict
            @facade.addClass 'non-entity-dict', NonEntityDict

        it 'get array of ids when the item is Entity', ->

            hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)
            expect(hobbyDict.ids).to.deep.equal [1, 2, 3]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)

            assert hobbyDict.length is 3

            arr = hobbyDict.toArray()
            assert arr.length is 3

            for hobby in arr
                assert hobby in @hobbies


    describe 'keys', ->

        it 'returns keys of the items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)

            keys = hobbyDict.keys()
            expect(keys).to.eql ['1', '2', '3']


    describe 'keyValues', ->

        it 'iterates key-value of the items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)

            hobbyDict.keyValues (k, v) ->
                assert k in ['1', '2', '3']
                assert v.name in ['keyboard', 'jogging', 'cycling']


    describe 'length', ->

        it 'is the number of items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @className: 'hobby-dict'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)
            assert Object.keys(hobbyDict.items).length is 3
            assert hobbyDict.length is 3


    describe 'setIds', ->

        beforeEach ->

            @facade.createRepository('diary').save(id: 'abc', name: 'xxx')

        it 'can load data by ids synchronously from BaseSyncRepository', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @className: 'hobby-dict'
                @properties:
                    annualCost: @TYPES.NUMBER

            dict = new HobbyDict(null, @facade)

            dict.setIds(['1', '3'])
            dict.include()

            assert dict.length is 2
            assert dict.items[1]?
            assert dict.items[3]?


        it 'loads data by ids asynchronously from BaseAsyncRepository', ->

            class DiaryDict extends BaseDict
                @itemModelName: 'diary'
                @className: 'hobby-dict'

            dict = new DiaryDict(null, @facade)

            dict.setIds(['abc'])

            assert dict.items is undefined

            dict.include().then =>
                assert dict.items?
                assert dict.itemLength is 1


    describe 'has', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass 'hobby-dict', HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'returns true when item exists', ->
            assert @hobbyDict.has('keyboard')

        it 'returns false when item does not exist', ->
            assert @hobbyDict.has('sailing') is false


    describe 'contains', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass 'hobby-dict', HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'returns true when item exists', ->
            assert @hobbyDict.contains(@hobbies[0])

        it 'returns false when item does not exist', ->
            newHobby = @facade.createModel('hobby', id: 4, name: 'xxx')
            assert @hobbyDict.has(newHobby) is false

        it 'returns false when item with same key exists but these two are different', ->
            newHobby = @facade.createModel('hobby', id: 4, name: 'keyboard')
            assert @hobbyDict.has(newHobby) is false


    describe 'get', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass 'hobby-dict', HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)

        it 'returns submodel when key exists', ->
            assert @hobbyDict.get('keyboard') instanceof @facade.getModel('hobby')

        it 'returns undefined when key does not exist', ->
            assert @hobbyDict.get('xxx') is undefined



    describe 'add', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass 'hobby-dict', HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'add item model', ->
            newHobby = @facade.createModel('hobby', id: 4, name: 'xxx')
            @hobbyDict.add(newHobby)
            assert @hobbyDict.items.xxx instanceof @facade.getModel 'hobby'


        it 'adds non-item model', ->
            newHobby = id: 4, name: 'yyyy'
            @hobbyDict.add(newHobby)
            assert @hobbyDict.items.yyyy instanceof @facade.getModel 'hobby'


    describe 'remove', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @key: (item) -> item.name

            @facade.addClass 'hobby-dict', HobbyDict
            @hobbyDict = @facade.createModel('hobby-dict', items: @hobbies)


        it 'removes by key', ->

            assert @hobbyDict.length is 3

            @hobbyDict.remove('keyboard')

            assert not @hobbyDict.items.keyboard?
            assert @hobbyDict.length is 2
            assert 3 not in @hobbyDict.ids


        it 'removes by item', ->

            assert @hobbyDict.length is 3

            @hobbyDict.remove(@hobbies[0])

            assert not @hobbyDict.items.keyboard?
            assert @hobbyDict.length is 2
            assert 3 not in @hobbyDict.ids



        it 'do nothing if no key exists', ->

            @hobbyDict.remove('xxx')



    describe 'clear', ->

        it 'removes all items', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @className: 'hobby-dict'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)

            assert hobbyDict.length is 3
            assert hobbyDict.ids.length is 3

            hobbyDict.clear()

            assert hobbyDict.length is 0
            assert hobbyDict.ids.length is 0

            hobbyDict.clear()

            assert hobbyDict.length is 0
            assert hobbyDict.ids.length is 0



    describe 'toggle', ->

        beforeEach ->
            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @className: 'hobby-dict'
                @key: (item) -> item.name

            @hobbyDict = new HobbyDict(items: @hobbies, @facade)


        it 'adds item if not loaded', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @className: 'hobby-dict'
                @key: (item) -> item.name

            hobbyDict = new HobbyDict(null, @facade)
            assert hobbyDict.loaded() is false
            h = @facade.createModel 'hobby', name: 'skiing'

            hobbyDict.toggle h
            assert hobbyDict.has 'skiing'





        it 'adds if not exist', ->

            h = @facade.createModel 'hobby', name: 'skiing'

            @hobbyDict.toggle h

            assert @hobbyDict.has 'skiing'


        it 'removes if exists', ->

            h = @facade.createModel 'hobby', name: 'skiing'

            @hobbyDict.add h
            @hobbyDict.toggle h
            assert @hobbyDict.has('skiing') is false


    describe 'toPlainObject', ->

        it 'returns object without items when dict has no items', ->

            class HobbyDict extends BaseDict
                @className: 'hobby-dict'
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict({}, @facade)
            plain = hobbyDict.toPlainObject()
            newHobbyDict = new HobbyDict(plain, @facade)

            assert plain.hasOwnProperty('items') is false
            assert plain.hasOwnProperty('ids')

            expect(hobbyDict).to.eql newHobbyDict


        it 'returns object without ids or items when dict has no items (non-entity-dict)', ->

            class NonEntityDict extends BaseDict
                @className: 'hobby-dict'
                @itemModelName: 'non-entity'

            nonEntityDict = new NonEntityDict({}, @facade)
            plain = nonEntityDict.toPlainObject()
            newNonEntityDict = new NonEntityDict({}, @facade)
            assert plain.hasOwnProperty('items') is false
            assert plain.hasOwnProperty('ids') is false

            expect(nonEntityDict).to.eql newNonEntityDict

        it 'returns object with ids when item is entity', ->

            class HobbyDict extends BaseDict
                @className: 'hobby-dict'
                @itemModelName: 'hobby'

            hobbyDict = new HobbyDict(items: @hobbies, @facade)
            plain = hobbyDict.toPlainObject()

            assert plain.ids?
            assert not plain.items?


        it 'returns object with items when item is non-entity', ->

            class NonEntityDict extends BaseDict
                @className: 'hobby-dict'
                @itemModelName: 'non-entity'

            nonEntities = (for name, i in ['keyboard', 'jogging', 'cycling']
                @facade.createModel 'non-entity', id: 3 - i, name: name
            )

            nonEntityDict = new NonEntityDict(items: nonEntities, @facade)
            plain = nonEntityDict.toPlainObject()

            assert not plain.ids?
            assert plain.items?
            assert plain.items instanceof Array
            assert plain.items.length is 3


        it 'returns object with custom properties', ->

            class HobbyDict extends BaseDict
                @itemModelName: 'hobby'
                @className: 'hobby-dict'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyDict = new HobbyDict(items: @hobbies, annualCost: 2000, @facade)

            assert hobbyDict.toPlainObject().ids?
            assert hobbyDict.toPlainObject().annualCost?
