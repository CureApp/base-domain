
{ BaseModel, Entity, BaseList, BaseSyncRepository, BaseAsyncRepository } = Facade = require('../base-domain')

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
        assert hospital.state is Hospital.enum('state').UNAVAILABLE


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


    describe '$set', ->

        it 'set props and create new model', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            newDiary = diary.$set('coauthor', @member)

            assert newDiary.coauthor is @member
            assert newDiary.coauthorId is 12
            assert not diary.coauthor?

        it 'set props and create new model when object is given', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()

            newDiary = diary.$set(coauthor: @member)

            assert newDiary.coauthor is @member
            assert newDiary.coauthorId is 12
            assert not diary.coauthor?



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


    describe '$unset', ->

        it 'unset props and submodel\'s id, and create a new model', ->

            diary = @facade.createModel 'diary',
                title : 'crazy about room335'
                comment: 'progression of room335 is wonderful'
                date  : new Date()
                author : @member

            newDiary = diary.$unset('author')

            assert not newDiary.author?
            assert not newDiary.memberId?

            assert diary.author?
            assert diary.memberId?

    describe 'include', ->

        it 'includes all submodels', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [1,2,3]

            mem.include().then (model) ->
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

            repo = @f.createRepository('a')

            repo.save(id: '1', name: 'a1', aId: '2')
            repo.save(id: '2', name: 'a2', aId: '3')
            repo.save(id: '3', name: 'a3', aId: '1')
            assert repo.getAll().length is 3


        it 'can load models with circular references', ->

            a = @f.createModel('a', { name: 'main', aId: '1' })

            assert a.a is a.a.a.a.a
            assert a.a.a is a.a.a.a.a.a
            assert a.a.a.a is a.a.a.a.a.a.a


    describe '$include', ->

        before ->
            { MemoryResource } = require '../others'

            class A extends Entity
                @isImmutable: true
                @properties:
                    name: @TYPES.STRING
                    a: @TYPES.MODEL 'a'

            class ARepository extends BaseAsyncRepository
                @modelName: 'a'
                client: new MemoryResource()

            @f = require('../create-facade').create()

            @f.addClass 'a', A
            @f.addClass 'a-repository', ARepository

            repo = @f.createRepository('a')

            Promise.all([
                repo.save(id: '1', name: 'a1', aId: '2')
                repo.save(id: '2', name: 'a2', aId: '3')
                repo.save(id: '3', name: 'a3', aId: '1')
            ])


        it 'includes model', ->
            a = @f.createModel('a', { name: 'main', aId: '1' })

            a.$include().then (newA) =>
                assert a isnt newA
                assert newA.a
                assert newA.a.a
                # assert newA.a.a.a # TODO



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
                hobbies: [
                    { id: 1, name: 'keyboard' }
                    { id: 2, name: 'ingress' }
                    { id: 3, name: 'Shogi' }
                ]
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



        it 'copies an empty list of value objects', ->

            class ValObj extends @facade.constructor.ValueObject
                @properties:
                    name: @TYPES.STRING

            class ValObjList extends @facade.constructor.BaseList
                @itemModelName: 'val-obj'

            @facade.addClass('val-obj', ValObj)
            @facade.addClass('val-obj-list', ValObjList)

            list = @facade.createModel 'val-obj-list'

            list2 = list.clone()

            assert.deepEqual list, list2


    describe 'copyWith', ->

        it 'shallow-copies the model', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: [
                    { id: 1, name: 'keyboard' }
                    { id: 2, name: 'ingress' }
                    { id: 3, name: 'Shogi' }
                ]
                age: 30

            diary = @facade.createModel 'diary',
                id: '2015/1/12'
                comment: 'sample'
                author: mem

            diary2 = diary.copyWith()

            assert.deepEqual diary, diary2
            assert diary2 instanceof @facade.getModel 'diary'
            assert diary2.author is mem


        it 'overwrites the given props', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: []
                age: 30

            diary = @facade.createModel 'diary',
                id: '2015/1/12'
                comment: 'sample'
                author: mem

            diary2 = diary.copyWith(comment: 'copied', extra: true)

            assert diary2.id is '2015/1/12'
            assert diary2.comment is 'copied'
            assert diary2.author is mem
            assert diary2.extra is true


        it 'replaces id of sub-entity', ->

            mem = @facade.createModel 'member',
                id: 11
                hobbies: []
                age: 30

            mem2 = @facade.createModel 'member',
                id: 22
                hobbies: []
                age: 22

            diary = @facade.createModel 'diary',
                id: '2015/1/12'
                comment: 'sample'
                author: mem

            diary2 = diary.copyWith(author: mem2)
            diary2.author is mem2
            diary2.memberId is 22


        it 'copies items of collection', ->
            class ValObj extends @facade.constructor.ValueObject
                @properties:
                    name: @TYPES.STRING

            class ValObjList extends @facade.constructor.BaseList
                @itemModelName: 'val-obj'
                @properties:
                    title: @TYPES.STRING

            @facade.addClass('val-obj', ValObj)
            @facade.addClass('val-obj-list', ValObjList)

            list = @facade.createModel 'val-obj-list', [
                { name: 'val1' }
                { name: 'val2' }
            ]

            list2 = list.copyWith(title: 'xxx')

            assert.deepEqual list2.items, list.items
            assert list2.title is 'xxx'



    describe 'getDiffProps', ->

        beforeEach ->
            { TYPES } = @facade.constructor.BaseModel
            properties =
                str: TYPES.STRING
                num: TYPES.NUMBER
                bool: TYPES.BOOLEAN
                obj: TYPES.OBJECT
                arr: TYPES.ARRAY
                date: TYPES.DATE
                en: TYPES.ENUM(['A', 'B', 'C'])

            class E extends @facade.constructor.Entity
                @properties: properties

            class V extends @facade.constructor.ValueObject
                @properties: properties

            class EL extends @facade.constructor.BaseList
                @itemModelName: 'e'
                @properties: properties

            class ED extends @facade.constructor.BaseDict
                @itemModelName: 'e'
                @properties: properties
                @key: (item) -> item.num

            class VL extends @facade.constructor.BaseList
                @itemModelName: 'v'
                @properties: properties

            class VD extends @facade.constructor.BaseDict
                @itemModelName: 'v'
                @properties: properties
                @key: (item) -> item.num

            @facade.addClass('e', E)
            @facade.addClass('v', V)
            @facade.addClass('el', EL)
            @facade.addClass('ed', ED)
            @facade.addClass('vl', VL)
            @facade.addClass('vd', VD)


        it 'regards as the same value to the plain object generated from toPlainObject()', ->

            model = @facade.createModel 'e',
                id: 'b89d'
                str: '123'
                num: 1192
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            assert model.isDifferentFrom(model) is false

            plain = model.toPlainObject()
            assert model.getDiffProps(plain).length is 0
            assert model.isDifferentFrom(plain) is false
            assert model.isDifferentFrom(JSON.parse JSON.stringify(plain)) is false

        it 'detects difference of string, number and boolean', ->

            model = @facade.createModel 'e',
                id: 'b89d'
                str: '123'
                num: 1192
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            assert model.isDifferentFrom(model) is false

            plain = model.toPlainObject()
            plain.str = 'xxx'
            plain.bool = false
            plain.num = 1129
            assert.deepEqual model.getDiffProps(plain), ['str', 'num', 'bool']


        it 'enums can be number or string', ->

            model = @facade.createModel 'v',
                str: '123'
                num: 1192
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            plain = model.toPlainObject()
            plain.en = 0
            assert model.isDifferentFrom(plain) is false

            plain.en = 1
            assert.deepEqual model.getDiffProps(plain), ['en']

            plain.en = 'A'
            assert model.isDifferentFrom(plain) is false

        it 'date can be string or date', ->

            model = @facade.createModel 'v',
                str: '123'
                num: 1192
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            plain = model.toPlainObject()
            plain.date = model.date.toISOString()
            assert model.isDifferentFrom(plain) is false

        it 'property of obj is checked deeply', ->

            model = @facade.createModel 'v',
                str: '123'
                num: 1192
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            plain = model.toPlainObject()
            plain.obj = { shinout: is: a: maintainer: true, carLicense: true }
            assert.deepEqual model.getDiffProps(plain), ['obj']

        it 'property of arr is checked deeply', ->

            model = @facade.createModel 'v',
                str: '123'
                num: 1192
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            plain = model.toPlainObject()
            plain.arr = [ { name: 123 }, { obj: key: 'string', key2: 10 } ]
            assert.deepEqual model.getDiffProps(plain), ['arr']

        it 'property of arr is checked deeply', ->

            model = @facade.createModel 'v',
                str: '123'
                bool: true
                obj: { shinout: is: a: maintainer: true }
                arr: [ { name: 123 }, { obj: key: 'string' } ]
                date: new Date()
                en: 'A'

            plain = model.toPlainObject()
            plain.arr = [ { name: 123 }, { obj: key: 'string', key2: 10 } ]
            assert.deepEqual model.getDiffProps(plain), ['arr']


        context 'when models contain submodels', ->

            beforeEach ->

                class ComplexModel extends @facade.constructor.Entity
                    @properties:
                        name: @TYPES.STRING
                        e: @TYPES.MODEL('e', 'exId')
                        v: @TYPES.MODEL('v')
                @facade.addClass('complex-model', ComplexModel)

                @complexModel = @facade.createModel 'complex-model',
                    name: 'hi'
                    e:
                        id: 'eb1b'
                        str: '123'
                        num: 1192
                        bool: true
                        obj: { shinout: is: a: maintainer: true }
                        arr: [ { name: 123 }, { obj: key: 'string' } ]
                        date: new Date()
                        en: 'A'
                    v:
                        str: '123'
                        num: 1192
                        bool: true
                        obj: { shinout: is: a: maintainer: true }
                        arr: [ { name: 123 }, { obj: key: 'string' } ]
                        date: new Date()
                        en: 'A'

            it 'checks difference of VO', ->
                plain = @complexModel.toPlainObject()
                plain.v.arr = [ { name: 123 }, { obj: key: 'string' }, 'xxx' ]
                assert.deepEqual @complexModel.getDiffProps(plain), ['v']

            it 'regards as the same value when a model is build by empty object', ->
                model = @facade.createModel('complex-model')
                plain = model.toPlainObject()
                assert model.isDifferentFrom(plain) is false
                assert model.v?
                assert not model.e?

            it 'regards as different between default VO and undefined value', ->

                model = @facade.createModel('complex-model')
                plain = model.toPlainObject()
                delete plain.v
                assert.deepEqual model.getDiffProps(plain), ['v']

            it 'regards as the same value when plain object contains no subEntity but id is the same', ->
                plain = @complexModel.toPlainObject()
                assert plain.exId is 'eb1b'

                assert not plain.e?
                assert @complexModel.e?

                assert @complexModel.isDifferentFrom(plain) is false

            it 'regards as the same value when plain object contains subEntity and id', ->
                plain = @complexModel.toPlainObject()
                plain.e = @complexModel.e.toPlainObject()
                assert @complexModel.isDifferentFrom(plain) is false


            it 'regards as different when plain object contains no subEntity and id is different', ->
                plain = @complexModel.toPlainObject()
                plain.exId = '1293'

                assert not plain.e?
                assert @complexModel.e?

                assert.deepEqual @complexModel.getDiffProps(plain), ['exId', 'e']


            it 'regards as different when plain object contains subEntity but id is different', ->
                plain = @complexModel.toPlainObject()
                plainE = @complexModel.e.toPlainObject()
                plain.e = plainE
                plain.exId = 'xxx'
                plain.e.id = 'xxx'
                assert.deepEqual @complexModel.getDiffProps(plain), ['exId', 'e']


        context 'when models contain VO Collection', ->

            beforeEach ->
                class ComplexModel extends @facade.constructor.Entity
                    @properties:
                        name: @TYPES.STRING
                        vl: @TYPES.MODEL('vl')
                        vd: @TYPES.MODEL('vd')
                @facade.addClass('complex-model', ComplexModel)

                date = new Date().toISOString()

                @getPlain = (num) ->
                    str: '123'
                    num: num ? 1192
                    bool: true
                    obj: { shinout: is: a: maintainer: true }
                    arr: [ { name: 123 }, { obj: key: 'string' } ]
                    date: date
                    en: 'A'

            it 'regards as the same value to the plain object generated from toPlainObject()', ->
                model = @facade.createModel 'complex-model',
                    name: 'xyz'
                    vl: [ @getPlain(1), @getPlain(2) ]
                    vd: [ @getPlain(3), @getPlain(4) ]

                plain = model.toPlainObject()

                assert model.isDifferentFrom(plain) is false
                assert model.isDifferentFrom(JSON.parse JSON.stringify(plain)) is false


            it 'regards as the same value when plain collections are array', ->
                model = @facade.createModel 'complex-model',
                    name: 'xyz'
                    vl: [ @getPlain(1), @getPlain(2) ]
                    vd: [ @getPlain(3), @getPlain(4) ]

                plain =
                    name: 'xyz'
                    vl: [ @getPlain(1), @getPlain(2) ]
                    vd: [ @getPlain(3), @getPlain(4) ]

                assert model.isDifferentFrom(plain) is false

            it 'regards as the same value when items are empty', ->
                model = @facade.createModel 'complex-model'
                plain = model.toPlainObject()
                assert model.isDifferentFrom(plain) is false

            it 'regards as the different value when compared with undefined submodel', ->
                model = @facade.createModel 'complex-model'
                plain = {}
                assert.deepEqual model.getDiffProps(plain), ['vl', 'vd']



        context 'when models contain Entity Collection', ->

            beforeEach ->
                class ComplexModel extends @facade.constructor.Entity
                    @properties:
                        name: @TYPES.STRING
                        el: @TYPES.MODEL('el')
                        ed: @TYPES.MODEL('ed')
                @facade.addClass('complex-model', ComplexModel)

                date = new Date().toISOString()

                @getPlain = (num) ->
                    id: if not num? then '1192' else num.toString()
                    str: '123'
                    num: num ? 1192
                    bool: true
                    obj: { shinout: is: a: maintainer: true }
                    arr: [ { name: 123 }, { obj: key: 'string' } ]
                    date: date
                    en: 'A'

            it 'regards as the same value to the plain object generated from toPlainObject()', ->
                model = @facade.createModel 'complex-model',
                    name: 'xyz'
                    el: [ @getPlain(1), @getPlain(2) ]
                    ed: [ @getPlain(3), @getPlain(4) ]

                plain = model.toPlainObject()
                assert model.isDifferentFrom(plain) is false
                assert model.isDifferentFrom(JSON.parse JSON.stringify(plain)) is false


            it 'regards as the same value when plain collections are array', ->
                model = @facade.createModel 'complex-model',
                    name: 'xyz'
                    el: [ @getPlain(1), @getPlain(2) ]
                    ed: [ @getPlain(3), @getPlain(4) ]

                plain =
                    name: 'xyz'
                    el: [ @getPlain(1), @getPlain(2) ]
                    ed: [ @getPlain(3), @getPlain(4) ]

                assert model.isDifferentFrom(plain) is false

            it 'regards as the same value when items are empty', ->
                model = @facade.createModel 'complex-model'
                plain = model.toPlainObject()
                assert model.isDifferentFrom(plain) is false

            it 'regards as the different value when compared with undefined submodel', ->
                model = @facade.createModel 'complex-model'
                plain = {}
                assert.deepEqual model.getDiffProps(plain), ['el', 'ed']




