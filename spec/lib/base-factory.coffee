
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




    describe 'fetchEntityProp', ->

        before (done) ->

            class MemberRepository extends MasterRepository
                @modelName: 'member'
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

    describe 'createDic', ->

        before ->
            @DicFactory = Facade.DicFactory

        after ->
            Facade.DicFactory = @DicFactory


        it 'invoke DicFactory and call createFromObject() of it', (done) ->

            factory = facade.createFactory('diary')

            Facade.DicFactory = create: (dicModelName, itemFactory) ->
                expect(dicModelName).to.equal 'diary-dic'
                expect(itemFactory).to.equal factory

                return createFromObject: -> done()

            factory.createDic('obj')


        it 'use original dic model name', (done) ->
            DiaryFactory = facade.getFactory 'diary'

            DiaryFactory.dicModelName = 'abcd'

            factory = facade.createFactory('diary')

            Facade.DicFactory = create: (dicModelName, itemFactory) ->
                expect(dicModelName).to.equal 'abcd'
                expect(itemFactory).to.equal factory
                DiaryFactory.dicModelName = null

                return createFromObject: -> done()

            factory.createDic('obj')


