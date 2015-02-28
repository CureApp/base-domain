
facade = require './init'

Hobby  = facade.getModel 'hobby'
Member = facade.getModel 'member'

describe 'BaseFactory', ->


    describe 'getModelClass', ->
        factory = facade.createFactory('hobby')

        it 'returns model class', ->

            expect(factory.getModelClass()).to.equal Hobby



    describe 'createEmptyModel', ->

        it 'returns instance of model', ->
            factory = facade.createFactory('hobby')

            model = factory.createEmptyModel()
            expect(model).to.be.instanceof Hobby
            expect(model).to.have.property 'id', null


    describe 'createFromObject', ->

        it 'returns instance of model', ->
            factory = facade.createFactory('member')

            now = new Date()

            model = factory.createFromObject
                firstName: 'Shin'
                age: 28
                registeredAt: now
                hobbies: [
                    { name: 'keyboard' }
                    { name: 'ingress' }
                    { name: 'Shogi' }
                ]

            expect(model).to.be.instanceof Member
            expect(model).to.have.property 'id', null
            expect(model).to.have.property 'firstName', 'Shin'
            expect(model).to.have.property 'registeredAt', now
            expect(model.hobbies).to.be.instanceof Array
            expect(model.hobbies).to.have.length 3
            for hobby in model.hobbies
                expect(hobby).to.be.instanceof Hobby
                expect(hobby).to.have.property 'name'


