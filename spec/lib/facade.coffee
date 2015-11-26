
Facade = require('../base-domain')

describe 'Facade', ->


    describe '@createInstance', ->

        it 'returns instance of Facade', ->
            f = Facade.createInstance()
            assert f instanceof Facade


        it 'returns instance of extended class', ->
            class ChildFacade extends Facade

            f = ChildFacade.createInstance()
            assert f instanceof Facade
            assert f instanceof ChildFacade


    describe 'addClass', ->

        it 'registers the given class, adding "className" property to the class', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true

            f.addClass('hobby', Hobby)

            assert Hobby.className is 'hobby'

            FaHobby = f.getModel('hobby')

            assert FaHobby is Hobby
            assert f.classes.hobby is Hobby


        it 'add new "className" property to the class whose parent class already has "className"', ->

            f = Facade.createInstance()
            class Hobby extends Facade.Entity
                @abc: true
            f.addClass('hobby', Hobby)

            class ChildHobby extends Hobby
                @abc: true
            f.addClass('child-hobby', ChildHobby)

            assert Hobby.className is 'hobby'
            assert ChildHobby.className is 'child-hobby'

            FaHobby = f.getModel('hobby')
            assert FaHobby is Hobby
            assert f.classes.hobby is Hobby

            FaChildHobby = f.getModel('child-hobby')
            assert FaChildHobby is ChildHobby
            assert f.classes['child-hobby'] is ChildHobby



    describe 'hasClass', ->

        it 'returns false if a class with the given name is not found', ->

            f = Facade.createInstance()
            assert f.hasClass('hobby') is false

        it 'returns true if a class with the given name is found', ->
            f = Facade.createInstance()
            class Hobby extends Facade.BaseModel
            f.addClass('hobby', Hobby)
            assert f.hasClass('hobby')


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
            assert factory.constructor.xxx is 'yyy'

        it 'throws error when no specific factory is found', ->

            class Abc extends Facade.ValueObject

            f = Facade.createInstance()
            f.addClass('abc', Abc)
            expect(-> f.createFactory('abc')).to.throw Error



    describe 'error', ->

        it 'throw DomainError with reason', ->

            f = Facade.createInstance()
            err = f.error('notANumber')

            assert err.reason is 'notANumber'
            assert f.isDomainError(err)
