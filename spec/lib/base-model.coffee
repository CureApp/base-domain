
facade = require('../create-facade').create('domain')

{ BaseModel, Entity, BaseList, Id } = facade.constructor

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


    it 'can define sub entity with idPropName', ->

        f = require('../create-facade').create()

        class Hospital extends Entity
            @properties:
                name: @TYPES.STRING
        f.addClass 'hospital', Hospital

        class Patient extends BaseModel
            @properties:
                hospital: @TYPES.MODEL 'hospital', 'type'
        f.addClass 'patient', Patient

        Patient  = f.getModel('patient')
        Hospital = f.getModel('hospital')

        p = new Patient()
        h = new Hospital(id: 123)
        p.set 'hospital', h

        expect(p.type).to.be.instanceof Id
        expect(p.type.equals 123).to.be.true



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
            expect(plainMember.id).to.equal '12'
            expect(plainMember.firstName).to.equal 'Shin'
            expect(plainMember.age).to.equal 29
            expect(plainMember.hobbies.ids).to.eql ['1','2','3']

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
            expect(plainDiary.memberId).to.equal '12'

        it 'returns plain object without tmp values', ->

            class Medicine extends BaseModel
                @properties:
                    name: @TYPES.STRING
                    abc : @TYPES.TMP
                    obj : @TYPES.TMP 'OBJECT'

                getFacade: -> facade
                @getFacade: -> facade

            medicine = new Medicine(name: 'hoge', abc: 'yeah', obj: key: 'value')

            expect(medicine).to.have.property 'name', 'hoge'
            expect(medicine).to.have.property 'abc', 'yeah'
            expect(medicine).to.have.property 'obj'

            plain = medicine.toPlainObject()

            expect(plain).to.have.property 'name', 'hoge'
            expect(plain).not.to.have.property 'abc'
            expect(plain).not.to.have.property 'obj'



    describe 'set', ->

        it 'set relation and its ids (has one / belongs to) when entity prop is given', ->
            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            diary.set('coauthor', member)

            expect(diary.coauthor).to.equal member
            expect(diary.coauthorId).to.be.instanceof Id
            expect(diary.coauthorId.equals '12').to.be.true



    describe 'unset', ->

        it 'unset relation and its id when entity prop is given', ->

            diary = diaryFactory.createFromObject
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : member

            diary.unset('author')

            expect(diary.author).not.to.exist
            expect(diary.memberId).not.to.exist


    describe 'include', ->

        it 'includes all submodels', (done) ->

            mem = memberFactory.createFromObject
                id: 11
                hobbies: [1,2,3]

            mem.include(recursive: true).then (model) ->
                expect(mem).to.equal model
                expect(mem).to.have.property('hobbies')
                expect(mem.hobbies).to.be.instanceof BaseList
                done()
            .catch (e) ->
                done e


    describe 'inherit', ->

        it 'overrides values', ->

            mem = memberFactory.createFromObject
                id: 11
                hobbies: [1,2,3]
                age: 30

            mem.inherit(foo: 0, bar: 'bar', age: 29, hobbies: null)

            expect(mem).to.have.property 'foo', 0
            expect(mem).to.have.property 'bar', 'bar'
            expect(mem).to.have.property 'age', 29
            expect(mem.hobbies).to.exist


        it 'overrides values', ->

            mem = facade.createModel 'member',
                id: 'shin'
                hobbies: [1,2,3]
                age: 30

            diary = facade.createModel 'diary',
                id: '2015/1/12'
                comment: 'sample'
                author: mem

            diary.inherit(memberId: '123')

            expect(diary.memberId).to.be.instanceof Id
            expect(diary.memberId.equals '123').to.be.true
            expect(diary.author).to.not.exist


