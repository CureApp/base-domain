
facade = require './init'

BaseList = facade.constructor.BaseList

hobbyFactory = facade.createFactory('hobby', true)

hobbies = (for name, i in ['keyboard', 'jogging', 'cycling']
    hobbyFactory.createFromObject id: 3 - i, name: name
)


describe 'BaseList', ->


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

        it 'get array of items', ->

            class HobbyList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'hobby'

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
