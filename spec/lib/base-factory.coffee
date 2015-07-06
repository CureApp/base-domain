
facade = require('../create-facade').create('domain')
Facade = facade.constructor

Hobby  = facade.getModel 'hobby'
Member = facade.getModel 'member'
Diary  = facade.getModel 'diary'
BaseList = facade.constructor.BaseList
MasterRepository = facade.constructor.MasterRepository

describe 'BaseFactory', ->


    describe 'getModelClass', ->
        factory = facade.createFactory('hobby')

        it 'returns model class', ->

            expect(factory.getModelClass()).to.equal Hobby

        it 'returns guessed model class when no @modelName given', ->

            f = require('../create-facade').create()
            class Foo extends Facade.ValueObject
            class FooFactory extends Facade.BaseFactory
            f.addClass 'foo', Foo
            f.addClass 'foo-factory', FooFactory

            expect(f.createFactory('foo').getModelClass()).to.equal f.getModel 'foo'



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
                    { id: 1, name: 'keyboard' }
                    { id: 2, name: 'ingress' }
                    { id: 3, name: 'Shogi' }
                ]

            expect(model).to.be.instanceof Member
            expect(model).to.have.property 'id', null
            expect(model).to.have.property 'firstName', 'Shin'
            expect(model).to.have.property 'registeredAt', now

            expect(model.hobbies).to.be.instanceof BaseList
            expect(model.hobbies.items).to.be.instanceof Array
            expect(model.hobbies.items).to.have.length 3

            for hobby in model.hobbies.items
                expect(hobby).to.be.instanceof Hobby
                expect(hobby).to.have.property 'name'

                # testing "beforeCreateFromObject", "afterCreateModel"
                expect(hobby).to.have.property 'isUnique', true
                expect(hobby).to.have.property 'isAwesomeHobby', true


        it 'returns instance of model with relational model', ->

            mFactory = facade.createFactory('member')

            member = mFactory.createFromObject
                id: 12
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

            expect(diary).to.have.property 'memberId', 12 # not "authorId"


        it 'creates empty list', ->

            mFactory = facade.createFactory('member')

            member = mFactory.createFromObject
                firstName: 'Shin'

            expect(member.hobbies).to.be.instanceof Facade.BaseList


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

            expect(foo.bar).to.equal null


        it 'does not create sub-dict when key is given null', ->

            f = require('../create-facade').create()

            class Foo extends Facade.BaseModel
                @properties:
                    bars: @TYPES.MODEL_DICT 'bar'
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

            expect(foo.bars).to.equal null



        it 'does not create sub-list when key is given null', ->

            mFactory = facade.createFactory('member')
            member = mFactory.createFromObject
                firstName: 'Shin'
                hobbies: null

            expect(member.hobbies).not.to.exist





    describe 'fetchEntityProp', ->

        before (done) ->

            class MemberRepository extends MasterRepository
                getFacade: -> facade

            MemberRepository.load().then -> done()

            @originalGetRepository = facade.getRepository

            facade.getRepository = (name) -> MemberRepository

        after ->
            facade.getRepository = @originalCreateRepository

        it 'set submodel by id', ->

            factory = facade.createFactory('diary')

            diary = new Diary()
            diary.memberId = 'dummy'

            factory.fetchEntityProp(diary, 'author', diary.getTypeInfo('author'))

            expect(diary.author).to.be.instanceof Member
            expect(diary.author.id).to.equal 'dummy'


    describe 'createDict', ->

        before ->
            @DictFactory = Facade.DictFactory

        after ->
            Facade.DictFactory = @DictFactory


        it 'invoke DictFactory and call createFromObject() of it', (done) ->

            factory = facade.createFactory('diary')

            Facade.DictFactory = create: (dictModelName, itemFactory) ->
                expect(dictModelName).to.equal 'super-diary-dict'
                expect(itemFactory).to.equal factory

                return createFromObject: -> done()

            factory.createDict('super-diary-dict', {})



    describe 'createList', ->

        before ->
            @ListFactory = Facade.ListFactory

        after ->
            Facade.ListFactory = @ListFactory


        it 'invoke ListFactory and call createFromObject() of it', (done) ->

            factory = facade.createFactory('diary')

            Facade.ListFactory = create: (listModelName, itemFactory) ->
                expect(listModelName).to.equal 'super-diary-list'
                expect(itemFactory).to.equal factory

                return createFromObject: -> done()

            factory.createList('super-diary-list', {})

