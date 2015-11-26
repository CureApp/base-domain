
facade = require('../create-facade').create('domain')
Facade = facade.constructor

Hobby  = facade.getModel 'hobby'
Member = facade.getModel 'member'
Diary  = facade.getModel 'diary'

{ BaseSyncRepository, BaseList, BaseDict } = facade.constructor

describe 'BaseFactory', ->


    describe 'getModelClass', ->
        factory = facade.createFactory('hobby')

        it 'returns model class', ->

            assert factory.getModelClass() is Hobby

        it 'returns guessed model class when no @modelName given', ->

            f = require('../create-facade').create()
            class Foo extends Facade.ValueObject
            class FooFactory extends Facade.BaseFactory
            f.addClass 'foo', Foo
            f.addClass 'foo-factory', FooFactory

            assert f.createFactory('foo').getModelClass() is f.getModel 'foo'



    describe 'createEmpty', ->

        it 'returns instance of model', ->
            factory = facade.createFactory('hobby')

            model = factory.createEmpty()
            assert model instanceof Hobby
            assert model.id is null


    describe 'createFromObject', ->

        it 'returns instance of model', ->
            factory = facade.createFactory('member')

            now = new Date()

            model = factory.createFromObject
                firstName: 'Shin'
                age: 28
                registeredAt: now
                hobbies: [
                    { id: 1, name: 'keyboard' }
                    { id: 2, name: 'ingress' }
                    { id: 3, name: 'Shogi' }
                ]

            assert model instanceof Member
            assert model.id is null
            assert model.firstName is 'Shin'
            assert model.registeredAt is now

            assert model.hobbies instanceof BaseList
            assert model.hobbies.items instanceof Array
            assert model.hobbies.items.length is 3

            for hobby in model.hobbies.items
                assert hobby instanceof Hobby
                assert hobby.name?


        it 'returns instance of model with relational model', ->

            mFactory = facade.createFactory('member')

            member = mFactory.createFromObject
                id: '12'
                firstName: 'Shin'
                age: 29
                registeredAt: new Date()
                hobbies: [
                    { id: 1, name: 'keyboard' }
                    { id: 2, name: 'ingress' }
                    { id: 3, name: 'Shogi' }
                ]

            dFactory = facade.createFactory('diary')

            diary = dFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                author: member
                date  : new Date()

            assert diary.memberId.toString() is '12' # not authorId


        it 'creates empty list', ->

            mFactory = facade.createFactory('member')

            member = mFactory.createFromObject
                firstName: 'Shin'

            assert member.hobbies instanceof Facade.BaseList


        it 'does not create sub-model when key is given null', ->

            f = require('../create-facade').create()

            class Foo extends Facade.BaseModel
                @properties:
                    bar: @TYPES.MODEL 'bar'
            f.addClass 'foo', Foo

            class Bar extends Facade.ValueObject
            f.addClass 'bar', Bar
            class FooFactory extends Facade.BaseFactory
            f.addClass 'foo-factory', FooFactory

            foo = f.createFactory('foo').createFromObject
                bar: null

            assert foo.bar is null


        it 'does not create sub-dict when key is given null', ->

            f = require('../create-facade').create()

            class Foo extends Facade.BaseModel
                @properties:
                    bars: @TYPES.MODEL 'bar-dict'
            f.addClass 'foo', Foo

            class Bar extends Facade.ValueObject
            f.addClass 'bar', Bar
            class BarDict extends Facade.BaseDict
                @itemModelName: 'bar'
            f.addClass 'bar-dict', BarDict

            class FooFactory extends Facade.BaseFactory
            f.addClass 'foo-factory', FooFactory

            foo = f.createFactory('foo').createFromObject
                bars: null

            assert foo.bars is null



        it 'does not create sub-list when key is given null', ->

            mFactory = facade.createFactory('member')
            member = mFactory.createFromObject
                firstName: 'Shin'
                hobbies: null

            assert not member.hobbies?


    describe 'createList', ->

        it 'creates list', ->

            class SuperDiaryList extends BaseList
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'diary'

            facade.addClass 'super-diary-list', SuperDiaryList

            factory = facade.createFactory('diary')

            list = factory.createList('super-diary-list', {})
            assert list instanceof facade.getModel('super-diary-list')


    describe 'createDict', ->

        it 'creates dict', ->

            class SuperDiaryDict extends BaseDict
                @getFacade: -> facade
                getFacade:  -> facade
                @itemModelName: 'diary'

            facade.addClass 'super-diary-dict', SuperDiaryDict

            factory = facade.createFactory('diary')

            dict = factory.createDict('super-diary-dict', {})
            assert dict instanceof facade.getModel('super-diary-dict')

