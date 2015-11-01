
{ ValueObject } = require '../base-domain'

describe 'Entity', ->

    it 'has isEntity, false', ->

        class Schedule extends ValueObject

        expect(Schedule).to.have.property 'isEntity', false


    describe 'equals', ->

        it 'checks deep equality', ->

            facade = require('../create-facade').create()

            class Schedule extends ValueObject
                @properties:
                    title   : @TYPES.STRING
                    date    : @TYPES.DATE
                    visited : @TYPES.BOOLEAN

            facade.addClass('schedule', Schedule)

            date = new Date()

            scheduleA = facade.createModel('schedule', title: 'abc', date: date, visited: false)
            scheduleB = facade.createModel('schedule', title: 'abc', date: date, visited: false)
            scheduleC = facade.createModel('schedule', title: 'abcd', date: date, visited: false)

            expect(scheduleA.equals scheduleB).to.be.true
            expect(scheduleA.equals scheduleC).to.be.false
