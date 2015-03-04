
Facade = require('../src/lib/facade')

describe 'Facade', ->


    describe '@createInstance', ->

        it 'returns instance of Facade', ->
            f = Facade.createInstance()
            expect(f).to.be.instanceof Facade


        it 'returns instance of extended class', ->
            class ChildFacade extends Facade

            f = ChildFacade.createInstance()
            expect(f).to.be.instanceof Facade
            expect(f).to.be.instanceof ChildFacade

