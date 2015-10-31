
Facade = require '../base-domain'

{ GeneralFactory, Collection, Entity, ValueObject,
    BaseSyncRepository, BaseAsyncRepository } = Facade

{ MemoryResource } = require '../others'

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
            toArray: -> []

        hobbyCollection = new HobbyCollection(items: @hobbies, @facade)

        expect(hobbyCollection.itemFactory).to.be.instanceof GeneralFactory


    it '"isItemEntity" and "itemFactory" are hidden properties', ->

        class HobbyCollection extends Collection
            @itemModelName: 'hobby'
            toArray: -> []

        hobbyCollection = new HobbyCollection(items: @hobbies, @facade)

        explicitKeys = Object.keys(hobbyCollection)

        expect(explicitKeys).not.to.contain 'isItemEntity'
        expect(explicitKeys).not.to.contain 'itemFactory'


    it 'can contain custom properties', ->

        class HobbyCollection extends Collection
            @itemModelName: 'hobby'
            @properties:
                annualCost: @TYPES.NUMBER
            toArray: -> []

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
                toArray: -> []

            class NonEntityCollection extends Collection
                @itemModelName: 'non-entity'
                toArray: -> []

            @facade.addClass HobbyCollection
            @facade.addClass NonEntityCollection

        it 'get array when the item is Entity', ->
            hobbyCollection = @facade.createModel('hobby-collection')
            expect(hobbyCollection.ids).to.be.instanceof Array

        it 'get undefined when the item is not Entity', ->
            nonEntityCollection = @facade.createModel('non-entity-collection')
            expect(nonEntityCollection.ids).to.be.undefined
            expect(nonEntityCollection).not.to.have.property 'ids'



