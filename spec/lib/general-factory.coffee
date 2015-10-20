Facade = require('../base-domain')
GeneralFactory = require '../../src/lib/general-factory'

describe 'GeneralFactory', ->

    describe '@create', ->

        it 'returns general factory when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            expect(GeneralFactory.create('abc', f)).to.be.instanceof GeneralFactory

