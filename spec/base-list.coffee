
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
