
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

        assert not hospital.beds?


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


    it 'can define enum and can get the map', ->

        f = require('../create-facade').create()

        class Hospital extends Entity
            @properties:
                name: @TYPES.STRING
                state: @TYPES.ENUM ['AVAILABLE', 'UNAVAILABLE']

        f.addClass 'hospital', Hospital

        hospital = new Hospital(id: 123, state: 'UNAVAILABLE', f)

        assert hospital.state is hospital.enum('state').UNAVAILABLE


    describe 'when invalid ENUM value is passed', ->

        before ->
            @console_error = console.error
        after ->
            console.error = @console_error

        it 'shows warning message via console.error', (done) ->

            console.error = (msg) ->
                assert(msg.match /Invalid value is passed/)
                done()

            f = require('../create-facade').create()

            class Hospital extends Entity
                @properties:
                    state: @TYPES.ENUM ['AVAILABLE', 'UNAVAILABLE']

            f.addClass 'hospital', Hospital

            hospital = new Hospital(id: 123, state: 'ABCDE', f)



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
            assert not ParentClass.properties.prop2?



    describe 'toPlainObject', ->

        it 'returns plain object without relational models (has many)', ->

            plainMember = @member.toPlainObject()

            assert plainMember.registeredAt instanceof Date
            assert plainMember.id is 12
            assert plainMember.firstName is 'Shin'
            assert plainMember.age is 29
            assert.deepEqual plainMember.hobbies.ids, [1,2,3]



        it 'returns plain object without relational models (has one / belongs to)', ->

            diary = @facade.createModel 'diary',
                title   : 'crazy about room335'
                comment : 'progression of room335 is wonderful'
                author  : @member
                date    : new Date()

            plainDiary = diary.toPlainObject()

            assert plainDiary.title is diary.title
            assert plainDiary.comment is diary.comment
            assert.deepEqual plainDiary.date, diary.date
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

            assert medicine.name is 'hoge'
            assert medicine.abc is 'yeah'
            assert medicine.obj?

            plain = medicine.toPlainObject()

            assert plain.name is 'hoge'
            assert not plain.abc?
            assert not plain.obj?



    describe 'set', ->

        it 'set relation and its ids (has one / belongs to) when entity prop is given', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            diary.set('coauthor', @member)

            assert diary.coauthor is @member
            assert diary.coauthorId is 12



    describe 'unset', ->

        it 'unset relation and its id when entity prop is given', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : @member

            diary.unset('author')

            assert not diary.author?
            assert not diary.memberId?


    describe 'include', ->

        it 'includes all submodels', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [1,2,3]

            mem.include(recursive: true).then (model) ->
                assert mem is model
                assert mem.hobbies
                assert mem.hobbies instanceof BaseList


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

            assert a.a is a.a.a.a.a
            assert a.a.a is a.a.a.a.a.a
            assert a.a.a.a is a.a.a.a.a.a.a


    describe 'inherit', ->

        it 'overrides values', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [1,2,3]
                age: 30

            mem.inherit(foo: 0, bar: 'bar', age: 29, hobbies: null)

            assert mem.foo is 0
            assert mem.bar is 'bar'
            assert mem.age is 29
            assert mem.hobbies?


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

            assert diary.memberId is '123'
            assert not diary.author?


    describe 'clone', ->

        it 'copies the model', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [1,2,3]
                age: 30

            diary = @facade.createModel 'diary',
                id: '2015/1/12'
                comment: 'sample'
                author: mem

            diary2 = diary.clone()

            assert.deepEqual diary, diary2
            assert diary2 instanceof @facade.getModel 'diary'
            assert diary2.author instanceof @facade.getModel 'member'
            assert diary2.author isnt mem

