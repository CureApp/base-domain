
Facade = require '../base-domain'

{ GeneralFactory, BaseList, Entity, ValueObject,
    BaseSyncRepository, BaseAsyncRepository } = Facade

MemoryResource = require '../../src/memory-resource'


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


    describe 'constructor', ->

        it 'sorts model when sort function is defined', ->

            hobbyIds = (hobby.id for hobby in @hobbies)

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
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

            @facade.addClass HobbyList
            @facade.addClass NonEntityList

        it 'get array when the item is Entity', ->
            hobbyList = @facade.createModel('hobby-list')
            expect(hobbyList.ids).to.be.instanceof Array

        it 'get null when the item is not Entity', ->
            nonEntityList = @facade.createModel('non-entity-list')
            expect(nonEntityList.ids).to.be.null

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

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList.last()).to.equal @hobbies[2]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList.toArray()).to.deep.equal hobbyList.items



    describe 'add', ->

        it 'appends models', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'
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
                @properties:
                    annualCost: @TYPES.NUMBER

            list = new HobbyList(null, @facade)

            list.setIds(['1', '3'])

            expect(list.loaded).to.be.true
            expect(list.length).to.equal 2


        it 'loads data by ids asynchronously from BaseAsyncRepository', (done) ->

            class DiaryList extends BaseList
                @itemModelName: 'diary'

            list = new DiaryList(null, @facade)

            list.setIds(['abc'])

            expect(list.loaded).to.be.false
            expect(list.items).to.eql []

            list.on 'loaded', ->

                expect(list.loaded).to.be.true
                expect(list.items).to.have.length 1

                done()


    describe 'remove', ->

        it 'removes an item by index', ->

            class HobbyList extends BaseList
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(items: @hobbies, @facade)

            expect(hobbyList).to.have.length 3

            hobbyList.remove(1)

            expect(hobbyList).to.have.length 2
            expect(hobbyList.ids).to.have.length 2

            expect(hobbyList.ids).to.eql [3, 1]

