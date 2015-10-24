
Facade = require '../base-domain'

{ GeneralFactory, Collection, Entity, ValueObject,
    BaseSyncRepository, BaseAsyncRepository } = Facade

MemoryResource = require '../../src/memory-resource'

describe 'Collection', ->

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


    it 'has itemFactory', ->

        class HobbyCollection extends Collection
            @itemModelName: 'hobby'

        hobbyCollection = new HobbyCollection(items: @hobbies, @facade)

        expect(hobbyCollection.itemFactory).to.be.instanceof GeneralFactory


    it '"loaded", "isItemEntity" and "itemFactory" are hidden properties whereas items is explicit', ->

        class HobbyCollection extends Collection
            @itemModelName: 'hobby'

        hobbyCollection = new HobbyCollection(items: @hobbies, @facade)

        explicitKeys = Object.keys(hobbyCollection)

        expect(explicitKeys).to.have.length 1
        expect(explicitKeys).to.contain 'items'
        expect(explicitKeys).not.to.contain 'loaded'
        expect(explicitKeys).not.to.contain 'isItemEntity'
        expect(explicitKeys).not.to.contain 'itemFactory'


    it 'can contain custom properties', ->

        class HobbyCollection extends Collection
            @itemModelName: 'hobby'
            @properties:
                annualCost: @TYPES.NUMBER

        hobbyCollection = new HobbyCollection(items: @hobbies, annualCost: 2000, @facade)

        expect(hobbyCollection).to.have.property 'annualCost', 2000

        explicitKeys = Object.keys(hobbyCollection)
        expect(explicitKeys).to.contain 'annualCost'

    it 'throws error if itemModelName is not set', ->
        class HobbyCollection extends Collection

        expect(-> new HobbyCollection(null, @facade)).to.throw Facade.DomainError


    describe 'ids', ->

        beforeEach ->

            class HobbyCollection extends Collection
                @itemModelName: 'hobby'

            class NonEntityCollection extends Collection
                @itemModelName: 'non-entity'

            @facade.addClass HobbyCollection
            @facade.addClass NonEntityCollection

        it 'get array when the item is Entity', ->
            hobbyCollection = @facade.createModel('hobby-collection')
            expect(hobbyCollection.ids).to.be.instanceof Array

        it 'get null when the item is not Entity', ->
            nonEntityCollection = @facade.createModel('non-entity-collection')
            expect(nonEntityCollection.ids).to.be.null

        it 'get array of ids when the item is Entity', ->

            hobbyCollection = @facade.createModel('hobby-collection', items: @hobbies)
            expect(hobbyCollection.ids).to.deep.equal [3, 2, 1]



    describe "on('loaded')", ->

        beforeEach (done) ->

            @facade.createRepository('diary').save(id: 'abc', name: 'xxx').then -> done()


        it 'loaded after loaded when ids is given in constructor', (done) ->

            class DiaryCollection extends Collection
                @itemModelName: 'diary'

            diaryCollection = new DiaryCollection(ids: ['abc'], @facade)

            expect(diaryCollection.loaded).to.be.false
            expect(diaryCollection.ids).to.have.length 0

            diaryCollection.on 'loaded', ->
                expect(diaryCollection.loaded).to.be.true
                done()


        it 'executed after event registered when array is given in constructor', (done) ->

            class HobbyCollection extends Collection
                @itemModelName: 'hobby'

            hobbyCollection = new HobbyCollection(items: @hobbies, @facade)

            hobbyCollection.on 'loaded', ->
                expect(hobbyCollection.loaded).to.be.true
                done()


    describe 'toPlainObject', ->

        it 'returns object with ids when item is entity', ->

            class HobbyCollection extends Collection
                @itemModelName: 'hobby'

            hobbyCollection = new HobbyCollection(items: @hobbies, @facade)
            plain = hobbyCollection.toPlainObject()

            expect(plain).to.have.property 'ids'
            expect(plain).not.to.have.property 'items'


        it 'returns object with items when item is non-entity', ->

            class NonEntityCollection extends Collection
                @itemModelName: 'non-entity'

            nonEntities = (for name, i in ['keyboard', 'jogging', 'cycling']
                @facade.createModel 'non-entity', id: 3 - i, name: name
            )

            nonEntityCollection = new NonEntityCollection(items: nonEntities, @facade)
            plain = nonEntityCollection.toPlainObject()

            expect(plain).not.to.have.property 'ids'
            expect(plain).to.have.property 'items'
            expect(plain.items).to.be.instanceof Array
            expect(plain.items).to.have.length 3


        it 'returns object with custom properties', ->

            class HobbyCollection extends Collection
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyCollection = new HobbyCollection(items: @hobbies, annualCost: 2000, @facade)

            expect(hobbyCollection.toPlainObject()).to.have.property 'ids'
            expect(hobbyCollection.toPlainObject()).to.have.property 'annualCost'


    describe 'setIds', ->

        beforeEach (done) ->

            @facade.createRepository('diary').save(id: 'abc', name: 'xxx').then -> done()

        it 'can load data by ids synchronously from BaseSyncRepository', ->

            class HobbyCollection extends Collection
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            coll = new HobbyCollection(null, @facade)

            coll.setIds(['1', '3'])

            expect(coll.loaded).to.be.true


        it 'loads data by ids asynchronously from BaseAsyncRepository', (done) ->

            class DiaryCollection extends Collection
                @itemModelName: 'diary'

            coll = new DiaryCollection(null, @facade)

            coll.setIds(['abc'])

            expect(coll.loaded).to.be.false

            coll.on 'loaded', ->

                expect(coll.loaded).to.be.true
                done()
