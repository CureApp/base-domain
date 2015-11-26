
{ ValueObject } = require '../base-domain'

describe 'Entity', ->

    it 'has isEntity, false', ->

        class Schedule extends ValueObject

        assert Schedule.isEntity is false


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

            assert scheduleA.equals scheduleB
            assert (scheduleA.equals scheduleC) is false
