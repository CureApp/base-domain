
facade = require('./create-facade').create()
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

        facade.addClass 'hobby', Hobby
        facade.addClass 'non-entity', NonEntity

        hobbyFactory = facade.createFactory('hobby', true)

        hobbies = (for name, i in ['keyboard', 'jogging', 'cycling']
            hobbyFactory.createFromObject id: 3 - i, name: name
        )


    it '"items", "loaded", and "listeners" are hidden properties', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'

        hobbyList = new HobbyList(hobbies)

        explicitKeys = Object.keys(hobbyList)

        expect(explicitKeys).to.have.length 0
        expect(explicitKeys).not.to.contain 'items'
        expect(explicitKeys).not.to.contain 'listeners'
        expect(explicitKeys).not.to.contain 'loaded'


    it 'can contain custom properties', ->

        class HobbyList extends BaseList
            @getFacade: -> facade
            getFacade:  -> facade
            @itemModelName: 'hobby'
            @properties:
                annualCost: @TYPES.NUMBER

        hobbyList = new HobbyList(hobbies, annualCost: 2000)

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

            hobbyList = new HobbyList(hobbies)

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

            hobbyList = new HobbyList(hobbies)
            expect(hobbyList.ids).to.deep.equal [1, 2, 3]



    describe 'first', ->

        it 'returns first value of the items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(hobbies)

            expect(hobbyList.first()).to.equal hobbies[2]



    describe 'last', ->

        it 'returns last value of the items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(hobbies)

            expect(hobbyList.last()).to.equal hobbies[0]


    describe 'toArray', ->

        it 'returns deeply-equal array to items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(hobbies)

            expect(hobbyList.toArray()).to.deep.equal hobbyList.items



    describe "on('loaded')", ->

        it 'executed after loaded when promise is given in constructor', (done) ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbiesPromise = new Promise (resolve) -> resolve hobbies

            hobbyList = new HobbyList(hobbiesPromise)
            expect(hobbyList.loaded).to.be.false
            expect(hobbyList.items).to.have.length 0

            hobbyList.on 'loaded', ->
                expect(hobbyList.loaded).to.be.true
                expect(hobbyList.items).to.have.length 3
                done()

        it 'executed after event registered when array is given in constructor', (done) ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

            hobbyList = new HobbyList(hobbies)

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

            hobbyList = new HobbyList(hobbies)
            plain = hobbyList.toPlainObject()

            expect(plain).to.have.property 'ids'
            expect(plain).not.to.have.property 'items'


        it 'returns object with items when item is non-entity', ->

            class NonEntityList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'non-entity'

            hobbyList = new NonEntityList(hobbies)
            plain = hobbyList.toPlainObject()

            expect(plain).not.to.have.property 'ids'
            expect(plain).to.have.property 'items'


        it 'returns object with custom properties', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'
                @properties:
                    annualCost: @TYPES.NUMBER

            hobbyList = new HobbyList(hobbies, annualCost: 2000)

            expect(hobbyList.toPlainObject()).to.have.property 'ids'
            expect(hobbyList.toPlainObject()).to.have.property 'annualCost'

