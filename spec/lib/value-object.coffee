
facade = require('../create-facade').create()

ValueObject = facade.constructor.ValueObject

describe 'Entity', ->

    it 'has isEntity, false', ->

        class Schedule extends ValueObject


        facade.addClass('schedule', Schedule)

        Schedule = facade.getModel 'schedule'

        expect(Schedule).to.have.property 'isEntity', false

