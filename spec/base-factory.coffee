
facade = require './init'

Hobby  = facade.getModel 'hobby'
Member = facade.getModel 'member'
Diary  = facade.getModel 'diary'
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
            expect(model.hobbies).to.be.instanceof Array
            expect(model.hobbies).to.have.length 3
            for hobby in model.hobbies
                expect(hobby).to.be.instanceof Hobby
                expect(hobby).to.have.property 'name'

                # testing "beforeCreateFromObject", "afterCreateModel"
                expect(hobby).to.have.property 'isUnique', true
                expect(hobby).to.have.property 'isAwesomeHobby', true


            expect(model.hobbyIds).to.have.length 3
            expect(model.hobbyIds).to.eql [1,2,3]

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


    describe 'fetchSubModel', ->

        before (done) ->

            class MemberRepository extends MasterRepository
                @modelName: 'member'
                getFacade: -> facade

            MemberRepository.load().then -> done()

            @originalCreateRepository = facade.createRepository

            facade.createRepository = (name) -> new MemberRepository()

        after ->
            facade.createRepository = @originalCreateRepository

        it 'set submodel by id', ->

            factory = facade.createFactory('diary')

            diary = new Diary()
            diary.memberId = 'dummy'

            typeInfo = Diary.getPropertyInfo 'author'

            factory.fetchSubModel(diary, 'author', typeInfo)

            expect(diary.author).to.be.instanceof Member
            expect(diary.author.id).to.equal 'dummy'


    describe 'fetchSubModel', -> # intentionally, appeared twice

        before (done) ->

            class HobbyRepository extends MasterRepository
                @modelName: 'hobby'
                getFacade: -> facade

            HobbyRepository.load().then -> done()

            @originalCreateRepository = facade.createRepository

            facade.createRepository = (name) -> new HobbyRepository()

        after ->
            facade.createRepository = @originalCreateRepository


        it 'set submodels by id', ->

            factory = facade.createFactory('member')

            member = new Member()
            member.newHobbyIds = ['dummy']

            typeInfo = Member.getPropertyInfo 'newHobbies'

            factory.fetchSubModel(member, 'newHobbies', typeInfo)

            expect(member.newHobbies).to.have.length 1
            expect(member.newHobbies[0]).to.be.instanceof Hobby

        it 'doesn\'t set submodels by id when there is aninvalid id in array', ->

            factory = facade.createFactory('member')

            member = new Member()
            member.newHobbyIds = ['dummy', 'xxx']

            typeInfo = Member.getPropertyInfo 'newHobbies'

            factory.fetchSubModel(member, 'newHobbies', typeInfo)

            expect(member.newHobbies).not.to.exist


