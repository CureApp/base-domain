
facade = require('../create-facade').create()
Facade = require('../base-domain')
GeneralFactory = require '../../src/lib/general-factory'

describe 'GeneralFactory', ->

    describe '@create', ->

        it 'returns general factory when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            facade.addClass('abc', Abc)
            expect(GeneralFactory.create('abc', facade)).to.be.instanceof GeneralFactory

