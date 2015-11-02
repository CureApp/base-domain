
Facade = require('../base-domain')

describe 'Facade', ->


    describe '@createInstance', ->

        it 'returns instance of Facade', ->
            f = Facade.createInstance()
            expect(f).to.be.instanceof Facade


        it 'returns instance of extended class', ->
            class ChildFacade extends Facade

            f = ChildFacade.createInstance()
            expect(f).to.be.instanceof Facade
            expect(f).to.be.instanceof ChildFacade


    describe 'addClass', ->

        it 'registers the given class, adding "className" property to the class', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true

            f.addClass('hobby', Hobby)

            expect(Hobby.className).to.equal 'hobby'

            FaHobby = f.getModel('hobby')

            expect(FaHobby).to.equal Hobby
            expect(f.classes.hobby).to.equal Hobby


        it 'add new "className" property to the class whose parent class already has "className"', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true
            f.addClass('hobby', Hobby)

            class ChildHobby extends Hobby
                @abc: true
            f.addClass('child-hobby', ChildHobby)

            expect(Hobby.className).to.equal 'hobby'
            expect(ChildHobby.className).to.equal 'child-hobby'

            FaHobby = f.getModel('hobby')
            expect(FaHobby).to.equal Hobby
            expect(f.classes.hobby).to.equal Hobby

            FaChildHobby = f.getModel('child-hobby')
            expect(FaChildHobby).to.equal ChildHobby
            expect(f.classes['child-hobby']).to.equal ChildHobby



    describe 'hasClass', ->

        it 'returns false if a class with the given name is not found', ->

            f = Facade.createInstance()
            expect(f.hasClass('hobby')).to.be.false

        it 'returns true if a class with the given name is found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.BaseModel
            f.addClass('hobby', Hobby)
            expect(f.hasClass('hobby')).to.be.true


    describe 'createFactory', ->

        it 'returns an instance of registered Factory', ->

            class Abc extends Facade.ValueObject

            class AbcFactory extends Facade.BaseFactory
                @modelName: 'abc'
                @xxx: 'yyy'

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            f.addClass('abc-factory', AbcFactory)
            factory = f.createFactory('abc')
            expect(factory.constructor.xxx).to.equal 'yyy'

        it 'throws error when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            expect(-> f.createFactory('abc')).to.throw Error



    describe 'error', ->

        it 'throw DomainError with reason', ->

            f = Facade.createInstance()
            err = f.error('notANumber')

            expect(err).to.have.property 'reason', 'notANumber'
            expect(f.isDomainError(err)).to.be.true
