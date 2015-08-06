
Util = require '../../src/lib/util'


describe 'Util', ->

    describe 'camelize', ->

        it 'converts larry-carlton to LarryCarlton', ->

            cameled = Util.camelize('larry-carlton')

            expect(cameled).to.equal 'LarryCarlton'


        it 'converts get-element-by-id to getElementById when lowerFirst is true', ->

            cameled = Util.camelize('get-element-by-id', true)

            expect(cameled).to.equal 'getElementById'


    describe 'hyphenize', ->

        it 'converts CureApp to cure-app', ->

            hyphenized = Util.hyphenize('CureApp')

            expect(hyphenized).to.equal 'cure-app'


        it 'converts getElementById to get-element-by-id', ->

            hyphenized = Util.hyphenize('getElementById')

            expect(hyphenized).to.equal 'get-element-by-id'


        it 'converts Room335 to room335', ->

            hyphenized = Util.hyphenize('Room335')

            expect(hyphenized).to.equal 'room335'


        it 'converts WBC to w-b-c', ->

            hyphenized = Util.hyphenize('WBC')

            expect(hyphenized).to.equal 'w-b-c'


    describe 'isInstance', ->

        it 'just the same result as "instanceof" operator when not in Titanium environment', ->

            F = ->
            f = new F
            expect(Util.isInstance(f, F)).to.be.true
            expect(Util.isInstance({}, F)).to.be.false


        it 'also returns the same result as "instanceof" operator, when class is given', ->

            class Human
            class Patient extends Human

            h = new Human
            p = new Patient
            o = {}
            n = null
            u = undefined

            expect(Util.isInstance(p, Human)).to.be.true
            expect(Util.isInstance(h, Human)).to.be.true
            expect(Util.isInstance(h, Human)).to.be.true
            expect(Util.isInstance(o, Human)).to.be.false
            expect(Util.isInstance(n, Human)).to.be.false
            expect(Util.isInstance(u, Human)).to.be.false

            expect(Util.isInstance(p, Patient)).to.be.true
            expect(Util.isInstance(h, Patient)).to.be.false
            expect(Util.isInstance(o, Patient)).to.be.false
            expect(Util.isInstance(n, Patient)).to.be.false
            expect(Util.isInstance(u, Patient)).to.be.false

            expect(Util.isInstance(p, Object)).to.be.true
            expect(Util.isInstance(h, Object)).to.be.true
            expect(Util.isInstance(o, Object)).to.be.true
            expect(Util.isInstance(n, Object)).to.be.false
            expect(Util.isInstance(u, Object)).to.be.false


        describe 'in Titanium environment', ->

            before ->
                # creates Ti in global scope
                getGlobal = -> @
                getGlobal().Ti = {}
                expect(Ti).to.exist

            after ->
                getGlobal = -> @
                getGlobal().Ti = undefined
                expect(Ti).not.to.exist


            it 'also returns the same result as "instanceof" operator', ->
                F = ->
                f = new F
                expect(Util.isInstance(f, F)).to.be.true
                expect(Util.isInstance({}, F)).to.be.false

            it 'also returns the same result as "instanceof" operator, when class is given', ->

                class Human
                class Patient extends Human

                h = new Human
                p = new Patient
                o = {}
                n = null
                u = undefined

                expect(Util.isInstance(p, Human)).to.be.true
                expect(Util.isInstance(h, Human)).to.be.true
                expect(Util.isInstance(h, Human)).to.be.true
                expect(Util.isInstance(o, Human)).to.be.false
                expect(Util.isInstance(n, Human)).to.be.false
                expect(Util.isInstance(u, Human)).to.be.false

                expect(Util.isInstance(p, Patient)).to.be.true
                expect(Util.isInstance(h, Patient)).to.be.false
                expect(Util.isInstance(o, Patient)).to.be.false
                expect(Util.isInstance(n, Patient)).to.be.false
                expect(Util.isInstance(u, Patient)).to.be.false

                expect(Util.isInstance(p, Object)).to.be.true
                expect(Util.isInstance(h, Object)).to.be.true
                expect(Util.isInstance(o, Object)).to.be.true
                expect(Util.isInstance(n, Object)).to.be.false
                expect(Util.isInstance(u, Object)).to.be.false
