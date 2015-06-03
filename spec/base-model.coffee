
facade = require './init'

BaseModel = facade.constructor.BaseModel

Diary  = facade.getModel 'diary'
Member = facade.getModel 'member'
Hobby  = facade.getModel 'hobby'
memberFactory = facade.createFactory('member')
diaryFactory = facade.createFactory('diary')
hobbyFactory = facade.createFactory('hobby')


member = memberFactory.createFromObject
    id: 12
    firstName: 'Shin'
    age: 29
    registeredAt: new Date()
    hobbies: [
        { id: 1, name: 'keyboard' }
        { id: 2, name: 'ingress' }
        { id: 3, name: 'Shogi' }
    ]



describe 'BaseModel', ->


    describe '@withParentProp', ->

        it 'extends parent\'s properties', ->

            class ParentClass extends BaseModel
                @properties:
                    prop1: @TYPES.STRING

            class ChildClass extends ParentClass

                @properties: @withParentProps
                    prop2: @TYPES.NUMBER

            expect(ChildClass.properties).to.have.property 'prop1', BaseModel.TYPES.STRING
            expect(ChildClass.properties).to.have.property 'prop2', BaseModel.TYPES.NUMBER

            expect(ParentClass.properties).to.have.property 'prop1', BaseModel.TYPES.STRING
            expect(ParentClass.properties).not.to.have.property 'prop2'


    describe 'isSubClassOfEntity', ->
        it 'returns true to descendant of Entity', ->
            hobby = new Hobby()
            expect(hobby.isSubClassOfEntity('hobby')).to.be.true


        xit 'returns false to descendant of BaseModel', ->
            hobby = new Hobby()
            expect(hobby.isSubClassOfEntity('xxxxx')).to.be.false



    describe 'toPlainObject', ->

        it 'returns plain object without relational models (has many)', ->
            plainMember = member.toPlainObject()

            expect(plainMember.registeredAt).to.be.instanceof Date
            expect(plainMember.id).to.equal 12
            expect(plainMember.firstName).to.equal 'Shin'
            expect(plainMember.age).to.equal 29
            expect(plainMember.hobbies).not.to.exist
            expect(plainMember.hobbyIds).to.eql [1,2,3]

        it 'returns plain object without relational models (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                author: member
                date  : new Date()

            plainDiary = diary.toPlainObject()

            expect(plainDiary.title).to.equal diary.title
            expect(plainDiary.comment).to.equal diary.comment
            expect(plainDiary.date).to.eql diary.date
            expect(plainDiary.author).not.to.exist
            expect(plainDiary.authorId).not.to.exist
            expect(plainDiary.memberId).to.equal 12


    describe 'updateRelationIds', ->
        it 'adds relation ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                author: member
                date  : new Date()

            delete diary.memberId

            expect(diary.memberId).not.to.exist
            diary.updateRelationIds()

            expect(diary.memberId).to.equal 12


        it 'adds relation ids (has many)', ->
            delete member.hobbyIds

            expect(member.hobbyIds).not.to.exist
            member.updateRelationIds()

            expect(member.hobbyIds).to.eql [1,2,3]


    describe 'setRelatedModel(s)', ->
        it 'set relation and its ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            diary.setRelatedModel('coauthor', member)

            expect(diary.coauthor).to.equal member
            expect(diary.coauthorId).to.equal 12

        it 'set relation and its ids (has many)', ->
            mem = memberFactory.createEmptyModel()
            mem.setRelatedModels 'hobbies', member.hobbies

            expect(mem.hobbies).to.equal member.hobbies
            expect(mem.hobbyIds).to.eql [1,2,3]



    describe 'unsetRelatedModel(s)', ->
        it 'unset relation and its ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : member

            diary.unsetRelatedModel('author')

            expect(diary.author).not.to.exist
            expect(diary.memberId).not.to.exist

        it 'unset relation and its ids (has many)', ->
            mem = memberFactory.createEmptyModel()
            mem.setRelatedModels 'hobbies', member.hobbies

            mem.unsetRelatedModels 'hobbies'
            expect(mem.hobbies).not.to.exist
            expect(mem.hobbyIds).to.eql []


    describe 'addRelatedModels', ->
        it 'add submodels and its ids (has many)', ->
            mem = memberFactory.createEmptyModel()

            newHobby1 = hobbyFactory.createFromObject { id: 4, name: 'sailing' }
            newHobby2 = hobbyFactory.createFromObject { id: 5, name: 'shopping' }

            mem.addRelatedModels 'newHobbies', newHobby1, newHobby2
            expect(mem.newHobbies[0]).to.equal newHobby1
            expect(mem.newHobbies[1]).to.equal newHobby2
            expect(mem.newHobbyIds).to.eql [4,5]

    describe 'include', ->

        it 'includes all submodels', (done) ->
            mem = memberFactory.createFromObject
                id: 11
                hobbyIds: [1,2,3]

            mem.include(recursive: true).then (model) ->
                expect(mem).to.equal model
                expect(mem).to.have.property('hobbies')
                expect(mem.hobbies[0]).to.be.instanceof Hobby
                done()
            .catch (e) ->
                done e

