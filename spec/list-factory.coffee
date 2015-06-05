
facade = require('./create-facade').create()
Facade = facade.constructor

describe 'ListFactory', ->

    before ->
        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        class NonEntity extends Facade.BaseModel
            @properties:
                name: @TYPES.STRING

        class HobbyRepository extends Facade.MasterRepository
            @modelName: 'hobby'


        facade.addClass('hobby', Hobby)
        facade.addClass('non-entity', NonEntity)
        facade.addClass('hobby-repository', HobbyRepository)


    describe 'createEmpty', ->

        hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
        hobbyList = hobbyListFactory.createEmpty()

        it 'creates list', ->

            expect(hobbyList).to.be.instanceof Facade.BaseList
            expect(hobbyList.items).to.be.instanceof Array
            expect(hobbyList.loaded).to.be.true

        it 'creates empty list', ->
            expect(hobbyList.items).to.have.length 0
            expect(hobbyList.ids).to.have.length 0


    xdescribe 'createFromObject', ->

        it 'regards arg as list object when arg has ids', ->


    describe 'createFromArray', ->

        it 'throws error when array of non-object given to non-entity-list factory', ->

            hobbyListFactory = facade.createListFactory('ne-list', 'non-entity')
            expect(-> hobbyListFactory.createFromArray(['abc', 'def'])).to.throw Error

        it 'regards string array as id list', (done) ->
            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromArray(['dummy'])

            list.on 'loaded', ->
                expect(list.items).to.have.length.above 0
                done()

        it 'regards object array as pre-model list', (done) ->

            data = [ {id: 3, name: 'keyboard'}, {id: 2, name: 'sailing'} ]

            hobbyListFactory = facade.createListFactory('hobby-list', 'hobby')
            list = hobbyListFactory.createFromArray(data)

            list.on 'loaded', ->
                Hobby = facade.getModel 'hobby'
                expect(list.items).to.have.length 2
                expect(list.items[0]).to.be.instanceof Hobby
                expect(list.ids).to.eql [2,3]
                done()

