
facade = require('./create-facade').create()
Facade = facade.constructor

describe 'ListFactory', ->

    before ->
        class Hobby extends Facade.Entity
            @properties:
                name: @TYPES.STRING

        facade.addClass('hobby', Hobby)


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

