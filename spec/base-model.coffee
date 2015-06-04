
facade = require './init'

BaseModel = facade.constructor.BaseModel
BaseList  = facade.constructor.BaseList

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

    it 'is created with object', ->

        class Hospital extends BaseModel

            @getFacade: -> facade
            getFacade : -> facade

            @properties:
                name: @TYPES.STRING
                beds: @TYPES.NUMBER

        hospital = new Hospital(name: 'shinout clinic')

        expect(hospital).to.have.property 'name', 'shinout clinic'
        expect(hospital).not.to.have.property 'beds'
        expect(Object.keys(hospital)).to.contain 'beds'


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



    describe 'toPlainObject', ->

        it 'returns plain object without relational models (has many)', ->
            plainMember = member.toPlainObject()

            expect(plainMember.registeredAt).to.be.instanceof Date
            expect(plainMember.id).to.equal 12
            expect(plainMember.firstName).to.equal 'Shin'
            expect(plainMember.age).to.equal 29
            expect(plainMember.hobbies.ids).to.eql [1,2,3]

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


    describe 'setEntityProp', ->
        it 'set relation and its ids (has one / belongs to)', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            diary.setEntityProp('coauthor', member)

            expect(diary.coauthor).to.equal member
            expect(diary.coauthorId).to.equal 12



    describe 'unsetEntityProp', ->

        it 'unset relation and its id', ->

            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : member

            diary.unsetEntityProp('author')

            expect(diary.author).not.to.exist
            expect(diary.memberId).not.to.exist


    describe 'include', ->

        it 'includes all submodels', (done) ->
            mem = memberFactory.createFromObject
                id: 11
                hobbies: ids: [1,2,3]

            mem.include(recursive: true).then (model) ->
                expect(mem).to.equal model
                expect(mem).to.have.property('hobbies')
                expect(mem.hobbies).to.be.instanceof BaseList
                done()
            .catch (e) ->
                done e

