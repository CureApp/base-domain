
{ Util } = require './others'


describe 'Util', ->

    describe 'camelize', ->

        it 'converts larry-carlton to LarryCarlton', ->

            cameled = Util.camelize('larry-carlton')

            assert cameled is 'LarryCarlton'


        it 'converts get-element-by-id to getElementById when lowerFirst is true', ->

            cameled = Util.camelize('get-element-by-id', true)

            assert cameled is 'getElementById'


    describe 'hyphenize', ->

        it 'converts CureApp to cure-app', ->

            hyphenized = Util.hyphenize('CureApp')

            assert hyphenized is 'cure-app'


        it 'converts getElementById to get-element-by-id', ->

            hyphenized = Util.hyphenize('getElementById')

            assert hyphenized is 'get-element-by-id'


        it 'converts Room335 to room335', ->

            hyphenized = Util.hyphenize('Room335')

            assert hyphenized is 'room335'


        it 'converts WBC to w-b-c', ->

            hyphenized = Util.hyphenize('WBC')

            assert hyphenized is 'w-b-c'


    describe 'isInstance', ->

        it 'just the same result as "instanceof" operator when not in Titanium environment', ->

            F = ->
            f = new F
            assert Util.isInstance(f, F)
            assert Util.isInstance({}, F) is false


        it 'also returns the same result as "instanceof" operator, when class is given', ->

            class Human
            class Patient extends Human

            h = new Human
            p = new Patient
            o = {}
            n = null
            u = undefined

            assert Util.isInstance(p, Human)
            assert Util.isInstance(h, Human)
            assert Util.isInstance(h, Human)
            assert Util.isInstance(o, Human) is false
            assert Util.isInstance(n, Human) is false
            assert Util.isInstance(u, Human) is false

            assert Util.isInstance(p, Patient)
            assert Util.isInstance(h, Patient) is false
            assert Util.isInstance(o, Patient) is false
            assert Util.isInstance(n, Patient) is false
            assert Util.isInstance(u, Patient) is false

            assert Util.isInstance(p, Object)
            assert Util.isInstance(h, Object)
            assert Util.isInstance(o, Object)
            assert Util.isInstance(n, Object) is false
            assert Util.isInstance(u, Object) is false


        describe 'in Titanium environment', ->

            before ->
                # creates Ti in global scope
                getGlobal = -> @
                getGlobal().Ti = {}
                assert Ti?

            after ->
                getGlobal = -> @
                getGlobal().Ti = undefined
                assert not Ti?


            it 'also returns the same result as "instanceof" operator', ->
                F = ->
                f = new F
                assert Util.isInstance(f, F)
                assert Util.isInstance({}, F) is false

            it 'also returns the same result as "instanceof" operator, when class is given', ->

                class Human
                class Patient extends Human

                h = new Human
                p = new Patient
                o = {}
                n = null
                u = undefined

                assert Util.isInstance(p, Human)
                assert Util.isInstance(h, Human)
                assert Util.isInstance(h, Human)
                assert Util.isInstance(o, Human) is false
                assert Util.isInstance(n, Human) is false
                assert Util.isInstance(u, Human) is false

                assert Util.isInstance(p, Patient)
                assert Util.isInstance(h, Patient) is false
                assert Util.isInstance(o, Patient) is false
                assert Util.isInstance(n, Patient) is false
                assert Util.isInstance(u, Patient) is false

                assert Util.isInstance(p, Object)
                assert Util.isInstance(h, Object)
                assert Util.isInstance(o, Object)
                assert Util.isInstance(n, Object) is false
                assert Util.isInstance(u, Object) is false


    describe 'requireFile', ->

        it 'just requires a file', ->

            abc = Util.requireFile(__dirname + '/sample-files/abc')
            assert abc is 'abc'


        describe 'in Titanium environment', ->

            beforeEach ->
                getGlobal = -> @
                getGlobal().Ti =
                    Platform:
                        name: 'android'
                    Filesystem:
                        getFile: (a, b) ->
                        resourcesDirectory: 'Resources'

            afterEach ->
                getGlobal = -> @
                getGlobal().Ti = undefined
                assert not Ti?


            it 'just adds suffix ".js" and requires the path when platform is android', ->

                Ti.Filesystem.getFile = -> throw new Error 'this must not be called'

                abc = Util.requireFile(__dirname + '/sample-files/abc')
                assert abc is 'abc'


            it 'adds suffix ".js", checkes existence and requires when platform is not android', ->

                Ti.Platform.name = 'iPhone'

                Ti.Filesystem.getFile = (a, b) ->
                    exists: -> true

                abc = Util.requireFile(__dirname + '/sample-files/abc')
                assert abc is 'abc'


            it 'adds suffix ".js", checkes existence and throws an error when platform is not android and file does not exist', ->

                Ti.Platform.name = 'iPhone'

                Ti.Filesystem.getFile = (a, b) ->

                    exists: -> false

                expect(-> Util.requireFile(__dirname + '/sample-files/abc')).to.throw Error


