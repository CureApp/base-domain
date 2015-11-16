
Facade = require '../base-domain'

{ GeneralFactory, BaseList, Entity, ValueObject,
    BaseSyncRepository, BaseAsyncRepository } = Facade

{ MemoryResource } = require '../others'


describe 'BaseList', ->

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


    describe 'constructor', ->

        it 'sorts model when sort function is defined', ->

            hobbyIds = (hobby.id for hobby in @hobbies)

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
                @className: 'hobby-list'
                sort: (a, b) -> a.id - b.id

            hobbyList = new HobbyList(items: @hobbies, @facade)

            hobbyIdsSorted = (hobby.id for hobby in hobbyList.items)

            expect(hobbyIdsSorted).to.deep.equal [1, 2, 3]


    describe 'ids', ->

        beforeEach ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            class NonEntityList extends BaseList
                @itemModelName: 'non-entity'

            @facade.addClass 'hobby-list', HobbyList
            @facade.addClass 'non-entity-list', NonEntityList

        it 'get array when the item is Entity', ->
            hobbyList = @facade.createModel('hobby-list')
            expect(hobbyList.ids).to.be.instanceof Array

        it 'get undefined when the item is not Entity', ->
            nonEntityList = @facade.createModel('non-entity-list')
            expect(nonEntityList.ids).to.be.undefined

        it 'get array of ids when the item is Entity', ->

            hobbyList = @facade.createModel('hobby-list', @hobbies)
            expect(hobbyList.ids).to.deep.equal [3, 2, 1]



    describe 'first', ->

        it 'returns first value of the items', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList.first()).to.equal @hobbies[0]



    describe 'last', ->

        it 'returns last value of the items', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
                @className: 'hobby-list'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList.last()).to.equal @hobbies[2]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
                @className: 'hobby-list'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList.toArray()).to.deep.equal hobbyList.items


    describe 'forEach', ->

        it 'executes function for each item', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            str = ''

            hobbyList.forEach (item) ->
                str += item.name + '|'

            assert str is 'keyboard|jogging|cycling|'

    describe 'map', ->

        it 'executes function for each item and returns the results', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            ids = hobbyList.map (item) -> item.id

            expect(ids).to.eql [ 3, 2, 1 ]


    describe 'filter', ->

        it 'filter items with given function', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            filtered = hobbyList.filter (item) -> item.id is 3

            expect(filtered).to.eql [ @hobbies[0] ]


    describe 'some', ->

        it 'checks if some items match the condition in function', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            assert hobbyList.some (item) -> item.id is 1
            assert not hobbyList.some (item) -> item.id is 4


    describe 'every', ->

        it 'checks if every items match the condition in function', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            assert hobbyList.every (item) -> item.id?
            assert not hobbyList.every (item) -> item.id is 1


    describe 'add', ->

        it 'appends models', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
                @className: 'hobby-list'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyList = new HobbyList(items: @hobbies, annualCost: 2000, @facade)

            Hobby = @facade.getModel 'hobby'

            hobbyList.add new Hobby(id: 0, name: 'abc', @facade), new Hobby(id: 100, name: 'xyz', @facade)

            expect(hobbyList.first()).to.have.property 'name', 'keyboard'
            expect(hobbyList.last()).to.have.property 'name', 'xyz'


        it 'appends plain objects', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
                @className: 'hobby-list'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyList = new HobbyList(items: @hobbies, annualCost: 2000, @facade)

            hobbyList.add {id: 0, name: 'abc'}, {id: 100, name: 'xyz'}

            expect(hobbyList).to.have.length 5
            expect(hobbyList.first()).to.have.property 'name', 'keyboard'
            expect(hobbyList.last()).to.have.property 'name', 'xyz'



    describe 'clear', ->

        it 'clears all models', ->

            class HobbyList extends BaseList
                @className: 'hobby-list'
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList).to.have.length 3

            hobbyList.clear()

            expect(hobbyList).to.have.length 0
            expect(hobbyList.ids).to.have.length 0

            hobbyList.clear()

            expect(hobbyList).to.have.length 0
            expect(hobbyList.ids).to.have.length 0


    describe 'setIds', ->

        beforeEach (done) ->

            @facade.createRepository('diary').save(id: 'abc', name: 'xxx').then -> done()


        it 'can load data by ids synchronously from BaseSyncRepository', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
                @className: 'hobby-list'
                @properties:
                    annualCost: @TYPES.NUMBER

            list = new HobbyList(null, @facade)

            list.setIds(['1', '3'])
            list.include()

            expect(list.length).to.equal 2


    describe 'remove', ->

        it 'removes an item by index', ->

            class HobbyList extends BaseList
                @className: 'hobby-list'
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList).to.have.length 3

            hobbyList.remove(1)

            expect(hobbyList).to.have.length 2
            expect(hobbyList.ids).to.have.length 2

            expect(hobbyList.ids).to.eql [3, 1]

