
facade = require('../create-facade').create('domain')

{ Entity } = facade.constructor

Hobby = facade.getModel 'hobby'

describe 'Entity', ->

    it 'has isEntity, true', ->

        expect(Hobby).to.have.property 'isEntity', true


    describe 'equals', ->

        it 'checks equality of id', ->

            class Schedule extends Entity
                @properties:
                    title   : @TYPES.STRING
                    date    : @TYPES.DATE
                    visited : @TYPES.BOOLEAN

            facade.addClass('schedule', Schedule)

            date = new Date()

            scheduleA = new Schedule(id: 'abc', title: 'abc', date: date, visited: false, facade)
            scheduleB = new Schedule(id: 'abcd', title: 'abc', date: date, visited: false, facade)
            scheduleC = new Schedule(id: 'abc', title: 'abcd', date: date, visited: false, facade)

            expect(scheduleA.equals scheduleB).to.be.false
            expect(scheduleA.equals scheduleC).to.be.true
