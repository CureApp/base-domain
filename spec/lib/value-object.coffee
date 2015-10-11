
facade = require('../create-facade').create()

ValueObject = facade.constructor.ValueObject

describe 'Entity', ->

    it 'has isEntity, false', ->

        class Schedule extends ValueObject


        facade.addClass('schedule', Schedule)

        Schedule = facade.getModel 'schedule'

        expect(Schedule).to.have.property 'isEntity', false


    describe 'equals', ->

        it 'checks deep equality', ->

            class Schedule extends ValueObject
                @properties:
                    title   : @TYPES.STRING
                    date    : @TYPES.DATE
                    visited : @TYPES.BOOLEAN

            facade.addClass('schedule', Schedule)

            Schedule = facade.getModel 'schedule'

            date = new Date()

            scheduleA = new Schedule(title: 'abc', date: date, visited: false)
            scheduleB = new Schedule(title: 'abc', date: date, visited: false)
            scheduleC = new Schedule(title: 'abcd', date: date, visited: false)

            expect(scheduleA.equals scheduleB).to.be.true
            expect(scheduleA.equals scheduleC).to.be.false
