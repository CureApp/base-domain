
{ BaseModel, Entity, BaseList, BaseSyncRepository } = Facade = require('../base-domain')

describe 'BaseModel', ->

    beforeEach ->

        @facade = require('../create-facade').create('domain')

        @member = @facade.createModel 'member',
            id: 12
            firstName: 'Shin'
            age: 29
            registeredAt: new Date()
            hobbies: [
                { id: 1, name: 'keyboard' }
                { id: 2, name: 'ingress' }
                { id: 3, name: 'Shogi' }
            ]


    it 'is constructed with object and root(facade)', ->

        facade = require('../create-facade').create()

        class Hospital extends BaseModel

            @properties:
                name: @TYPES.STRING
                beds: @TYPES.NUMBER

        facade.addClass('hospital', Hospital)

        hospital = new Hospital(name: 'shinout clinic', facade)

        assert hospital.name is 'shinout clinic'
        assert hospital.root is facade

        expect(hospital).not.to.have.property 'beds'


    it 'can define sub entity with idPropName', ->

        f = require('../create-facade').create()

        class Hospital extends Entity
            @properties:
                name: @TYPES.STRING

        f.addClass 'hospital', Hospital

        class Patient extends BaseModel
            @properties:
                hospital: @TYPES.MODEL 'hospital', 'hospital-id'

        f.addClass 'patient', Patient

        patient  = new Patient(null, f)
        hospital = new Hospital(id: 123, f)
        patient.set 'hospital', hospital

        assert patient['hospital-id'] is 123



    describe '@withParentProp', ->

        it 'extends parent\'s properties', ->

            class ParentClass extends BaseModel
                @properties:
                    prop1: @TYPES.STRING

            class ChildClass extends ParentClass

                @properties: @withParentProps
                    prop2: @TYPES.NUMBER

            assert ChildClass.properties.prop1 is BaseModel.TYPES.STRING
            assert ChildClass.properties.prop2 is BaseModel.TYPES.NUMBER

            assert ParentClass.properties.prop1 is BaseModel.TYPES.STRING
            expect(ParentClass.properties).not.to.have.property 'prop2'



    describe 'toPlainObject', ->

        it 'returns plain object without relational models (has many)', ->

            plainMember = @member.toPlainObject()

            assert plainMember.registeredAt instanceof Date
            assert plainMember.id is 12
            assert plainMember.firstName is 'Shin'
            assert plainMember.age is 29
            expect(plainMember.hobbies.ids).to.eql [1,2,3]



        it 'returns plain object without relational models (has one / belongs to)', ->

            diary = @facade.createModel 'diary',
                title   : 'crazy about room335'
                comment : 'progression of room335 is wonderful'
                author  : @member
                date    : new Date()

            plainDiary = diary.toPlainObject()

            assert plainDiary.title is diary.title
            assert plainDiary.comment is diary.comment
            expect(plainDiary.date).to.eql diary.date
            assert not plainDiary.author?
            assert not plainDiary.authorId?
            assert plainDiary.memberId is 12


        it 'returns plain object without "omit" options', ->

            class Medicine extends BaseModel
                @className: 'medicine'
                @properties:
                    name: @TYPES.STRING
                    abc : @TYPES.STRING default: 'abd', omit: true
                    obj : @TYPES.OBJECT omit: true

            medicine = new Medicine({ name: 'hoge', abc: 'yeah', obj: key: 'value' }, @facade)

            expect(medicine).to.have.property 'name', 'hoge'
            expect(medicine).to.have.property 'abc', 'yeah'
            expect(medicine).to.have.property 'obj'

            plain = medicine.toPlainObject()

            expect(plain).to.have.property 'name', 'hoge'
            expect(plain).not.to.have.property 'abc'
            expect(plain).not.to.have.property 'obj'



    describe 'set', ->

        it 'set relation and its ids (has one / belongs to) when entity prop is given', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            diary.set('coauthor', @member)

            expect(diary.coauthor).to.equal @member
            expect(diary.coauthorId).to.equal 12



    describe 'unset', ->

        it 'unset relation and its id when entity prop is given', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : @member

            diary.unset('author')

            expect(diary.author).not.to.exist
            expect(diary.memberId).not.to.exist


    describe 'include', ->

        it 'includes all submodels', (done) ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [1,2,3]

            mem.include(recursive: true).then (model) ->
                expect(mem).to.equal model
                expect(mem).to.have.property('hobbies')
                expect(mem.hobbies).to.be.instanceof BaseList
                done()
            .catch (e) ->
                done e


    describe 'include', ->

        before ->
            { MemoryResource } = require '../others'

            class A extends Entity
                @properties:
                    name: @TYPES.STRING
                    a: @TYPES.MODEL 'a'

            class ARepository extends BaseSyncRepository
                @modelName: 'a'
                client: new MemoryResource()

            @f = require('../create-facade').create()

            @f.addClass 'a', A
            @f.addClass 'a-repository', ARepository

            @f.createRepository('a').save(id: '1', name: 'a1', aId: '2')
            @f.createRepository('a').save(id: '2', name: 'a2', aId: '3')
            @f.createRepository('a').save(id: '3', name: 'a3', aId: '1')


        it 'can load models recursively with circular references', ->

            a = @f.createModel('a', { name: 'main', aId: '1' }, { include: recursive: true })

            expect(a.a).to.equal a.a.a.a.a
            expect(a.a.a).to.equal a.a.a.a.a.a
            expect(a.a.a.a).to.equal a.a.a.a.a.a.a


    describe 'inherit', ->

        it 'overrides values', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [1,2,3]
                age: 30

            mem.inherit(foo: 0, bar: 'bar', age: 29, hobbies: null)

            expect(mem).to.have.property 'foo', 0
            expect(mem).to.have.property 'bar', 'bar'
            expect(mem).to.have.property 'age', 29
            expect(mem.hobbies).to.exist


        it 'overrides values', ->

            mem = @facade.createModel 'member',
                id: 'shin'
                hobbies: [1,2,3]
                age: 30

            diary = @facade.createModel 'diary',
                id: '2015/1/12'
                comment: 'sample'
                author: mem

            diary.inherit(memberId: '123')

            expect(diary.memberId).to.equal '123'
            expect(diary.author).to.not.exist



