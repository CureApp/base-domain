
facade = require('../create-facade').create()
{ Base } = require '../base-domain'

describe 'Base', ->

    describe 'deprecated', ->

        before ->
            @consoleWarn = console.warn

        after ->
            console.error = @consoleWarn


        it 'shows message about deprecation', (done) ->

            class SomeClass extends Base
                foo: ->
                    @deprecated('SomeClass#foo()', 'Call "bar" instead.')

            instance = new SomeClass(facade)

            console.warn = (str) ->
                assert str.match /Deprecated method: 'SomeClass#foo\(\)'\. Call "bar" instead\./
                done()

            instance.foo()


    describe 'facade', ->

        it 'returns domain facade', ->

            class SomeClass extends Base

            facade.addClass('some-class', SomeClass)

            instance = facade.create(SomeClass)
            assert instance.facade is facade
            assert facade.facade is facade
