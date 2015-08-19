
facade = require('../create-facade').create('domain')

{ ValueObject, BaseModel, Entity, BaseList } = facade.constructor

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

        expect(p.type).to.equal 123



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



    describe 'inherit', ->

        beforeEach ->

            @f = require('../create-facade').create()

            class Patient extends Entity
                @properties:
                    name       : @TYPES.STRING
                    hospital   : @TYPES.MODEL 'hospital'
                    medication : @TYPES.MODEL 'medication'

            class Hospital extends Entity
                @properties:
                    name: @TYPES.STRING

            class Medication extends ValueObject
                @properties:
                    name: @TYPES.STRING

            @f.addClass 'patient', Patient
            @f.addClass 'hospital', Hospital
            @f.addClass 'medication', Medication

            @pFactory = @f.createFactory('patient', true)
            @hFactory = @f.createFactory('hospital', true)
            @mFactory = @f.createFactory('medication', true)

            @tokyoHp = @hFactory.createFromObject(id: 'tokyo', name: 'Tokyo Hp.')
            @osakaHp = @hFactory.createFromObject(id: 'osaka', name: 'Osaka Hp.')

            @medicationD = @mFactory.createFromObject(name: 'vitamin D')
            @medicationE = @mFactory.createFromObject(name: 'vitamin E')

            @patient = @pFactory.createFromObject
                name: 'Shin Suzuki'
                hospital: @tokyoHp
                medication: @medicationD

            @yokoyama = @pFactory.createFromObject
                name: 'Ken Yokoyama'
                hospital: @osakaHp
                medication: @medicationE


        it 'changes no properties when null is given', ->

            ret = @patient.inherit(null)

            expect(ret).to.equal @patient

            expect(@patient.name).to.equal 'Shin Suzuki'

            expect(@patient.hospital).to.equal @tokyoHp
            expect(@patient.hospital.id).to.equal 'tokyo'
            expect(@patient.hospital.name).to.equal 'Tokyo Hp.'
            expect(@patient.hospitalId).to.equal 'tokyo'

            expect(@patient.medication).to.equal @medicationD
            expect(@patient.medication.name).to.equal 'vitamin D'


        it 'changes no properties when non-base-model object is given', ->

            ret = @patient.inherit(name: 'Ken Yokoyama')

            expect(ret).to.equal @patient

            expect(@patient.name).to.equal 'Shin Suzuki'



        it 'changes properties of non-model prop', ->

            ret = @patient.inherit(@yokoyama)
            expect(ret).to.equal @patient

            expect(@patient.name).to.equal 'Ken Yokoyama'


        it 'changes properties of entity prop, overwriting when foreign id is different', ->

            ret = @patient.inherit(@yokoyama)
            expect(ret).to.equal @patient

            expect(@patient.hospital).to.equal @osakaHp
            expect(@patient.hospital).to.not.equal @tokyoHp
            expect(@patient.hospital.id).to.equal 'osaka'
            expect(@patient.hospital.name).to.equal 'Osaka Hp.'
            expect(@patient.hospitalId).to.equal 'osaka'


        it 'changes properties of entity prop, inheriting the existing instance when foreign id is same', ->

            @osakaHp.id = 'tokyo'

            @yokoyama.set 'hospital', @osakaHp

            ret = @patient.inherit(@yokoyama)
            expect(ret).to.equal @patient

            expect(@patient.hospital).to.not.equal @osakaHp
            expect(@patient.hospital).to.equal @tokyoHp
            expect(@patient.hospital.id).to.equal 'tokyo'
            expect(@patient.hospital.name).to.equal 'Osaka Hp.'
            expect(@patient.hospitalId).to.equal 'tokyo'


        it 'set properties of entity prop to null when foreign id is different and new foreign model is not given', ->

            delete @yokoyama.hospital

            ret = @patient.inherit(@yokoyama)
            expect(ret).to.equal @patient

            expect(@patient.hospital).to.not.exist
            expect(@patient.hospitalId).to.equal 'osaka'


        it 'does not remove properties of entity prop when foreign id is same and new foreign model is not given', ->

            delete @yokoyama.hospital
            @yokoyama.hospitalId = 'tokyo'

            ret = @patient.inherit(@yokoyama)
            expect(ret).to.equal @patient

            expect(@patient.hospital).to.equal @tokyoHp
            expect(@patient.hospital.id).to.equal 'tokyo'
            expect(@patient.hospital.name).to.equal 'Tokyo Hp.'
            expect(@patient.hospitalId).to.equal 'tokyo'


        it 'changes properties of non-entity prop, setting the existing instance to the new values', ->

            ret = @patient.inherit(@yokoyama)
            expect(ret).to.equal @patient

            expect(@patient.medication).to.not.equal @medicationE
            expect(@patient.medication).to.equal @medicationD
            expect(@patient.medication.name).to.equal 'vitamin E'


